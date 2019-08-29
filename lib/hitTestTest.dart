import 'package:flutter/material.dart';

class HitTestTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: HitTestHome(),
    );
  }
}

class HitTestHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HitTestState();
}

class HitTestState extends State<HitTestHome> {
  PointerEvent _event;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Listener(
          child: Container(
            child: Container(
              width: 300.0,
              padding: EdgeInsets.symmetric(horizontal: 20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              height: 150.0,
              color: Colors.blue,
              child: Text(_event.toString() ?? '', textAlign: TextAlign.start),
            ),
            width: double.maxFinite,
            height: double.maxFinite,
            alignment: Alignment.center,
          ),
          onPointerMove: (PointerEvent e) => setState(() => _event = e)),
    );
  }
}
