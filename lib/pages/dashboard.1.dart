import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'jsonfiles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'settings.dart';
import 'dashboard.dart';
import 'package:weather/weather.dart';

class MainPage1 extends StatefulWidget {
  @override
  _MainPageState1 createState() => _MainPageState1();
}

class _MainPageState1 extends State<MainPage1> {
  static final List<String> chartDropdownItems = [
    'Last 1 hour',
    'Last 24 hours',
    'Last 1 week'
  ];
  SnackBar snackBar = new SnackBar(
    content: new Text("Hello World"),
  );
  String actualDropdown = chartDropdownItems[0];
  Stopwatch stopwatch = new Stopwatch();
  int actualChart = 0;
  bool connected = true;
  DatabaseReference dr =
      FirebaseDatabase.instance.reference().child("realtime");
  Messages recievedMessages;
  int irriswitch = 0, irriswitch1 = 0;
  bool switchValue = false, switchValue1 = false;
  bool switchDisabled = true, switchDisabled1 = true;
  bool currentPulse = true;
  int count = 0;
  final GlobalKey<ScaffoldState> mScaffoldState =
      new GlobalKey<ScaffoldState>();
  setData(String k, int v) {
    print("reaching");
    dr.update({k: v});
  }

  void snackMessage(String content) {
    final snackBar = new SnackBar(
      content: new Text(content),
    );
    mScaffoldState.currentState.showSnackBar(snackBar);
  }

  checkStatus() {
    if (recievedMessages.moisture > recievedMessages.upThreshold &&
        (irriswitch == 1 || irriswitch == 2)) {
      setState(() {
        setData("status", 0);
        irriswitch = 0;
        switchDisabled = true;
        switchValue = false;
      });
    }
    if (recievedMessages.moisture < recievedMessages.downThreshold &&
        irriswitch == 0) {
      setState(() {
        irriswitch = 1;
        switchDisabled = false;
      });
    }
    if (recievedMessages.water > 50 && (irriswitch1 == 1 || irriswitch1 == 2)) {
      setState(() {
        setData("wtstatus", 0);
        irriswitch1 = 0;
        switchDisabled1 = true;
        switchValue1 = false;
      });
    }
    if (recievedMessages.water < 30 && irriswitch1 == 0) {
      setState(() {
        irriswitch1 = 1;
        switchDisabled1 = false;
      });
    }
  }

  List<double> chart = new List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chart.clear();
    recievedMessages = new Messages(
        status: 0,
        moisture: 0,
        downThreshold: 0,
        upThreshold: 0,
        language: "English");
    DatabaseReference ref =
        FirebaseDatabase.instance.reference().child("realtime");
    ref.onValue.listen((Event event) async {
      var data = event.snapshot.value;
      recievedMessages = new Messages(
          status: data['status'],
          moisture: data['moisture'],
          downThreshold: data['downThreshold'],
          upThreshold: data['upThreshold'],
          language: data['language'],
          water: data['water'],
          wtstatus: data['wtstatus'],
          pulse: data['pulse']);
      setState(() {
        if (recievedMessages.pulse == currentPulse)
          stopwatch.start();
        else {
          currentPulse = recievedMessages.pulse;
          if (stopwatch.isRunning) {
            stopwatch.reset();
            stopwatch.reset();
          }
          if (connected == false) {
            print("IoT Devices Connected Again");
            snackMessage("IoT Device Connected");
            connected = true;
          }
        }
        if (stopwatch.isRunning && stopwatch.elapsedMilliseconds >= 60000) {
          print("The IoT device is not connected");
          snackMessage("The IoT device is not connected");
          connected = false;
        }
        checkStatus();
      });
    });
    DatabaseReference dstore = FirebaseDatabase.instance.reference();

    dstore
        .child('store')
        .orderByChild('timestamp')
        .limitToLast(60480)
        .once()
        .then((DataSnapshot snap) {
      var keys = snap.value.keys;

      var data = snap.value;

      //chart.clear();

      for (var key in keys) {
        // Store d = new Store(

        //   moisture: data[key]['moisture'],

        //   status: data[key]['status'],

        //   timestamp: data[key]['timestamp'],

        // );
        chart.add(double.parse(data[key]['moisture'].toString()));
      }
      setState(() {
        //print('Length : ${chart.toString()}');
      });
    });
    dstore
        .child('store')
        .orderByChild('timestamp')
        .limitToLast(1)
        .onChildAdded
        .listen((Event event) {
      setState(() {
        chart.add(double.parse(event.snapshot.value['moisture'].toString()));
        print("Hafffe::" + event.snapshot.value['moisture'].toString());
        if (chart.length > 60480) chart.removeAt(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: mScaffoldState,
        appBar: AppBar(
          elevation: 2.0,
          backgroundColor: Colors.white,
          title: Text('SmartFarm',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 30.0)),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Dashboard',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0))
                ],
              ),
            )
          ],
        ),
        body: StaggeredGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            _buildTile(
               Padding(
                 padding: const EdgeInsets.all(24.0),
                 child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: <Widget>[
                       Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: <Widget>[
                           Text(recievedMessages.language=="English"?"Irrigation System":recievedMessages.language=="हिंदी"?"विशेषज्ञ के साथ चैट करें":"செய்தி நிபுணர்",
                               style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700,
                                   fontSize: 24.0)),
                           Text(recievedMessages.language=="English"?'Smart irrigation solutions':"",
                               style: TextStyle(
                                   color: Colors.black45,
                                   fontWeight: FontWeight.bold
                                   ))
                         ],
                       ),
                       Material(
                           color: Colors.red,
                           borderRadius: BorderRadius.circular(24.0),
                           child: Center(
                               child: Padding(
                             padding: EdgeInsets.all(16.0),
                             child: Icon(Icons.chat,
                                 color: Colors.white, size: 30.0),
                           )))
                     ]),
               ),
               onTap:
                   () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MainPage())),

               ),
               _buildTile(
               Padding(
                 padding: const EdgeInsets.all(24.0),
                 child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: <Widget>[
                       Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: <Widget>[
                           Text(recievedMessages.language=="English"?"Crops Recommendation":recievedMessages.language=="हिंदी"?"विशेषज्ञ के साथ चैट करें":"செய்தி நிபுணர்",
                               style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700,
                                   fontSize: 24.0)),
                           Text(recievedMessages.language=="English"?'Recommends best crops...':"",
                               style: TextStyle(
                                   color: Colors.black45,
                                   fontWeight: FontWeight.bold
                                   ))
                         ],
                       ),
                       Material(
                           color: Colors.red,
                           borderRadius: BorderRadius.circular(24.0),
                           child: Center(
                               child: Padding(
                             padding: EdgeInsets.all(16.0),
                             child: Icon(Icons.chat,
                                 color: Colors.white, size: 30.0),
                           )))
                     ]),
               ),
               onTap:
                   () {} //=> Navigator.of(context).push(MaterialPageRoute(builder: (_) => ShopItemsPage())),

               ),
            _buildTile(
               Padding(
                 padding: const EdgeInsets.all(24.0),
                 child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: <Widget>[
                       Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: <Widget>[
                           Text(recievedMessages.language=="English"?"Chat with Experts":recievedMessages.language=="हिंदी"?"विशेषज्ञ के साथ चैट करें":"செய்தி நிபுணர்",
                               style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700,
                                   fontSize: 24.0)),
                           Text(recievedMessages.language=="English"?'Facing Issues? Get help...':"",
                               style: TextStyle(
                                   color: Colors.black45,
                                   fontWeight: FontWeight.bold
                                   ))
                         ],
                       ),
                       Material(
                           color: Colors.red,
                           borderRadius: BorderRadius.circular(24.0),
                           child: Center(
                               child: Padding(
                             padding: EdgeInsets.all(16.0),
                             child: Icon(Icons.chat,
                                 color: Colors.white, size: 30.0),
                           )))
                     ]),
               ),
               onTap:
                   () {} //=> Navigator.of(context).push(MaterialPageRoute(builder: (_) => ShopItemsPage())),

               ),
          ],
          staggeredTiles: [
            StaggeredTile.extent(2, 110.0),
            StaggeredTile.extent(2, 110.0),
            StaggeredTile.extent(2, 110.0),
          ],
        ));
  }

  Widget _buildTile(Widget child, {Function() onTap}) {
    return Material(
        elevation: 14.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: Color(0x802196F3),
        child: InkWell(
            // Do onTap() if it isn't null, otherwise do print()
            onTap: onTap != null ? () => onTap() : () {},
            child: child));
  }
}
