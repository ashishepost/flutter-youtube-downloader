import 'package:flutter/material.dart';
import 'package:youtube_downloader/tabs/add_to_queue.dart';
import 'package:youtube_downloader/tabs/history.dart';
import 'package:youtube_downloader/tabs/about.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

const debug = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: debug);

  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

// SingleTickerProviderStateMixin is used for animation
class MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  /*
   *-------------------- Setup Tabs ------------------*
   */
  // Create a tab controller
  TabController controller;

  @override
  void initState() {
    super.initState();

    // Initialize the Tab Controller
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  TabBar getTabBar() {
    return TabBar(
      tabs: <Tab>[
        Tab(
          // set icon to the tab
          icon: Icon(Icons.add_to_queue),
        ),
        Tab(
          icon: Icon(Icons.history),
        ),
        Tab(
          icon: Icon(Icons.info_outline),
        ),
      ],
      // setup the controller
      controller: controller,
    );
  }

  TabBarView getTabBarView(var tabs) {
    return TabBarView(
      // Add tabs as widgets
      children: tabs,
      // set the controller
      controller: controller,
    );
  }

  /*
   *-------------------- Setup the page by setting up tabs in the body ------------------*
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Appbar
        appBar: AppBar(
            // Title
            title: Text("Youtube Video Downloader"),
            // Set the background color of the App Bar
            backgroundColor: Colors.blue,
            // Set the bottom property of the Appbar to include a Tab Bar
            bottom: getTabBar()),
        // Set the TabBar view as the body of the Scaffold
        body: getTabBarView(<Widget>[AddToQueue(), History(), About()]));
  }
}
