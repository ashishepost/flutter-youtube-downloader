import 'package:flutter/foundation.dart';

class Youtube {
  final String description;
  final String filename;
  final String thumbnail;
  final String title;
  final String videoURL;


  Youtube({
    @required this.description,
    @required this.filename,
    @required this.thumbnail,
    @required this.title,
    @required this.videoURL,
  });

  factory Youtube.fromJson(Map<String, dynamic> json) {
    // print(json);
    return Youtube(
      description: json['description'] as String,
      filename: json['filename'] as String,
      thumbnail: json['thumbnail'] as String,
      title: json['title'] as String,
      videoURL: json['video_url'] as String,
    );
  }
}