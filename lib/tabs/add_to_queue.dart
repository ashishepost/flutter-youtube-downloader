import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_downloader/models/youtube_model.dart';
import 'package:youtube_downloader/services/http_service.dart';
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
  String _youtubeURL;
  bool _isLoading = true;
  bool _isDisabled = true;
  bool _appInitialized = true;
  Widget button;
  final HttpService httpService = HttpService();
  // final HistoryPageState historyPageState = HistoryPageState();

  final _formKey = GlobalKey<FormState>();

  FocusNode _youtubeURLNode = FocusNode();
  FocusNode _submitButtonNode = FocusNode();

  addToQueue() {
    setState(() {
      _isLoading = false;
    });
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      httpService.youtubeData(_youtubeURL).then((Youtube youtubeURLData) {
        // print(youtubeURLData.title);
        global.videos.add(
            {'name': youtubeURLData.title, 'link': youtubeURLData.videoURL});

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
    Pattern pattern = r'^(http(s)?:\/\/)?((w){3}.)?youtu(be|.be)?(\.com)?\/.+$';
    RegExp regex = new RegExp(pattern);
    _youtubeURL = url;
    // print(url);
    if (!regex.hasMatch(url)) {
      button = FlatButton(
        onPressed: null,
        focusNode: _submitButtonNode,
        child: Text('Add To Queue'),
      );

      setState(() {
        _isDisabled = true;
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
        _isDisabled = false;
      });
    }
  }

  initialized(){
    _appInitialized = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_appInitialized){
      getButton("");
      initialized();
    }
    return new Scaffold(
        body: Builder(
            builder: (context) => !_isLoading
                ? new Center(
                    child: new CircularProgressIndicator(),
                  )
                : new Container(
                    child: Form(
                      key: _formKey,
                      child: Center(
                        child: Column(
                          // center the children
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              focusNode: _youtubeURLNode,
                              autofocus: true,
                              // initialValue:
                              //     'https://www.youtube.com/watch?v=sugvnHA7ElY',
                              decoration: InputDecoration(
                                  labelText: "Enter Youtube URL:",
                                  hintText:
                                      'https://www.youtube.com/watch?v=sugvnHA7ElY'),
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
                                fieldFocusChange(context, _youtubeURLNode,
                                    _submitButtonNode);
                              },
                            ),
                            SizedBox(height: 20),
                            button,
                          ],
                        ),
                      ),
                    ),
                  )));
  }
}
