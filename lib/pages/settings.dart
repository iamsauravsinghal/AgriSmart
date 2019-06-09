import 'dart:async';
import 'package:flutter/material.dart';
import 'jsonfiles.dart';
import 'package:firebase_database/firebase_database.dart';
class Setting extends StatefulWidget
{
  final Messages msg;
  Setting({this.msg});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SettingState();
  }
}
class SettingState extends State<Setting>
{
  DatabaseReference dr = FirebaseDatabase.instance.reference().child("realtime");
  Messages recievedMessages;
  TextEditingController _thresholdController=new TextEditingController();
  int status=0;
  setData(String k, int v) {
    print("reaching");
    dr.update({k: v});
  }
   setLang(String k, String v) {
    print("reaching");
    dr.update({k: v});
  }
  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      dr.onValue.listen((Event event) {
      var data = event.snapshot.value;
      recievedMessages = new Messages(
          status: data['status'],
          moisture: data['moisture'],
          downThreshold: data['downThreshold'],
          upThreshold: data['upThreshold'],
          tankHeight:data['tankHeight'],
          language: data['language']);
      setState(() {
        print("settings");
      });
    });
    }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
       appBar: AppBar(
        elevation: 2.0,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(recievedMessages.language=="English"?"Settings":recievedMessages.language=="हिंदी"?"सेटिंग्स":"அமைப்புகள்", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 30.0)),
       ),
       body: new ListView(
          children: <Widget>[
            new Material(
              elevation: 4.0,
              child: new ListTile(
               
               title: new Text(recievedMessages.language=="English"?"Threshold Upper Limit":recievedMessages.language=="हिंदी"?"ऊपरी सीमा":"மேல் எல்லை"),
               subtitle: new Text((recievedMessages.language=="English"?"Current Threshold:":recievedMessages.language=="हिंदी"?"वर्तमान सीमा:":"தற்போதைய வரம்பு:")+recievedMessages.upThreshold.toString()),
               trailing: new FlatButton(
                 child: new Text(recievedMessages.language=="English"?"CHANGE":recievedMessages.language=="हिंदी"?"परिवर्तन":"மாற்றம்"),
                 color: Colors.blue,
                 shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(24.0)),
                 onPressed: () {setThresold(); status=1;},),
            ),
            ),
            new Material(
              elevation: 4.0,
              child: new ListTile(
               
               title: new Text(recievedMessages.language=="English"?"Threshold Lower Limit":recievedMessages.language=="हिंदी"?"निचली सीमा":"கீழ் எல்லை"),
               subtitle: new Text((recievedMessages.language=="English"?"Current Threshold:":recievedMessages.language=="हिंदी"?"वर्तमान सीमा:":"தற்போதைய வரம்பு:")+recievedMessages.downThreshold.toString()),
               trailing: new FlatButton(
                 child: new Text(recievedMessages.language=="English"?"CHANGE":recievedMessages.language=="हिंदी"?"परिवर्तन":"மாற்றம்"),
                 color: Colors.blue,
                 shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(24.0)),
                 onPressed: () {setThresold(); status=2;},),
            ),
            ),
            new Material(
              elevation: 4.0,
              child: new ListTile(
               
               title: new Text(recievedMessages.language=="English"?"Water Tank Height(cm)":recievedMessages.language=="हिंदी"?"निचली सीमा":"கீழ் எல்லை"),
               subtitle: new Text((recievedMessages.language=="English"?"Current Height:":recievedMessages.language=="हिंदी"?"वर्तमान सीमा:":"தற்போதைய வரம்பு:")+recievedMessages.tankHeight.toString()),
               trailing: new FlatButton(
                 child: new Text(recievedMessages.language=="English"?"CHANGE":recievedMessages.language=="हिंदी"?"परिवर्तन":"மாற்றம்"),
                 color: Colors.blue,
                 shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(24.0)),
                 onPressed: () {setThresold(); status=3;},),
            ),
            ),
            new Material(
              elevation: 4.0,
              child: new ListTile(
               
               title: new Text("Language/மொழி/भाषा"),
               subtitle: new Text((recievedMessages.language=="English"?"Current Language: ":recievedMessages.language=="हिंदी"?"वर्तमान भाषा: ":"தற்போதைய மொழி: ")+recievedMessages.language.toString()),
               trailing: new FlatButton(
                 child: new Text(recievedMessages.language=="English"?"CHANGE":recievedMessages.language=="हिंदी"?"परिवर्तन":"மாற்றம்"),
                 color: Colors.blue,
                 shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(24.0)),
                 onPressed:()=>setLanguage(),
            ),
            ),),
         ],
       ),
    );
  }
  Future<Null> setThresold() async{
      return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return AlertDialog(
            actions: <Widget>[
              new FlatButton(
                 child: new Text("Submit"), onPressed: () {
                   if(status==1)
                    setData("upThreshold", int.parse(_thresholdController.text));
                   else if(status==2)
                   setData("downThreshold", int.parse(_thresholdController.text));
                   else if(status==3)
                   setData("tankHeight", int.parse(_thresholdController.text));
                   status=0;
                   Navigator.of(context).pop();
                   _thresholdController.clear();
                 },
              )
            ],
            title:new Text("Set the value:"),
            content: new SingleChildScrollView(
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    controller: _thresholdController,
                    maxLines: 1,
                     decoration: new InputDecoration(
                      // border: InputBorder.none,
                       hintText: "Enter the threshold value"
                       
                     ),
                  )
                ],
              ),
            ),
            );
        }

      );
  }
  Future<Null> setLanguage() async{
      return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return AlertDialog(
            contentPadding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
            title:new Text("Select the language:"),
            content: new SingleChildScrollView(
              child: new Column(
              children: <Widget>[
            new Material(
              elevation: 10.0,
              //color: Colors.blue,
              child: new ListTile(
               title: new Text("English"),
               subtitle: new Text("Click to Select"),
               onTap:(){
                 setLang("language", "English");
                 Navigator.of(context).pop();
                 },
            ),
            ),
            new Material(
              //color: Colors.blue,
              elevation: 10.0,
              child: new ListTile(
               title: new Text("தமிழ்"),
               subtitle: new Text("Click to Select"),
               onTap:(){
                 setLang("language", "தமிழ்");
                 Navigator.of(context).pop();
                 },
            ),
            ),
            new Material(
              elevation: 10.0,
              //color: Colors.blue,
              child: new ListTile(
               title: new Text("हिंदी"),
               subtitle: new Text("Click to Select"),
               onTap:(){
                 setLang("language", "हिंदी");
                 Navigator.of(context).pop();
                 },
            ),
            ),
                ],
              ),
            ),
            );
        }

      );
  }
}