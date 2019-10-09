import 'dart:developer' as developer;

import 'package:empty_wallet/db/Item.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/routes/platformDetailRoute.dart';
import 'package:empty_wallet/ui/cus_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'routes/editItemRoute.dart';

void main() => runApp(NewApp());

class NewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;

    openDB();

    //程序第一次运行时在monthTable中插入36个月，最长贷款应该就是36月了
    return MaterialApp(
      home: NewHome(),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      routes: <String, WidgetBuilder>{
        '/edit': (BuildContext context) => EditItemRoute(),
      },
    );
  }
}

class NewHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewHomeState();
  }
}

class NewHomeState extends State<NewHome> with TickerProviderStateMixin {
  var currentPage = 0.0;
  var currentCardPosition = 0;

  var cards = [oweCard(), loanCard()];

  AnimationController _animationController;
  Animation<double> showAnimation;

  GlobalKey key = GlobalKey();

  //拖动相关
  double _topDis = 0.0;
  double _bottomDis = 600;
  double _currentDis;
  bool isExpanded = true;
  double startY;
  double endY;
  bool isEdge = false;

  AnimationController _toBottomController;
  AnimationController _toTopController;
  CurvedAnimation _curvedAnimation;
  CurvedAnimation _curvedAnimation2;

  var _controller = PageController(viewportFraction: 0.85);

  List<SubPlatform> subPlatforms = List();

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
        _topDis = _currentDis +
            (_bottomDis - _currentDis).abs() * _curvedAnimation.value;
      });
    });

    //上划动画
    _toTopController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 400));
    _curvedAnimation2 =
        new CurvedAnimation(parent: _toTopController, curve: Curves.easeOut);
    _curvedAnimation2.addListener(() {
      setState(() {
        _topDis = _currentDis - _currentDis.abs() * _curvedAnimation2.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getSubPlatforms(); //todo 写在build里会执行两次，写在initState里，从detail界面返回不能自动刷新
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
              padding:
                  EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
              child: SafeArea(
                  child: CusToolbar(
                title: '-bank',
                leftIcon: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () => {},
                ),
                rightIcon: IconButton(
                    key: key,
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      RenderBox renderBox =
                          key.currentContext.findRenderObject();
                      var offset = renderBox
                          .localToGlobal(Offset(0.0, renderBox.size.height));
                      var pop = _popupMenuButton();
                      showMenu(
                          context: context,
                          position:
                              RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
                          items: pop.itemBuilder(context));
                    }),
              ))),
          Expanded(
              child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: <Widget>[
              //back layer, show statistic data
              Positioned(
                  top: 2,
                  height: 500,
                  left: 0,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      child: GestureDetector(
                        child: CustomPaint(
                          size: Size(1000, 500),
                          painter: DataCurvePainter(),
                        ),
                        onTapDown: (TapDownDetails tdd) {
                          developer.log(tdd.globalPosition.dy.toString());
                        },
                      ))),
              //main layer
              Positioned(
                top: _topDis,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  child: SingleChildScrollView(
                    child: getCardAndList(),
                  ),
                ),
              ),
            ],
          ))
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  Future<void> getSubPlatforms() async {
    var nowTime = DateTime.now();
    var monthKey = nowTime.year.toString() + '.' + nowTime.month.toString();
    subPlatforms = await getSubPlatformByMonth(monthKey).whenComplete(() {
      setState(() {});
    });
  }

  Widget getCardAndList() {
    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page;
      });
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          child: Container(
            alignment: Alignment.center,
            width: double.maxFinite,
            height: 60,
            child: Image.asset('assets/line.png'),
          ),
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (e) {
            startY = 0.0;
            startY = e.globalPosition.dy;
          },
          onVerticalDragUpdate: (e) {
            endY = e.globalPosition.dy;
            if (!isExpanded) {
              setState(() {
                _topDis += e.delta.dy;
              });
            }
          },
          onVerticalDragEnd: (e) {
            //解决点击时被识别为拖动
            if (-(endY - startY) > 20 && !isExpanded) {
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                currentCardPosition = index;
                _animationController.forward(from: 0.0);
              }),
        ),
        Padding(
          padding: EdgeInsets.only(left: 40, top: 10, bottom: 10),
          child: Text(
            'Transactions',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: getCurrentList(currentCardPosition),
        )
      ],
    );
  }

  //显示是owe list 还是 Loan list
  Widget getCurrentList(int index) {
    if (index == 0) {
      return FadeTransition(
        child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return oweTileWidget(index);
            },
            itemCount: subPlatforms.length),
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
          Expanded(
            child: GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      subPlatforms[index].platformKey,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(subPlatforms[index].numThisStage.toString()),
                    )
                  ],
                ),
                onTap: () => go2Detail(subPlatforms[index].platformKey)),
          ),
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

  Future<void> go2Detail(String name) async {
    Platform pf = await getPf(name);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PlatformDetailRoute(pf)));
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

  PopupMenuButton _popupMenuButton() {
    return PopupMenuButton(
      itemBuilder: (context) => <PopupMenuEntry>[
        PopupMenuItem(
          child: GestureDetector(
            child: Text('add owe'),
            onTap: () => Navigator.of(context)
              ..pop()
              ..pushNamed('/edit'),
          ),
        )
      ],
    );
  }
}

class DataCurvePainter extends CustomPainter {
  var dataArray = [1890, 1200, 2000, 2700, 1000, 2300, 3200, 2400, 1500];
  var maxData = 0;
  List<double> timeArrayAxis = List(9); //X轴坐标
  List<double> dataArrayAxis = List(9); //Y轴坐标
  List<Offset> offsetArray = List(9); //坐标数组

  double dateHeight = 30.0; //空出显示日期的地方

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = Color.fromARGB(255, 255, 21, 119)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    var pxPerTime = size.width / 10;
    for (int i = 0; i < timeArrayAxis.length; i++) {
      timeArrayAxis[i] = pxPerTime * (i + 1);
    } //这里是X轴坐标

    for (int j = 0; j < dataArray.length; j++) {
      if (dataArray[j] > maxData) {
        maxData = dataArray[j];
      }
    } //找出最大数值，确定纵坐标高度

    var pxPerData = size.height / maxData;
    for (int m = 0; m < dataArray.length; m++) {
      dataArrayAxis[m] = size.height - dataArray[m] * pxPerData;
    } //这里是Y轴坐标

    for (int n = 0; n < timeArrayAxis.length; n++) {
      var os = Offset(timeArrayAxis[n], dataArrayAxis[n]);
      offsetArray[n] = os;
    } //这里是坐标数组

    Path curvePath = new Path();
    for (int q = 0; q < timeArrayAxis.length - 1; q++) {
      if (q == 0) {
        curvePath.moveTo(offsetArray[q].dx, offsetArray[q].dy);
      }
      curvePath.cubicTo(
          offsetArray[q].dx + 30,
          offsetArray[q].dy,
          offsetArray[q + 1].dx - 30,
          offsetArray[q + 1].dy,
          offsetArray[q + 1].dx,
          offsetArray[q + 1].dy);
    }

    //画个渐变矩形
    Offset offsetCenter = Offset(
        (offsetArray[0].dx + offsetArray[offsetArray.length - 1].dx) / 2,
        maxData * pxPerData / 2);
    var curveWidth = pxPerTime * 8;
    var curveHeight = offsetCenter.dy * 2;
    var rectToDraw = Rect.fromCenter(
        center: offsetCenter, width: curveWidth, height: curveHeight);
    var shadowPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = Color.fromARGB(255, 255, 21, 119)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    shadowPaint.shader = LinearGradient(
            colors: [Color.fromARGB(255, 255, 21, 119), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter)
        .createShader(rectToDraw);
    shadowPaint.style = PaintingStyle.fill;

    var path = Path()
      ..moveTo(offsetArray[8].dx, offsetArray[8].dy)
      ..lineTo(offsetArray[8].dx, size.height)
      ..lineTo(offsetArray[0].dx, size.height)
      ..lineTo(offsetArray[0].dx, offsetArray[0].dy);
    path.addPath(curvePath, Offset(0, 0));

    path.close();
    canvas.clipPath(path); //先clip，再draw

    canvas.drawRect(rectToDraw, shadowPaint);
    canvas.drawPath(curvePath, paint);

    //todo 画字不显示
    TextSpan span = TextSpan(
        text: 'test', style: TextStyle(fontSize: 50, color: Colors.blue));
    var textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.rtl);
    textPainter.layout(minWidth: 20, maxWidth: 100);
    textPainter.paint(canvas, new Offset(200, 10));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
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
