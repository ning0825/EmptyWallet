import 'package:bloc/bloc.dart';
import 'package:empty_wallet/bloc/bloc_human.dart';
import 'package:empty_wallet/bloc/bloc_month.dart';
import 'package:empty_wallet/bloc/bloc_subplatform.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/routes/add_human_loan_route.dart';
import 'package:empty_wallet/routes/human_detail_route.dart';
import 'package:empty_wallet/routes/platform_detail_route.dart';
import 'package:empty_wallet/ui/bottom_drag.dart';
import 'package:empty_wallet/ui/custom_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc_delegate.dart';
import 'routes/add_platfom_route.dart';
import 'ui/data_curve.dart';

//提供一个context给platform_detail_route界面获取bloc用
BuildContext mContext;
//
//List<double> dataArray = [];
//List<String> monthArray = [];

void main() {
  //Bloc事件回调
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(NewApp());
}

class NewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider<SubPlatformBloc>(
        builder: (_) => SubPlatformBloc(),
        child: BlocProvider<HumanBloc>(
          builder: (_) => HumanBloc(),
          child: BlocProvider<MonthBloc>(
            builder: (_) => MonthBloc(),
            child: NewHome(),
          ),
        ),
      ),
      routes: <String, WidgetBuilder>{
        '/edit ': (BuildContext context) => AddPlatformRoute(),
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
  //当前月的subPlatform列表
  List<SubPlatform> subPlatforms = List();

//Human load list.
  List<HumanLoan> humanLoans = List();

  var cards;

  var currentPage = 0.0;
  var currentCardPosition = 0;

  AnimationController _animationController;
  Animation<double> showAnimation;

  GlobalKey key = GlobalKey();

  GlobalKey flKey = GlobalKey();

  var _controller = PageController(viewportFraction: 0.85);

  var oweTotal = 0.0;
  var owePaid = 0.0;
  var oweRemain = 0.0;

  @override
  void initState() {
    super.initState();

    openDB().whenComplete(() {
      BlocProvider.of<HumanBloc>(context)
          .add(HumanEvent(methodId: HumanEvent.SHOW_HUMAN_LOAN));
      BlocProvider.of<SubPlatformBloc>(context)
          .add(SubPlatformEvent(eventId: SubPlatformEvent.SHOW_SUBPLATFORMS));
      BlocProvider.of<MonthBloc>(context).add(MonthEvent.UPDATE_MONTH);
    });

    mContext = context;

    //列表逐渐显示的动画
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 780));
    showAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
              padding:
                  EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
              child: SafeArea(
                child: CusToolbar(
                  title: '-bank',
                  leftIcon: Icons.menu,
                  leftOnPress: () => {},
                ),
              )),
          Expanded(
            child: MockBottomDrag(
              bl: BlocBuilder<MonthBloc, MonthArgs>(builder: (context, s) {
                return DataCurveWidget(s.dataList, s.monthList);
              }),
              fl: Container(
                key: flKey,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: SingleChildScrollView(
                  child: getCardAndList(),
                ),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget getCardAndList() {
    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page;
      });
    });

    return Center(child: BlocBuilder<SubPlatformBloc, List<SubPlatform>>(
      builder: (context, s) {
        subPlatforms = s;
        return BlocBuilder<HumanBloc, List<HumanLoan>>(
          builder: (context, s) {
            humanLoans = s;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  height: 60,
                  child: Image.asset('assets/line.png'),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40, right: 40),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Cards',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  height: 300,
                  child: PageView.builder(
                      itemBuilder: (BuildContext context, int position) {
                        cards = [oweCard(), loanCard()];
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
                        setState(() {});
                        _animationController.forward(from: 0.0);
                      }
                      ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 40, top: 10, bottom: 10, right: 40),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Transactions',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (currentCardPosition == 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddPlatformRoute()));
                          } else if (currentCardPosition == 1) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddHumanLoanRoute()));
                          }
                        },
                      )
                    ],
                  ),
                ),
                getCurrentList(currentCardPosition)
              ],
            );
          },
        );
      },
    ));
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
            itemCount: humanLoans.length),
        opacity: showAnimation,
      );
    }
    return Text('index != neither 0 nor 1 ');
  }

//列表【0】Item
  Widget oweTileWidget(int index) {
    return Padding(
      padding: EdgeInsets.only(left: 40, top: 10, bottom: 10, right: 30),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => go2Detail(subPlatforms[index].platformKey),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
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
                    child: Text(subPlatforms[index].dateThisStage ?? 'N/A'),
                  )
                ],
              ),
            ),
            Expanded(
              child: Text(subPlatforms[index].numThisStage.toString()),
            ),
            IconButton(
              icon: Icon(
                Icons.confirmation_number,
                size: 30,
                color: subPlatforms[index].isPaidOff == 0 ? Colors.redAccent : Colors.greenAccent,
              ),
              onPressed: (){
                BlocProvider.of<SubPlatformBloc>(context)
                    .add(SubPlatformEvent(eventId: SubPlatformEvent.CHANGE_PAY_STATE, data: subPlatforms[index]));

              },
              padding: EdgeInsets.all(2),
            )
          ],
        ),
      ),
    );
  }

//列表【1】Item
  Widget loanTileWidget(int index) {
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
                    humanLoans[index].hName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(humanLoans[index].hTotal.toString()),
                  )
                ],
              ),
              behavior: HitTestBehavior.opaque,
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HumanDetailRoute(humanLoans[index])))
              },
            ),
          ),
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

//卡片【0】
  Widget oweCard() {
    oweTotal = 0.0;
    owePaid = 0.0;
    oweRemain = 0.0;
    for (var o in subPlatforms) {
      oweTotal += o.numThisStage;
      if(o.isPaidOff == 1) {
        owePaid += o.numThisStage;
      }
    }
    oweRemain = oweTotal - owePaid;

    return BaseCard(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Num you need paid this month',
          style: TextStyle(color: Colors.white),
        ),
        Container(height: 10),
        Text(
          '￥$oweRemain',
          style: TextStyle(color: Colors.white, fontSize: 50),
        ),
        Text('total: ' + oweTotal.toString(),style: TextStyle(color: Colors.white),),
        Text('paid: ' + owePaid.toString(),style: TextStyle(color: Colors.white),)
      ],
    ));
  }

//卡片【1】
  Widget loanCard() {
    var loanTotal = 0.0;
    for (var o in humanLoans) {
      loanTotal += o.hTotal;
    }

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Total loan num',
            style: TextStyle(color: Colors.white),
          ),
          Container(height: 10),
          Text(
            '￥$loanTotal',
            style: TextStyle(color: Colors.white, fontSize: 50),
          )
        ],
      ),
    );
  }

//点击进入详情界面
  Future<void> go2Detail(String name) async {
    Platform pf = await getPlatformByName(name);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PlatformDetailRoute(pf)));
  }

//  PopupMenuButton _popupMenuButton() {
//    return PopupMenuButton(
//      itemBuilder: (context) => <PopupMenuEntry>[
//        PopupMenuItem(
//          child: GestureDetector(
//            child: Text('add owe'),
//            onTap: () => Navigator.of(context)
//              ..pop() //隐藏popupMenu
//              ..push(MaterialPageRoute(builder: (context) => AddPlatformRoute())),
//          ),
//        )
//      ],
//    );
//  }
}
