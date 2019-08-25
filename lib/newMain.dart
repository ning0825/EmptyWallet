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

  var cards = [oweCard(), loanCard()];

  AnimationController _animationController;
  AnimationController _animationController2;
  Animation<double> showAnimation;
  Animation<double> hideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    showAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    showAnimation.addListener(() {
      setState(() {});
    });

    _animationController2 =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    hideAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController2);
    hideAnimation.addListener(() {
      setState(() {});
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
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Colors.white),
              margin: EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 40, top: 30),
                    child: Text(
                      'Cards',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    height: 300,
                    child: PageView.builder(
                        itemBuilder: (BuildContext context, int position) {
                          if (position == currentPage) {
                            return cards[position];
                          } else {
                            return Transform.scale(
                              scale: 1 - (currentPage - position).abs() * 0.1,
                              child: cards[position],
                            );
                          }
                        },
                        itemCount: 2,
                        physics: BouncingScrollPhysics(),
                        controller: _controller,
                        onPageChanged: (index) {
                          developer.log('animation exec');
                          if (index == 0) {
                            _animationController.forward(from: 0.0);
                            _animationController2.reverse(from: 1.0);
                          } else if (index == 1) {
                            _animationController2.forward(from: 0.0);
                            _animationController.reverse(from: 1.0);
                          }
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 40, top: 10, bottom: 10),
                    child: Text(
                      'Transactions',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: currentPage == 0
                        ? FadeTransition(
                            child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return listTileWidget(index);
                                },
                                itemCount: 10),
                            opacity: showAnimation,
                          )
                        : FadeTransition(
                            child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return ListTile(title: Text('$index'),);
                                },
                                itemCount: 10),
                            opacity: hideAnimation,
                          ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  void changeListOpacity(index) {
    _animationController.forward();
  }

  Widget listTileWidget(int index) {
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

  static Widget oweCard() {
    return Padding(
      padding: EdgeInsets.only(top: 40, bottom: 40),
      child: Container(
        padding: EdgeInsets.all(40),
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 0, blurRadius: 30, color: Colors.grey[400])
            ],
            image: DecorationImage(
                image: AssetImage('assets/CardBG.webp'), fit: BoxFit.fill)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '本月需还:',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              '已       还:',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              '未       还:',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  static Widget loanCard() {
    return Padding(
      padding: EdgeInsets.only(top: 40, bottom: 40),
      child: Container(
        padding: EdgeInsets.all(40),
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 0, blurRadius: 12, color: Colors.grey[400])
            ],
            image: DecorationImage(
                image: AssetImage('assets/CardBG.webp'), fit: BoxFit.fill)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '本月需借:',
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
      ),
    );
  }
}
