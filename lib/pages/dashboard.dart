import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'jsonfiles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'settings.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
    if (100-(recievedMessages.water*100)/recievedMessages.tankHeight > 50 && (irriswitch1 == 1 || irriswitch1 == 2)) {
      setState(() {
        setData("wtstatus", 0);
        irriswitch1 = 0;
        switchDisabled1 = true;
        switchValue1 = false;
      });
    }
    if (100-(recievedMessages.water*100)/recievedMessages.tankHeight < 30 && irriswitch1 == 0) {
      setState(() {
        irriswitch1 = 1;
        switchDisabled1 = false;
      });
    }
  }

  List<double> chart = new List();
  List<double> chart1 = new List();
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
          tankHeight: data['tankHeight'],
          soilTemp: data['soilTemp'],
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
        chart1.add(double.parse(data[key]['soilTemp'].toString()));
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
        chart1.add(double.parse(event.snapshot.value['soilTemp'].toString()));
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
          backgroundColor: Colors.green[300],
          title: Text('AgriSmart',
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
                  Text('',
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
            _buildTile(new Container(
              color: irriswitch > 0
                  ? irriswitch == 1 ? Colors.redAccent : Colors.greenAccent
                  : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              recievedMessages.language == "English"
                                  ? "Moisture Level"
                                  : recievedMessages.language == "हिंदी"
                                      ? "नमी स्तर"
                                      : "ஈரப்பதம் நிலை",
                              style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0)),
                          Text(
                              recievedMessages != null
                                  ? recievedMessages.moisture.toString() + "\%"
                                  : "Waiting",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 34.0))
                        ],
                      ),
                      Material(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(24.0),
                          //shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(24.0)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              //child: Icon(Icons.timeline,color: Colors.white, size: 30.0),
                              child: switchDisabled
                                  ? const Switch(
                                      value: false,
                                      onChanged: null,
                                    )
                                  : new Switch(
                                      onChanged: (bool value) {
                                        print("inside");
                                        if (value == true)
                                          setState(() {
                                            switchValue = true;
                                            setData("status", 1);
                                            irriswitch = 2;
                                          });
                                        else if (value == false)
                                          setState(() {
                                            switchValue = false;
                                            print("gandu");
                                            irriswitch = 0;
                                            setData("status", 0);
                                            checkStatus();
                                          });
                                      },
                                      value: switchValue,
                                      activeColor: Colors.lightGreen,
                                      activeTrackColor: Colors.red,
                                    ),
                            ),
                          ))
                    ]),
              ),
            )),
            _buildTile(new Container(
              color: irriswitch1 > 0
                  ? irriswitch1 == 1 ? Colors.redAccent : Colors.greenAccent
                  : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              recievedMessages.language == "English"
                                  ? "Water Tank Level"
                                  : recievedMessages.language == "हिंदी"
                                      ? "जल टैंक स्तर"
                                      : "தண்ணீர் தொட்டி நிலை",
                              style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0)),
                          Text(
                              recievedMessages != null
                                  ? (100-recievedMessages.water*100/recievedMessages.tankHeight).toInt().toString() + "\%"
                                  : "Waiting",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 34.0))
                        ],
                      ),
                      Material(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(24.0),
                          //shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(24.0)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              //child: Icon(Icons.timeline,color: Colors.white, size: 30.0),
                              child: switchDisabled1
                                  ? const Switch(
                                      value: false,
                                      onChanged: null,
                                    )
                                  : new Switch(
                                      onChanged: (bool value) {
                                        print("inside");
                                        if (value == true)
                                          setState(() {
                                            switchValue1 = true;
                                            setData("wtstatus", 1);
                                            irriswitch1 = 2;
                                          });
                                        else if (value == false)
                                          setState(() {
                                            switchValue1 = false;
                                            print("gandu");
                                            irriswitch1 = 0;
                                            setData("wtstatus", 0);
                                            checkStatus();
                                          });
                                      },
                                      value: switchValue1,
                                      activeColor: Colors.lightGreen,
                                      activeTrackColor: Colors.red,
                                    ),
                            ),
                          ))
                    ]),
              ),
            )),
//            _buildTile(
//              Padding(
//                padding: const EdgeInsets.all(24.0),
//                child: Column(
//                    mainAxisAlignment: MainAxisAlignment.start,
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      Material(
//                          color: Colors.amber,
//                          shape: CircleBorder(),
//                          child: Padding(
//                            padding: EdgeInsets.all(16.0),
//                            child: Icon(Icons.notifications,
//                                color: Colors.white, size: 30.0),
//                          )),
//                      Padding(padding: EdgeInsets.only(bottom: 16.0)),
//                      Text(recievedMessages.language=="English"?"Alerts":recievedMessages.language=="हिंदी"?"अधिसूचना":"அறிவித்தல்",
//                          style: TextStyle(
//                              color: Colors.black,
//                              fontWeight: FontWeight.w700,
//                              fontSize: 20.0)),
//                      Text(recievedMessages.language=="English"?'All':"", style: TextStyle(color: Colors.black45)),
//                    ]),
//              ),
//            ),
//
            _buildTile(
              Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                recievedMessages.language == "English"
                                    ? "Moisture Analysis"
                                    : recievedMessages.language == "हिंदी"
                                        ? "नमी विश्लेषण"
                                        : "ஈரப்பதம் பகுப்பாய்வு",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                              Text(
                                  recievedMessages != null
                                      ? (recievedMessages.moisture.toString() +
                                          "\%")
                                      : "Waiting",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 34.0)),
                            ],
                          ),
                          DropdownButton(
                              isDense: true,
                              value: actualDropdown,
                              onChanged: (String value) => setState(() {
                                    actualDropdown = value;

                                    actualChart = chartDropdownItems
                                        .indexOf(value); // Refresh the chart
                                  }),
                              items: chartDropdownItems.map((String title) {
                                return DropdownMenuItem(
                                  value: title,
                                  child: Text(title,
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.0)),
                                );
                              }).toList())
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 4.0)),
                      Sparkline(
                        data: actualChart == 0
                            ? chart.sublist(
                                (chart.length - 360) > 0
                                    ? (chart.length - 360)
                                    : 0,
                                chart.length)
                            : actualChart == 1
                                ? chart.sublist(
                                    (chart.length - 8640) >= 0
                                        ? chart.length - 8640
                                        : 0,
                                    chart.length)
                                : chart.sublist(
                                    (chart.length - 60480) >= 0
                                        ? chart.length - 60480
                                        : 0,
                                    chart.length),
                        lineWidth: 5.0,
                        sharpCorners: true,
                        pointsMode: PointsMode.last,
                        pointColor: Colors.red,
                        pointSize: 5.0,
                        lineColor: Colors.greenAccent,
                      )
                    ],
                  )),
            ),
                        _buildTile(
              Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                recievedMessages.language == "English"
                                    ? "Temperature Analysis"
                                    : recievedMessages.language == "हिंदी"
                                        ? "नमी विश्लेषण"
                                        : "ஈரப்பதம் பகுப்பாய்வு",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                              Text(
                                  recievedMessages != null
                                      ? (recievedMessages.soilTemp.toString() +
                                          "°C")
                                      : "Waiting",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 34.0)),
                            ],
                          ),
                          DropdownButton(
                              isDense: true,
                              value: actualDropdown,
                              onChanged: (String value) => setState(() {
                                    actualDropdown = value;

                                    actualChart = chartDropdownItems
                                        .indexOf(value); // Refresh the chart
                                  }),
                              items: chartDropdownItems.map((String title) {
                                return DropdownMenuItem(
                                  value: title,
                                  child: Text(title,
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.0)),
                                );
                              }).toList())
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 4.0)),
                      Sparkline(
                        data: actualChart == 0
                            ? chart1.sublist(
                                (chart1.length - 360) > 0
                                    ? (chart1.length - 360)
                                    : 0,
                                chart1.length)
                            : actualChart == 1
                                ? chart1.sublist(
                                    (chart1.length - 8640) >= 0
                                        ? chart1.length - 8640
                                        : 0,
                                    chart1.length)
                                : chart1.sublist(
                                    (chart1.length - 60480) >= 0
                                        ? chart1.length - 60480
                                        : 0,
                                    chart1.length),
                        lineWidth: 5.0,
                        sharpCorners: true,
                        pointsMode: PointsMode.last,
                        pointColor: Colors.red,
                        pointSize: 5.0,
                        lineColor: Colors.greenAccent,
                      )
                    ],
                  )),
            ),
            _buildTile(
              MaterialButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Setting(msg: recievedMessages)),
                  );
                },
                padding: const EdgeInsets.fromLTRB(0.0, 24.0, 24.0, 24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Material(
                          color: Colors.teal,
                          shape: CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(Icons.settings_applications,
                                color: Colors.white, size: 30.0),
                          )),
                      Padding(padding: EdgeInsets.only(bottom: 16.0)),
                      Text(
                          recievedMessages.language == "English"
                              ? "Settings"
                              : recievedMessages.language == "हिंदी"
                                  ? "सेटिंग्स"
                                  : "அமைப்புகள்",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0)),
                      Text(
                          recievedMessages.language == "English"
                              ? 'Threshold, etc...'
                              : "",
                          style: TextStyle(color: Colors.black45)),
                    ]),
              ),
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
            StaggeredTile.extent(2, 220.0),
            StaggeredTile.extent(2, 220.0),
            StaggeredTile.extent(1, 180.0),
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
