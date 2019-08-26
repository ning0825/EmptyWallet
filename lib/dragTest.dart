import 'package:flutter/material.dart';
import 'dart:developer';

void main() => runApp(DragApp());

class DragApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: DragHome(),
    );
  }
}

class DragHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DragState();
}

class DragState extends State<DragHome> with TickerProviderStateMixin {
  double _topDis = 200.0;
  double _bottomDis = 800;
  double _currentDis;
  bool isExpanded = true;
  double startY;

  AnimationController _controller;
  AnimationController _controller2;
  CurvedAnimation _curvedAnimation;
  CurvedAnimation _curvedAnimation2;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 400));
    _curvedAnimation =
        new CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _curvedAnimation.addListener(() {
      setState(() {
        _topDis =
            _currentDis + (800 - _currentDis).abs() * _curvedAnimation.value;
      });
    });

    _controller2 = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 400));
    _curvedAnimation2 =
        new CurvedAnimation(parent: _controller2, curve: Curves.easeOut);
    _curvedAnimation2.addListener(() {
      setState(() {
        _topDis =
            _currentDis - (200 - _currentDis).abs() * _curvedAnimation2.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: mainPage(),
    );
  }

  Widget mainPage() {
    return Scaffold(
        body: ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Column(
              children: <Widget>[
                Text(
                  'back',
                  style: TextStyle(fontSize: 100),
                ),
                Text(
                  'back',
                  style: TextStyle(fontSize: 100),
                ),
                Text(
                  'back',
                  style: TextStyle(fontSize: 100),
                ),
                Text(
                  'back',
                  style: TextStyle(fontSize: 100),
                ),
                Text(
                  'back',
                  style: TextStyle(fontSize: 100),
                ),
              ],
            ),
          ),
          Positioned(
            top: _topDis,
            child: GestureDetector(
              child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: Colors.green,
              ),
              onVerticalDragStart: (e) {
                startY = e.globalPosition.dy;
              },
              onVerticalDragUpdate: (e) {
                setState(() {
                  _topDis += e.delta.dy;
                });
              },
              onVerticalDragEnd: (e) {
//                if(e.globalPosition.dy;)
              },
            ),
          )
        ],
      ),
    ));
  }
}
