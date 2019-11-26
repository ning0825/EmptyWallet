import 'dart:core';
import 'dart:core' as prefix0;

import 'package:empty_wallet/tool/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

//=======================================================================================================
//CusToolbar
//=======================================================================================================
//Custom Toolbar
class CusToolbar extends StatelessWidget {
  final String title;
  final IconData leftIcon;
  final Function leftOnPress;
  final IconData rightIcon;
  final GlobalKey rightIconKey;
  final Function rightOnPress;

  CusToolbar(
      {@required this.title,
      this.leftIcon,
      this.leftOnPress,
      this.rightIcon,
      this.rightIconKey,
      this.rightOnPress})
      : super() {
    assert(title != null);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              leftIcon,
              color: Colors.white,
            ),
            onPressed: leftOnPress,
          ),
          Expanded(
              child: Text(
            this.title,
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )),
          IconButton(
            key: rightIconKey,
            icon: Icon(
              rightIcon,
              color: Colors.white,
            ),
            onPressed: rightOnPress,
          ),
        ],
      ),
    );
  }
}

//=======================================================================================================
//BaseCard
//=======================================================================================================

//Cards in main UI.
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

//=======================================================================================================
//CusTextField
//=======================================================================================================

class CusTextField extends StatelessWidget {
  final String title;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator validator;
  final String hintText;
  final TextInputType keyboardType;
  final bool enable;
  final TextEditingController controller;

  CusTextField(
      {this.title,
      this.onSaved,
      this.validator,
      this.hintText,
      this.keyboardType,
      this.enable,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[350]),
            ),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              fillColor: Colors.grey[800],
              filled: true,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(),
              // focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3)),
              labelStyle: TextStyle(color: Colors.black),
            ),
            cursorColor: Colors.black,
            keyboardType: keyboardType,
            onSaved: onSaved,
            validator: validator,
            enabled: enable,
          ),
        ],
      ),
    );
  }
}

//=======================================================================================================
//CusAnimScaleButton
//=======================================================================================================
class AnimScaleButton extends StatefulWidget {
  final Widget child;
  final GestureTapCallback onTap;

  AnimScaleButton({@required this.child, this.onTap});

  @override
  _AnimScaleButtonState createState() => _AnimScaleButtonState();
}

class _AnimScaleButtonState extends State<AnimScaleButton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: Duration(milliseconds: 5000), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d)=>_controller.forward(from: 0.0),
      onTapUp: (d)=>_controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (_, child) {
          return Transform.scale(
            scale: 1 - (_controller.value * 0.5),
            child: child,
          );
        },
      ),
    );
  }
}

//=======================================================================================================
//CusDatePicker
//=======================================================================================================

typedef OnRetureDate = void Function(DateTime dateTime);

class CusDatePicker extends StatefulWidget {
  final DateTime firstMonth;
  final DateTime lastMonth;
  final DateTime initDay;

  final OnRetureDate onRetureDate;

  final String selectedDate = '';

  final DateTime titleDate = DateTime.now();

  final GlobalKey key;

  CusDatePicker(
      {this.key,
      this.firstMonth,
      this.lastMonth,
      this.initDay,
      this.onRetureDate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => CusDatePickerState();
}

class CusDatePickerState extends State<CusDatePicker>
    with TickerProviderStateMixin {
  Color backgroundColor = Colors.blue[900];
  Color tileColor = Colors.blue[800];

  GlobalKey childKey = GlobalKey();

  AnimationController controller;
  AnimationController controller1;

  AnimationController oController;
  AnimationController oController1;
  double _opacity = 1.0;
  double _opacity1 = 0.0;

  Tween<Offset> mainTween;
  Tween<Offset> secTween;

  bool isSwipeLeft = true;

  DateTime s0;
  DateTime s1;

  int transDura = 400;
  int opaDura = 250;

  DateTime selectedDate;

  bool isVisible0 = true;
  bool isVisible1 = false;

  List<DateTime> months;

  @override
  void initState() {
    super.initState();

    months = getMonths(widget.firstMonth, widget.lastMonth);

    s0 = months[0];
    s1 = months[1];

    selectedDate = widget.initDay;

    controller = AnimationController(
        duration: Duration(milliseconds: transDura), vsync: this);
    controller1 = AnimationController(
        duration: Duration(milliseconds: transDura), vsync: this);

    oController = AnimationController(
        duration: Duration(milliseconds: opaDura), vsync: this);
    oController1 = AnimationController(
        duration: Duration(milliseconds: opaDura), vsync: this);

    mainTween = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.5, 0.0));
    secTween = Tween<Offset>(begin: Offset(0.5, 0.0), end: Offset(0.0, 0.0));

    oController.addListener(() {
      setState(() {
        _opacity = oController.value;
      });
    });
    oController1.addListener(() {
      setState(() {
        _opacity1 = oController1.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int daysThisMonth = dayInMonth(2019, 11);
    int oneWeek = DateTime(2019, 11, 1).weekday; //1234567
    print('oneWeek:' + oneWeek.toString());
    return _buildPages(daysThisMonth, oneWeek);
  }

  int stackIndex = 0;

  Widget _buildPages(int i, int n) {
    double startX;
    double endX;

    bool finishSwipe = true;

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: backgroundColor),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2 + 111,
      child: GestureDetector(
        onPanStart: (d) {
          if (d.localPosition.dx != null) {
            startX = d.localPosition.dx;
          }
        },
        onPanUpdate: (d) {
          if (d.localPosition.dx != null) {
            endX = d.localPosition.dx;

            if (endX - startX > 10 && finishSwipe && stackIndex != 0) {
              finishSwipe = false;

              if (_opacity1 == 0) {
                s1 = months[stackIndex - 1];
                stackIndex = stackIndex - 1;

                mainTween.begin = Offset(0.0, 0.0);
                mainTween.end = Offset(0.5, 0.0);
                controller.forward(from: 0.0);
                oController.reverse(from: 1.0).whenComplete(() {
                  isVisible0 = false;
                  isVisible1 = true;
                  setState(() {});
                }).whenComplete(() => oController1.forward(from: 0.0));

                secTween.begin = Offset(-0.5, 0.0);
                secTween.end = Offset(0.0, 0.0);
                controller1.forward(from: 0.0);
              }

              if (_opacity == 0) {
                s0 = months[stackIndex - 1];

                mainTween.begin = Offset(-0.5, 0.0);
                mainTween.end = Offset(0.0, 0.0);
                controller.forward(from: 0.0);

                secTween.begin = Offset(0.0, 0.0);
                secTween.end = Offset(0.5, 0.0);
                controller1.forward(from: 0.0);
                oController1.reverse(from: 1.0).whenComplete(() {
                  isVisible1 = false;
                  isVisible0 = true;
                  setState(() {});
                }).whenComplete(() => oController.forward(from: 0.0));

                stackIndex = stackIndex - 1;
              }
            }

            if (endX - startX < -10 &&
                finishSwipe &&
                stackIndex != months.length) {
              finishSwipe = false;

              if (_opacity1 == 0) {
                s1 = months[stackIndex + 1];
                stackIndex = stackIndex + 1;

                mainTween.begin = Offset(0.0, 0.0);
                mainTween.end = Offset(-0.5, 0.0);
                controller.forward(from: 0.0);
                oController.reverse(from: 1.0).whenComplete(() {
                  isVisible0 = false;
                  isVisible1 = true;
                  setState(() {});
                }).whenComplete(() => oController1.forward(from: 0.0));

                secTween.begin = Offset(0.5, 0.0);
                secTween.end = Offset(0.0, 0.0);
                controller1.forward(from: 0.0);
              }

              if (_opacity == 0) {
                s0 = months[stackIndex + 1];

                mainTween.begin = Offset(0.5, 0.0);
                mainTween.end = Offset(0.0, 0.0);
                controller.forward(from: 0.0);

                secTween.begin = Offset(0.0, 0.0);
                secTween.end = Offset(-0.5, 0.0);
                controller1.forward(from: 0.0);
                oController1.reverse(from: 1.0).whenComplete(() {
                  isVisible1 = false;
                  isVisible0 = true;
                  setState(() {});
                }).whenComplete(() => oController.forward(from: 0.0));

                stackIndex = stackIndex + 1;
              }
            }
          }
        },
        onPanEnd: (d) {
          if (stackIndex != 0 && stackIndex != months.length) {
            finishSwipe = true;
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 24, top: 24, right: 24),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Visibility(
                    visible: isVisible0,
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SlideTransition(
                            position: mainTween
                                .chain(CurveTween(curve: Curves.easeIn))
                                .animate(controller),
                            child: Opacity(
                              opacity: _opacity,
                              child: Text(
                                '${s0.year.toString() + '.' + s0.month.toString()}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: mainTween
                              .chain(CurveTween(curve: Curves.easeIn))
                              .animate(controller1),
                          child: Opacity(
                              opacity: _opacity,
                              child: Column(
                                children: <Widget>[
                                  _buildTitle(),
                                  _buildPageItem(dayInMonth(s0.year, s0.month),
                                      DateTime(s0.year, s0.month, 1).weekday),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: isVisible1,
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SlideTransition(
                            position: secTween
                                .chain(CurveTween(curve: Curves.easeIn))
                                .animate(controller),
                            child: Opacity(
                              opacity: _opacity1,
                              child: Text(
                                '${s1.year.toString() + '.' + s1.month.toString()}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: secTween
                              .chain(CurveTween(curve: Curves.easeIn))
                              .animate(controller1),
                          child: Opacity(
                              opacity: _opacity1,
                              child: Column(
                                children: <Widget>[
                                  _buildTitle(),
                                  _buildPageItem(dayInMonth(s1.year, s1.month),
                                      DateTime(s1.year, s1.month, 1).weekday),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: GestureDetector(
                  child: Container(
                    width: 120,
                    height: 50,
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blue),
                  ),
                  onTap: () => widget.onRetureDate(selectedDate),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  var weeks = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  Widget _buildTitle() {
    return Row(
      children: _buildWeeks(),
    );
  }

  List<Widget> _buildWeeks() {
    List<Widget> widgets = [];

    for (var i = 0; i < weeks.length; i++) {
      widgets.add(Expanded(
          child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 8),
        child: Text(
          weeks[i],
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[400]),
        ),
      )));
    }
    return widgets;
  }

  //days: 一个月多少天  initWeek：这个月第一天是星期几
  Widget _buildPageItem(int days, int initWeek) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            GridView.builder(
              shrinkWrap: true,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemCount: initWeek == 7 ? days : days + initWeek,
              itemBuilder: (_, index) {
                return Container(
                  margin: EdgeInsets.all(4.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: CircleAvatar(
                        child: _getGridText(index, initWeek),
                        backgroundColor: _getGridBG(index, initWeek)),
                    onTap: () {
                      if (initWeek != 7) {
                        selectedDate = DateTime(months[stackIndex].year,
                            months[stackIndex].month, index - initWeek + 1);
                      } else {
                        selectedDate = DateTime(months[stackIndex].year,
                            months[stackIndex].month, index + 1);
                      }
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ],
        ));
  }

  Widget _getGridText(int index, int initWeek) {
    if (initWeek == 7) {
      return Text('${index + 1}');
    } else {
      return Text(
          (index - initWeek + 1) > 0 ? (index - initWeek + 1).toString() : '');
    }
  }

  Color _getGridBG(int index, int initWeek) {
    if (initWeek == 7) {
      return DateTime(months[stackIndex].year, months[stackIndex].month,
                      index + 1)
                  .difference(selectedDate)
                  .inDays ==
              0
          ? (DateTime(months[stackIndex].year, months[stackIndex].month,
                      index + 1)
                  .isAfter(selectedDate)
              ? tileColor
              : Colors.yellow[300])
          : tileColor;
    } else {
      return (index - initWeek + 1) > 0
          ? (DateTime(months[stackIndex].year, months[stackIndex].month,
                          index - initWeek + 1)
                      .difference(selectedDate)
                      .inDays ==
                  0
              ? (DateTime(months[stackIndex].year, months[stackIndex].month,
                          index - initWeek + 1)
                      .isAfter(selectedDate)
                  ? tileColor
                  : Colors.yellow[300])
              : tileColor)
          : backgroundColor;
    }
  }

  List<DateTime> getMonths(DateTime firstDate, DateTime lastDate) {
    List<DateTime> ms = [];

    DateTime iDateTime = firstDate;

    while (true) {
      ms.add(iDateTime);
      iDateTime = iDateTime
          .add(Duration(days: dayInMonth(iDateTime.year, iDateTime.month)));

      if (iDateTime.difference(lastDate).inDays == 0) {
        break;
      }
    }

    return ms;
  }
}
