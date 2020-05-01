import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:youtube_downloader/models/youtube_model.dart';
import 'package:youtube_downloader/services/http_service.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

// import 'package:youtube_downloader/tabs/history.dart';

import 'package:youtube_downloader/global/global.dart' as global;

class AddToQueue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new AddToQueuePage(),
    );
  }
}

class AddToQueuePage extends StatefulWidget {
  AddToQueuePage({Key key}) : super(key: key);
  @override
  _AddToQueueState createState() => _AddToQueueState();
}

class _AddToQueueState extends State<AddToQueuePage> {
  List<String> _youtubeURL;
  bool _isLoading = true;
  bool _isDisabled = true;
  bool _appInitialized = true;
  Widget button;
  Widget inputField;
  bool isBulkDownload = false;
  final HttpService httpService = HttpService();
  // final HistoryPageState historyPageState = HistoryPageState();

  final _formKey = GlobalKey<FormState>();

  FocusNode _youtubeURLNode = FocusNode();
  FocusNode _submitButtonNode = FocusNode();

  addToQueue() {
    setState(() {
      _isLoading = false;
    });
    if (_youtubeURL.length > 1) {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        var tempObject = jsonEncode({"urls": _youtubeURL});
        httpService
            .youtubeBulkData(tempObject.toString())
            .then((Youtube youtubeURLData) {
          // print(youtubeURLData.urlData);
          for (var urlDetails in youtubeURLData.urlData) {
            // print(urlDetails['video_url']);
            global.videos.add(
                {'name': urlDetails['title'], 'link': urlDetails['video_url']});
            // print({'name': urlDetails['title'], 'link': urlDetails['video_url']});
          }
          setState(() {
            _isLoading = true;
          });
          toastMessage("Youtube Videos Added to the Queue", 'success');
          _appInitialized = true;
        });
      } else {
        _formKey.currentState.save();
        setState(() {
          _isLoading = true;
        });
        toastMessage("Please Check Youtube URLs", 'error');
      }
    } else {
      {
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();
          // print(_youtubeURL[0]);

          httpService
              .youtubeData(_youtubeURL[0])
              .then((Youtube youtubeURLData) {
            global.videos.add({
              'name': youtubeURLData.title,
              'link': youtubeURLData.videoURL
            });

            setState(() {
              _isLoading = true;
            });
            toastMessage("Youtube Video Added to the Queue", 'success');
            _appInitialized = true;
          });
        } else {
          _formKey.currentState.save();
          setState(() {
            _isLoading = true;
          });
          toastMessage("Please Check Youtube URL", 'error');
        }
      }
    }
  }

  void toastMessage(String message, String error) {
    switch (error) {
      case 'success':
        Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.blue,
            fontSize: 16.0);
        break;
      case 'warning':
        Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.orange,
            fontSize: 16.0);
        break;
      case 'error':
        Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            fontSize: 16.0);
        break;
      default:
    }
  }

  void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void getButton(String url) {
    if (isBulkDownload) {
      var urls = url.split('\n');
      _youtubeURL = urls;
      if (validateURL(urls)) {
        button = new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                onPressed: addToQueue,
                focusNode: _submitButtonNode,
                child: Text('Add To Queue'),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
              ),
              // button = FlatButton(
              //   onPressed: null,
              //   focusNode: _submitButtonNode,
              //   child: Text('Validate URLs'),
              //   color: Theme.of(context).primaryColor,
              //   textColor: Colors.white,
              // ),
            ]);
        setState(() {
          _isDisabled = !_isDisabled;
        });
      } else {
        button = new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                onPressed: null,
                focusNode: _submitButtonNode,
                child: Text('Add To Queue'),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
              ),
              // button = FlatButton(
              //   onPressed: null,
              //   focusNode: _submitButtonNode,
              //   child: Text('Validate URLs'),
              //   color: Theme.of(context).primaryColor,
              //   textColor: Colors.white,
              // ),
            ]);
        setState(() {
          _isDisabled = !_isDisabled;
        });
      }
      return;
    }

    List<String> temp = [url];
    _youtubeURL = temp;

    // print(url);
    if (!validateURL([url])) {
      button = FlatButton(
        onPressed: null,
        focusNode: _submitButtonNode,
        child: Text('Add To Queue'),
      );

      setState(() {
        _isDisabled = !_isDisabled;
      });
    } else {
      button = FlatButton(
        onPressed: addToQueue,
        focusNode: _submitButtonNode,
        child: Text('Add To Queue'),
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
      );

      setState(() {
        _isDisabled = !_isDisabled;
      });
    }
  }

  bool validateURL(List<String> urls) {
    Pattern pattern = r'^(http(s)?:\/\/)?((w){3}.)?youtu(be|.be)?(\.com)?\/.+$';
    RegExp regex = new RegExp(pattern);

    for (var url in urls) {
      if (!regex.hasMatch(url)) {
        return false;
      }
    }
    return true;
  }

  getInputField() {
    if (!isBulkDownload) {
      inputField = TextFormField(
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        focusNode: _youtubeURLNode,
        autofocus: true,
        // initialValue:
        //     'https://www.youtube.com/watch?v=sugvnHA7ElY',
        decoration: InputDecoration(
            labelText: "Enter Youtube URL:",
            hintText: 'https://www.youtube.com/watch?v=sugvnHA7ElY'),
        // validator: (name) {
        //   Pattern pattern =
        //       r'^(http(s)?:\/\/)?((w){3}.)?youtu(be|.be)?(\.com)?\/.+$';
        //   RegExp regex = new RegExp(pattern);
        //   if (!regex.hasMatch(name))
        //     return 'Invalid Youtube URL';
        //   else
        //     setState(() {
        //       _isDisabled = false;
        //     });
        //   return null;
        // },
        onChanged: getButton,
        // onSaved: (name) {
        //   _youtubeURL = name;
        // },
        onFieldSubmitted: (_) {
          fieldFocusChange(context, _youtubeURLNode, _submitButtonNode);
        },
      );

      // setState(() {
      //   isBulkDownload = !isBulkDownload;
      // });
    } else {
      inputField = new TextField(
        keyboardType: TextInputType.multiline,
        onChanged: getButton,
        maxLines: null,
        decoration: InputDecoration(
            labelText: "Enter Youtube URLs One Per Line",
            hintText:
                'https://www.youtube.com/watch?v=sugvnHA7ElY\nhttps://www.youtube.com/watch?v=5KlnlCq2M5Q\nhttps://www.youtube.com/watch?v=Rn6HPDltaWk'),
      );

      // setState(() {
      //   isBulkDownload = !isBulkDownload;
      // });
    }
    // print(inputField);
  }

  initialized() {
    _appInitialized = false;
  }

// https://www.youtube.com/watch?v=qFkNATtc3mc
// https://www.youtube.com/watch?v=oGneAab3e88
  @override
  Widget build(BuildContext context) {
    if (_appInitialized) {
      getButton("");
      getInputField();
      initialized();
    }
    return new Scaffold(
        body: Builder(
            builder: (context) => !_isLoading
                ? new Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                        new CircularProgressIndicator(),
                        SizedBox(height: 20),
                        !isBulkDownload
                            ? new Text('please wait while fetching Video.',
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16))
                            : new Text('please wait while fetching Videos.',
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                      ]))
                : new Container(
                    child: Form(
                      key: _formKey,
                      child: Center(
                        child: Column(
                          // center the children
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  new Text('Enable Bulk Download',
                                      style: TextStyle(
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Switch(
                                    value: isBulkDownload,
                                    onChanged: (value) {
                                      setState(() {
                                        isBulkDownload = value;
                                        getButton("");
                                        getInputField();
                                      });
                                    },
                                    activeTrackColor:
                                        Theme.of(context).primaryColor,
                                    activeColor: Theme.of(context).primaryColor,
                                  )
                                ]),
                            SizedBox(height: 10),
                            inputField,
                            SizedBox(height: 20),
                            button,
                          ],
                        ),
                      ),
                    ),
                  )));
  }
}
