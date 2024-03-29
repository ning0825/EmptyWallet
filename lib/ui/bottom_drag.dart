import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Widget backLayer;
Widget frontLayer;
double flHeight;

class MockBottomDrag extends StatelessWidget {
  MockBottomDrag({bl, fl}) {
    backLayer = bl;
    frontLayer = fl;
  }

  @override
  Widget build(BuildContext context) {
    return DragContainer();
  }
}

class DragContainer extends StatefulWidget {
  @override
  _DragContainerState createState() => _DragContainerState();
}

class _DragContainerState extends State<DragContainer>
    with TickerProviderStateMixin {
  double topDis = 0.0;
  double currentDis;
  double bottomDis;

  AnimationController _downAnimController;
  CurvedAnimation animation;

  AnimationController _upAnimController;
  CurvedAnimation animation22;

  bool isEdge = false;
  bool isExpanded = true;

  Curve curveType;
  //上拉和下滑的动画时长
  Duration dur;

  @override
  void initState() {
    super.initState();

    curveType = Curves.easeOut;
    dur = Duration(milliseconds: 250);

    WidgetsBinding.instance
        .addPostFrameCallback((d) => bottomDis = context.size.height - 50);

    //下滑动画
    _downAnimController =
        AnimationController(vsync: this, duration: dur);
    animation = CurvedAnimation(parent: _downAnimController, curve: curveType);
    animation.addListener(() {
      topDis = currentDis + (bottomDis - currentDis).abs() * animation.value;
      setState(() {});
    });

    //上拉动画
    _upAnimController =
        AnimationController(vsync: this, duration: dur);
    animation22 =
        CurvedAnimation(parent: _upAnimController, curve: curveType);
    animation22.addListener(() {
      topDis = currentDis - currentDis * animation22.value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    //DragContainer高度，下拉达到三分之一高度时执行下拉动画
    flHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          child: Visibility(child: backLayer, visible: topDis > 0.0,),
        ),
        Positioned(
          top: topDis,
          bottom: 0,
          left: 0,
          right: 0,
          child: NotificationListener<ScrollEndNotification>(
            child: NotificationListener<OverscrollNotification>(
              child: Container(
                child: RawGestureDetector(
                  gestures: {MyVerticalDragRecognizer: getGestureRecognizer()},
                  child: frontLayer,
                ),
              ),
              onNotification: (d) {
                //下拉拖动
                if (d.dragDetails != null && d.dragDetails.delta.dy > 0.0) {
                  isEdge = true;
                  topDis = topDis + d.dragDetails.delta.dy;
                  setState(() {});
                }
                return false;
              },
            ),
            onNotification: (s) {
              //是否滑动到顶部的判断，因为在滑动Cards时也会触发这个notification
              //下拉动画
              if (isEdge) {
                currentDis = topDis;
                if (topDis > flHeight / 5) {
                  _downAnimController.forward(from: 0.0);
                  isEdge = false;
                  isExpanded = false;
                } else {
                  _upAnimController.forward(from: 0.0);
                  isEdge = false;
                  isExpanded = true;
                }
              }
              return false;
            },
          ),
        ),
        Positioned(
          top: topDis,
          height: 300,
          left: 0,
          right: 0,
          child: Offstage(
            child: GestureDetector(
              child: Container(
                color: Colors.transparent,
                height: 200,
              ),
              onVerticalDragUpdate: (d) {
                topDis = topDis + d.delta.dy;
                setState(() {});
              },
              onVerticalDragEnd: (d) {
                currentDis = topDis;
                _upAnimController.forward(from: 0.0);
                isExpanded = true;
              },
            ),
            offstage: isExpanded,
          ),
        )
      ],
    );
  }

  GestureRecognizerFactoryWithHandlers<MyVerticalDragRecognizer>
      getGestureRecognizer() {
    return GestureRecognizerFactoryWithHandlers(
        () => MyVerticalDragRecognizer(), this._initializer);
  }

  void _initializer(MyVerticalDragRecognizer instance) {
    instance
      ..onStart = _handleStart
      ..onUpdate = _handleUpdate
      ..onEnd = _handleEnd;
  }

  void _handleStart(DragStartDetails dsd) {}

  void _handleUpdate(DragUpdateDetails dud) {
    if (dud.delta.dy > 0) {
      topDis = topDis + dud.delta.dy;
      setState(() {});
    }
  }

  void _handleEnd(DragEndDetails ded) {
    if (topDis > flHeight / 5) {
      currentDis = topDis;
      _downAnimController.forward(from: 0.0);
      isExpanded = false;
    } else {
      currentDis = topDis;
      _upAnimController.forward(from: 0.0);
      isExpanded = true;
    }
  }
}

class MyVerticalDragRecognizer extends VerticalDragGestureRecognizer {
  MyVerticalDragRecognizer({Object debugOwner}) : super(debugOwner: debugOwner);
}
