import 'package:flutter/cupertino.dart';
import '../services/video_service.dart';

class VideoServiceProvider with ChangeNotifier {
  final VideoService _videoService = VideoService();

  VideoService get service => _videoService;

  void notify() => notifyListeners();
}