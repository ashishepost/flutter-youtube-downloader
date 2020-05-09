import 'package:dio/dio.dart';
import 'package:youtube_downloader/models/youtube_model.dart';

class HttpService {
   Future<Youtube> youtubeData(String url) async {
    try {
      // var client = Dio(BaseOptions(baseUrl: "http://34.208.206.10/youtube/"));
      final String baseURL = 'http://34.208.206.10/youtube/';

      Response response = await Dio().post(baseURL + 'download-url/', data: {"url": url});
      // print("Go");
      // print(response.data);
      return Youtube.fromJson(response.data);
    } catch (error) {
      print(error);
    }
  }

   Future<Youtube> youtubeBulkData(String urlList) async {
    try {
      // var client = Dio(BaseOptions(baseUrl: "http://34.208.206.10/youtube/"));
      final String baseURL = 'http://34.208.206.10/youtube/';

      Response response = await Dio().post(baseURL + 'download-bulk-urls/', data: urlList);
      // print(response.data);
      // print(Youtube.fromJson(response.data));
      return Youtube.fromBulkJson(response.data);
    } catch (error) {
      print(error);
    }
  }
}

// import 'package:youtube_downloader/models/youtube_model.dart';
// import 'package:http/http.dart' as http;
// import 'dart:async';
// import 'dart:convert';

// class HttpService {
//   final String baseURL = 'http://34.208.206.10/youtube/';

//   Future<Youtube> downloadURL(String url) async {
//     final http.Response response = await http.post(
//       baseURL + 'download-url/',
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, String>{
//         'url': url,
//       }),
//     );
//     if (response.statusCode == 200) {
//       // If the server did return a 201 CREATED response,
//       // then parse the JSON.
//       return Youtube.fromJson(json.decode(response.body));
//     } else {
//       // If the server did not return a 201 CREATED response,
//       // then throw an exception.
//       throw Exception('Failed to load album');
//     }
//   }
// }
