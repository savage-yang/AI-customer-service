import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ChatService {
  static const String baseUrl = 'http://192.168.2.128:8000';

  String _sessionId = '';

  String get sessionId => _sessionId;

  Future<String> sendMessage(String question, {String? sessionId}) async {
    _sessionId = sessionId ?? _sessionId;
    if (_sessionId.isEmpty) {
      _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    }

    final url = Uri.parse('$baseUrl/chat/');
    final request = await HttpClient().postUrl(url);
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'text/event-stream');

    final body = json.encode({
      'question': question,
      'session_id': _sessionId,
    });
    request.write(body);

    final response = await request.close();
    final completer = Completer<String>();
    final fullAnswer = StringBuffer();

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
  }

  Stream<String> sendMessageStream(String question, {String? sessionId}) async* {
    _sessionId = sessionId ?? _sessionId;
    if (_sessionId.isEmpty) {
      _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    }

    final url = Uri.parse('$baseUrl/chat/');
    final request = await HttpClient().postUrl(url);
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'text/event-stream');

    final body = json.encode({
      'question': question,
      'session_id': _sessionId,
    });
    request.write(body);

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
  }

  Future<List<Map<String, dynamic>>> getHistory(String sessionId) async {
    final url = Uri.parse('$baseUrl/chat/history/$sessionId');
    final request = await HttpClient().getUrl(url);
    final response = await request.close();

    if (response.statusCode == HttpStatus.ok) {
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body) as Map<String, dynamic>;
      return (data['messages'] as List).cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  Future<void> clearSession(String sessionId) async {
    final url = Uri.parse('$baseUrl/chat/session/$sessionId');
    final request = await HttpClient().deleteUrl(url);
    await request.close();
  }

  void resetSession() {
    _sessionId = '';
  }
}