import 'dart:io';
import 'dart:ui' as prefix0;
import 'dart:developer' as developer;
import 'package:flutter/rendering.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(NewApp());

class NewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    // TODO: implement build
    return MaterialApp(
      home: NewHome(),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
    );
  }
}

class NewHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NewHomeState();
}

class NewHomeState extends State<NewHome> with TickerProviderStateMixin {
  var currentPage = 0.0;
  var currentCardPosition = 0;

  var cards = [oweCard(), loanCard()];

  AnimationController _animationController;
  Animation<double> showAnimation;

  //拖动相关
  double _topDis = 0.0;
  double _bottomDis = 800;
  double _currentDis;
  bool isExpanded = true;
  double startY;
  double endY;
  bool isEdge = false;

  AnimationController _toBottomController;
  AnimationController _toTopController;
  CurvedAnimation _curvedAnimation;
  CurvedAnimation _curvedAnimation2;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 780));
    showAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    showAnimation.addListener(() {
      setState(() {});
    });
    _animationController.forward(from: 0.0);

    //controller1: 下划动画
    _toBottomController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 400));
    _curvedAnimation =
        new CurvedAnimation(parent: _toBottomController, curve: Curves.easeOut);
    _curvedAnimation.addListener(() {
      setState(() {
        _topDis =
            _currentDis + (500 - _currentDis).abs() * _curvedAnimation.value;
      });
    });

    //上划动画
    _toTopController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 400));
    _curvedAnimation2 =
        new CurvedAnimation(parent: _toTopController, curve: Curves.easeOut);
    _curvedAnimation2.addListener(() {
      setState(() {
        _topDis =
            _currentDis - (0.0 - _currentDis).abs() * _curvedAnimation2.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var _controller = PageController(viewportFraction: 0.85);
    _controller.addListener(() {
      setState(() {
        //todo set opacity animation
        currentPage = _controller.page;
      });
    });

    // TODO: implement build
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
              padding:
                  EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
              child: SafeArea(
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      onPressed: () => {},
                    ),
                    Expanded(
                        child: Text(
                      '-bank',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    )),
                    IconButton(
                      icon: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                      onPressed: () => {},
                    )
                  ],
                ),
              )),
          Expanded(
              child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: <Widget>[
              Positioned(
                child: Text(
                  'this is back layer',
                  style: TextStyle(color: Colors.white, fontSize: 50),
                ),
              ),
              Positioned(
                top: _topDis,
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40)),
                        color: Colors.white),
                    width: double.maxFinite,
                    child: NotificationListener<ScrollEndNotification> (
                      child: NotificationListener<OverscrollNotification>(
                        child: Theme(
                          data: ThemeData(splashColor: Colors.red),
                          child: SingleChildScrollView(controller: ScrollController(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: double.maxFinite,
                                    child: Image.asset('assets/line.png'),
                                  ),
                                  behavior: HitTestBehavior.opaque,
                                  onVerticalDragStart: (e) {
                                    startY = 0.0;
                                    startY = e.globalPosition.dy;
                                  },
                                  onVerticalDragUpdate: (e) {
                                    endY = e.globalPosition.dy;
                                    if(isExpanded) {
                                      setState(() {
                                        _topDis += e.delta.dy;
                                      });
                                    }
                                  },
                                  onVerticalDragEnd: (e) {
                                    //解决点击时被识别为拖动
                                    if (-(endY - startY) > 20) {
                                      _currentDis = _topDis;
                                      _toTopController.forward(from: 0.0);
                                      isExpanded = !isExpanded;
                                    }
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 40, top: 0),
                                  child: Text(
                                    'Cards',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 24),
                                  ),
                                ),
                                Container(
                                  width: double.maxFinite,
                                  height: 300,
                                  child: PageView.builder(
                                      itemBuilder:
                                          (BuildContext context, int position) {
                                        if (position == currentPage) {
                                          return cards[position];
                                        } else {
                                          return Transform.scale(
                                            scale: 1 -
                                                (currentPage - position).abs() *
                                                    0.1,
                                            child: cards[position],
                                          );
                                        }
                                      },
                                      itemCount: 2,
                                      physics: BouncingScrollPhysics(),
                                      controller: _controller,
                                      onPageChanged: (index) {
                                        currentCardPosition = index;
                                        _animationController.forward(from: 0.0);
                                      }),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 40, top: 10, bottom: 10),
                                  child: Text(
                                    'Transactions',
                                    style: TextStyle(
                                        fontSize: 28, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                getCurrentList(currentCardPosition),
                              ],
                            ),
                          ),
                        ),
                        onNotification: (OverscrollNotification notification) {
                          isEdge = true;
                          if(isExpanded) {
                            setState(() {
                              _topDis += notification.dragDetails.delta.dy;
                            });
                          }
                          return false;
                        },
                      ),
                      onNotification: (ScrollEndNotification notification) {
                        developer.log('SCROLL END');
                        double currentExtent = notification.metrics.pixels;
                        double maxExtent = notification.metrics.maxScrollExtent;
                        if(isExpanded && isEdge && ((maxExtent - currentExtent)> 200)) {
                          _currentDis = _topDis;
                          _toBottomController.forward(from: 0.0);
                          isExpanded = false;
                          isEdge = false;
                        }
                        return false;
                      },
                    )
                  ),
                  onVerticalDragStart: (e) {
                    startY = 0.0;
                    startY = e.globalPosition.dy;
                    developer.log('vertical drag START');
                  },
                  onVerticalDragUpdate: (e) {
                    endY = e.globalPosition.dy;
                    setState(() {
                      _topDis += e.delta.dy;
                    });
                  },
                  onVerticalDragEnd: (e) {
                    //解决点击时被识别为拖动
                    developer.log('vertical drag END');
                    if (-(endY - startY) > 20) {
                      _currentDis = _topDis;
                      _toBottomController.forward(from: 0.0);
                      isExpanded = !isExpanded;
                    }
                  }
                ),
              ),
            ],
          ))
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget getCurrentList(int index) {
    if (index == 0) {
      return FadeTransition(
        child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return oweTileWidget(index);
            },
            itemCount: 10),
        opacity: showAnimation,
      );
    } else if (index != 0) {
      return FadeTransition(
        child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return loanTileWidget(index);
            },
            itemCount: 10),
        opacity: showAnimation,
      );
    }
    return Text('index != neither 0 nor 1 ');
  }

  Widget oweTileWidget(int index) {
    return Padding(
      padding: EdgeInsets.only(left: 40, top: 10, bottom: 10, right: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '分期乐',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('09-11'),
              )
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(
              Icons.all_inclusive,
              size: 30,
            ),
            onPressed: null,
            padding: EdgeInsets.all(2),
          )
        ],
      ),
    );
  }

  Widget loanTileWidget(int index) {
    return Padding(
      padding: EdgeInsets.only(left: 40, top: 10, bottom: 10, right: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '信用卡',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('10-04'),
              )
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(
              Icons.insert_emoticon,
              size: 30,
            ),
            onPressed: null,
            padding: EdgeInsets.all(2),
          )
        ],
      ),
    );
  }

  static Widget oweCard() {
    return BaseCard(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '噫噫噫:',
          style: TextStyle(color: Colors.white),
        ),
        Text(
          '￥2,300',
          style: TextStyle(color: Colors.white, fontSize: 50),
        ),
      ],
    ));
  }

  static Widget loanCard() {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '噫噫噫:',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            '已       借:',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            '未       借:',
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}

//两张卡片只有child不同，故封装。
class BaseCard extends Container {
  final Widget child;

  BaseCard({this.child})
      : super(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      spreadRadius: 0, blurRadius: 12, color: Colors.grey[400])
                ],
                image: DecorationImage(
                    image: AssetImage('assets/CardBG.webp'), fit: BoxFit.fill)),
            padding: EdgeInsets.all(40),
            width: 300,
            margin: EdgeInsets.only(top: 20, left: 2, right: 2, bottom: 20),
            height: 280);
}
