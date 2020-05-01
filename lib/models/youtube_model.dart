import 'package:flutter/foundation.dart';

class Youtube {
  final String description;
  final String filename;
  final String thumbnail;
  final String title;
  final String videoURL;
  final List urlData;


  Youtube({
    this.description,
    this.filename,
    this.thumbnail,
    this.title,
    this.videoURL,
    this.urlData,
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
   factory Youtube.fromBulkJson(Map<String, dynamic> json) {
    // print(json);
    return Youtube(
      urlData: json['urlData'] as List,
    );
  }
}