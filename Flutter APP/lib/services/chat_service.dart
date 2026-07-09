import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../config/app_config.dart';

class ChatService {
  static const String baseUrl = AppConfig.baseUrl;
  static const Duration _connectionTimeout = Duration(seconds: 15);
  static const Duration _receiveTimeout = Duration(seconds: 30);

  String _sessionId = '';
  late final String _userId;

  String get sessionId => _sessionId;
  String get userId => _userId;

  ChatService() {
    _userId = 'u_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
  }

  Future<String> sendMessage(String question, {String? sessionId}) async {
    _sessionId = sessionId ?? _sessionId;
    if (_sessionId.isEmpty) {
      _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    }

    final httpClient = HttpClient()
      ..connectionTimeout = _connectionTimeout
      ..idleTimeout = _receiveTimeout;

    try {
      final url = Uri.parse('$baseUrl/chat/');
      final request = await httpClient.postUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'text/event-stream');

      final body = json.encode({
        'question': question,
        'session_id': _sessionId,
        'user_id': _userId,
      });
      final bodyBytes = utf8.encode(body);
      request.headers.set('Content-Length', bodyBytes.length.toString());
      request.add(bodyBytes);

      final response = await request.close();
      final completer = Completer<String>();
      final fullAnswer = StringBuffer();

      Timer(_receiveTimeout, () {
        if (!completer.isCompleted) {
          completer.completeError(Exception('服务响应超时'));
        }
      });

      response.transform(utf8.decoder).listen(
        (data) {
          final lines = data.split('\n');
          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final content = line.substring(6);
              if (content == '[DONE]') {
                completer.complete(fullAnswer.toString());
              } else if (content.startsWith('[ERROR]')) {
                completer.completeError(Exception(content.substring(8)));
              } else {
                fullAnswer.write(content);
              }
            }
          }
        },
        onError: (error) {
          completer.completeError(error);
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete(fullAnswer.toString());
          }
        },
      );

      return completer.future;
    } catch (e) {
      rethrow;
    } finally {
      httpClient.close();
    }
  }

  Stream<String> sendMessageStream(String question, {String? sessionId}) async* {
    _sessionId = sessionId ?? _sessionId;
    if (_sessionId.isEmpty) {
      _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    }

    final httpClient = HttpClient()
      ..connectionTimeout = _connectionTimeout
      ..idleTimeout = _receiveTimeout;

    try {
      final url = Uri.parse('$baseUrl/chat/');
      final request = await httpClient.postUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'text/event-stream');

      final body = json.encode({
        'question': question,
        'session_id': _sessionId,
        'user_id': _userId,
      });
      final bodyBytes = utf8.encode(body);
      request.headers.set('Content-Length', bodyBytes.length.toString());
      request.add(bodyBytes);

      final response = await request.close();

      await for (final data in response.transform(utf8.decoder)) {
        final lines = data.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final content = line.substring(6);
            if (content == '[DONE]') {
              return;
            } else if (content.startsWith('[ERROR]')) {
              throw Exception(content.substring(8));
            } else {
              yield content;
            }
          }
        }
      }
    } catch (e) {
      throw Exception('网络连接失败: $e');
    } finally {
      httpClient.close();
    }
  }

  Future<List<Map<String, dynamic>>> getHistory(String sessionId) async {
    final httpClient = HttpClient()..connectionTimeout = _connectionTimeout;

    try {
      final url = Uri.parse('$baseUrl/chat/history/$sessionId');
      final request = await httpClient.getUrl(url);
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final body = await response.transform(utf8.decoder).join();
        final data = json.decode(body) as Map<String, dynamic>;
        return (data['messages'] as List).cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    } finally {
      httpClient.close();
    }
  }

  Future<void> clearSession(String sessionId) async {
    final httpClient = HttpClient()..connectionTimeout = _connectionTimeout;

    try {
      final url = Uri.parse('$baseUrl/chat/session/$sessionId');
      final request = await httpClient.deleteUrl(url);
      await request.close();
    } catch (e) {
      // ignore
    } finally {
      httpClient.close();
    }
  }

  void resetSession() {
    _sessionId = '';
  }
}