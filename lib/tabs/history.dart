import 'package:flutter/material.dart';

import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:youtube_downloader/global/global.dart' as global;

const debug = true;

class History extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return Container(
      child: new HistoryPage(
        platform: platform,
      ),
    );
  }
}

class HistoryPage extends StatefulWidget with WidgetsBindingObserver {
  final TargetPlatform platform;

  HistoryPage({Key key, this.platform}) : super(key: key);

  @override
  _HistoryPageState createState() => new _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // final videos = [
  //   {
  //     'name': 'Big Buck Bunny',
  //     'link':
  //         'https://r2---sn-nx5s7n7s.googlevideo.com/videoplayback?expire=1587657138&ei=UmWhXsbBI7GBsfIPsZCQyAg&ip=34.208.206.10&id=o-AFTT-4gsT1oSMAzpzls2rAk_HhXqlamftZ-Jiwq_1TaR&itag=18&source=youtube&requiressl=yes&mh=y5&mm=31%2C26&mn=sn-nx5s7n7s%2Csn-a5mlrn7k&ms=au%2Conr&mv=u&mvi=1&pl=21&vprv=1&mime=video%2Fmp4&gir=yes&clen=12935163&ratebypass=yes&dur=145.217&lmt=1575001741596677&mt=1587634904&fvip=2&c=WEB&txp=3531432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&sig=AJpPlLswRgIhAO-ss0NOUR3wOGFgthA37j2cS6uyyJIpqeAJ9WJxOHGFAiEAy2kG23ZInc7UxOrjUP04RJhxdIlWD9qV7uRYqz6nSW0%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl&lsig=ALrAebAwRQIhAOQz1xcxBNVAEZnAg57p00dyLBWyQKBH6LP3c1EGpDhSAiByjviTkyZeC1_1tYUlNe8puCMwYh39b3edziTS-di_1A%3D%3D'
  //   },
  //   {
  //     'name': 'Elephant Dreams',
  //     'link':
  //         "https://r6---sn-nx57ynlz.googlevideo.com/videoplayback?expire=1587655902&ei=fmChXv2zJc7JkgaGtrvICQ&ip=34.208.206.10&id=o-ADiB981BpSEgM3hh2SH8eotWzHrI23F_5Ux_zpk6V7i9&itag=22&source=youtube&requiressl=yes&mh=SK&mm=31%2C26&mn=sn-nx57ynlz%2Csn-a5meknll&ms=au%2Conr&mv=u&mvi=5&pl=21&vprv=1&mime=video%2Fmp4&ratebypass=yes&dur=522.983&lmt=1577801864532565&mt=1587633691&fvip=6&beids=9466587&c=WEB&txp=5535432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cratebypass%2Cdur%2Clmt&sig=AJpPlLswRQIgWAWkKWneqMUIr00U3BSFT86cE9WLFUi8Y30wpBaNaBoCIQCGqCYRcY9PDWDPs70q9CoymQQRevmvPA4fNCoyBcOdew%3D%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl&lsig=ALrAebAwRgIhAOHRWreIvIgAAIma3OTaTK21pxXi3MTDZ7LWjZaOzliyAiEA7n7aeP4XzAHd7mAgWDDZ_VqcgnniS2uLDTIBHLO1eUk%3D"
  //   }
  // ];

  // var videos = [];
  List<_TaskInfo> _tasks;
  List<_ItemHolder> _items;
  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _isLoading = true;
    _permissionReady = false;

    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (debug) {
        print('UI Isolate Callback: $data');
      }
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      final task = _tasks?.firstWhere((task) => task.taskId == id);
      if (task != null) {
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // appBar: new AppBar(
      //   title: new Text(widget.title),
      // ),
      body: Builder(
          builder: (context) => _isLoading
              ? new Center(
                  child: new CircularProgressIndicator(),
                )
              : _permissionReady
                  ? new Container(
                      child: new ListView(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        children: _items
                            .map((item) => item.task == null
                                ? new Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 18.0),
                                    ),
                                  )
                                : new Container(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 8.0),
                                    child: InkWell(
                                      onTap: item.task.status ==
                                              DownloadTaskStatus.complete
                                          ? () {
                                              _openDownloadedFile(item.task)
                                                  .then((success) {
                                                if (!success) {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              'Cannot open this file')));
                                                }
                                              });
                                            }
                                          : null,
                                      child: new Stack(
                                        children: <Widget>[
                                          new Container(
                                            width: double.infinity,
                                            height: 64.0,
                                            child: new Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                FadeInImage.assetNetwork(
                                                  placeholder:
                                                      'assets/loader.gif',
                                                  // placeholderScale: 20,
                                                  image: item.thumbnail,
                                                  height: 40,
                                                ),
                                                // Image(image: AssetImage('assets/loader.gif'), height: 40),
                                                SizedBox(width: 5),
                                                new Expanded(
                                                  child: new Text(
                                                    item.name,
                                                    maxLines: 1,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                new Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: _buildActionForTask(
                                                      item.task),
                                                ),
                                              ],
                                            ),
                                          ),
                                          item.task.status ==
                                                      DownloadTaskStatus
                                                          .running ||
                                                  item.task.status ==
                                                      DownloadTaskStatus.paused
                                              ? new Positioned(
                                                  left: 0.0,
                                                  right: 0.0,
                                                  bottom: 0.0,
                                                  child:
                                                      new LinearProgressIndicator(
                                                    value: item.task.progress /
                                                        100,
                                                  ),
                                                )
                                              : new Container()
                                        ]
                                            .where((child) => child != null)
                                            .toList(),
                                      ),
                                    ),
                                  ))
                            .toList(),
                      ),
                    )
                  : new Container(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                'Please grant accessing storage permission to continue -_-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 18.0),
                              ),
                            ),
                            SizedBox(
                              height: 32.0,
                            ),
                            FlatButton(
                                onPressed: () {
                                  _checkPermission().then((hasGranted) {
                                    setState(() {
                                      _permissionReady = hasGranted;
                                    });
                                  });
                                },
                                child: Text(
                                  'Retry',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ))
                          ],
                        ),
                      ),
                    )),
    );
  }

  Widget _buildActionForTask(_TaskInfo task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return new RawMaterialButton(
        onPressed: () {
          _requestDownload(task);
        },
        child: new Icon(Icons.file_download),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return new RawMaterialButton(
        onPressed: () {
          _pauseDownload(task);
        },
        child: new Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return new RawMaterialButton(
        onPressed: () {
          _resumeDownload(task);
        },
        child: new Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text(
            'Ready',
            style: new TextStyle(color: Colors.green),
          ),
          RawMaterialButton(
            onPressed: () {
              _delete(task);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return new Text('Canceled', style: new TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text('Failed', style: new TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              _retryDownload(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else {
      return null;
    }
  }

  void _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

  void _cancelDownload(_TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void _pauseDownload(_TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void _resumeDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  Future<bool> _openDownloadedFile(_TaskInfo task) {
    return FlutterDownloader.open(taskId: task.taskId);
  }

  void _delete(_TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }

  Future<bool> _checkPermission() async {
    if (widget.platform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();
    // print(Random().nextInt(1000).toString());

    // print(videos);
    int count = 0;
    _tasks = [];
    _items = [];
    // print("tilu");
    // print(global.videos);
    _tasks.addAll(global.videos.map((video) => _TaskInfo(
        name: video['name'],
        link: video['link'],
        thumbnail: video['thumbnail'])));

    if (_tasks.length == 0) {
      _items.add(_ItemHolder(name: 'No Youtube Videos in Queue'));
    } else {
      _items.add(_ItemHolder(name: 'Youtube Videos Queue'));
    }
    for (int i = count; i < _tasks.length; i++) {
      _items.add(_ItemHolder(
          name: _tasks[i].name,
          thumbnail: _tasks[i].thumbnail,
          task: _tasks[i]));
      // print("kalu");
      // print(_tasks[i].name + _tasks[i].thumbnail);
      // print(_tasks[i].thumbnail);
      // print(_tasks[i].name);
      count++;
    }
    //  print(_tasks.length);
    // print(_items);
    tasks?.forEach((task) {
      for (_TaskInfo info in _tasks) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _permissionReady = await _checkPermission();

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _findLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

class _TaskInfo {
  final String name;
  final String link;
  final String thumbnail;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link, this.thumbnail});
}

class _ItemHolder {
  final String name;
  final String thumbnail;
  final _TaskInfo task;

  _ItemHolder({this.name, this.thumbnail, this.task});
}

// var history = History();
// history.initialize();
