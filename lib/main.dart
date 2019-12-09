import 'package:bloc/bloc.dart';
import 'package:empty_wallet/bloc/bloc_human.dart';
import 'package:empty_wallet/bloc/bloc_month.dart';
import 'package:empty_wallet/bloc/bloc_platform.dart';
import 'package:empty_wallet/bloc/bloc_subplatform.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/routes/human_detail_route.dart';
import 'package:empty_wallet/routes/platform_detail_route.dart';
import 'package:empty_wallet/ui/bottom_drag.dart';
import 'package:empty_wallet/ui/custom_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'advan/localizations.dart';
import 'bloc/bloc_delegate.dart';
import 'routes/add_human_loan_route.dart';
import 'routes/add_platfom_route.dart';
import 'ui/data_curve.dart';

BuildContext mContext;

void main() {
  //Bloc事件回调
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(NewApp());
}

class NewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        const EwLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('en'), const Locale('zh')],
      home: BlocProvider<SubPlatformBloc>(
        builder: (_) => SubPlatformBloc(),
        child: BlocProvider<HumanBloc>(
          builder: (_) => HumanBloc(),
          child: BlocProvider<MonthBloc>(
            builder: (_) => MonthBloc(),
            child: BlocProvider<PfRemainBloc>(
                builder: (_) => PfRemainBloc(), child: NewHome()),
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
  var oweTotal = 0.0;
  var owePaid = 0.0;
  var oweRemain = 0.0;

  GlobalKey key = GlobalKey();
  GlobalKey flKey = GlobalKey();

  var _controller = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();

    mContext = context;

    _controller
        .addListener(() => setState(() => currentPage = _controller.page));

    openDB().whenComplete(() {
      BlocProvider.of<HumanBloc>(context)
          .add(HumanEvent(methodId: HumanEvent.SHOW_HUMAN_LOAN));
      BlocProvider.of<SubPlatformBloc>(context)
          .add(SubPlatformEvent(eventId: SubPlatformEvent.SHOW_SUBPLATFORMS));
      BlocProvider.of<MonthBloc>(context).add(MonthEvent.UPDATE_MONTH);
      BlocProvider.of<PfRemainBloc>(context).add(PfRemainEvent.SHOW_PF_REMAIN);
    });
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
                  title: EwLocalizations.of(context).title,
                  leftIcon: Icons.menu,
                  leftOnPress: () => {},
                ),
              )),
          Expanded(
            child: MockBottomDrag(
              bl: _buildBackLayer(),
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

  List<int> colors = const [
    0xfff65c78,
    0xffffd271,
    0xffc3f584,
    0xff46b3e6,
    0xfffbe3b9,
    0xffffbbcc,
    0xff52de97,
    0xfffc7978,
    0xffd597ce,
    0xfff2eee5,
    0xfffff8cd
  ];

  Widget _buildBackLayer() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //各个平台的剩余待还，以及总待还
          BlocBuilder<PfRemainBloc, List<Platform>>(
            builder: (_, s) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: s.length > 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Total',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            '${getTotalRemain(s).toString()}',
                            style: TextStyle(color: Colors.white),
                          ),
                          GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            shrinkWrap: true,
                            itemCount: s.length,
                            primary: false,
                            itemBuilder: (_, i) {
                              return Container(
                                height: 80,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Color(colors[i % 10]),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      (s[i].totalNum - s[i].paidNum).toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    Text(
                                      s[i].platformName,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : Center(
                        child: Text('no data',
                            style: TextStyle(color: Colors.white))),
              );
            },
          ),
          
          BlocBuilder<MonthBloc, MonthArgs>(builder: (context, s) {
            return DataCurveWidget(s.dataList, s.monthList);
          }),
        ],
      ),
    );
  }

  double getTotalRemain(List<Platform> pfs) {
    double sum = 0.0;
    for (var item in pfs) {
      sum = sum + item.totalNum - item.paidNum;
    }
    return sum;
  }

  Widget getCardAndList() {
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
                      }),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 40, top: 10, bottom: 0, right: 40),
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
    return AnimatedCrossFade(
      crossFadeState:
          index == 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 500),
      firstChild: ListView.builder(
          primary: false,
          shrinkWrap: true,
          padding: EdgeInsets.all(0.0),
          itemBuilder: (context, index) {
            return oweTileWidget(index);
          },
          itemCount: subPlatforms.length),
      secondChild: ListView.builder(
          primary: false,
          shrinkWrap: true,
          padding: EdgeInsets.all(0.0),
          itemBuilder: (context, index) {
            return loanTileWidget(index);
          },
          itemCount: humanLoans.length),
    );
  }

//列表【0】Item
  Widget oweTileWidget(int index) {
    print(subPlatforms.toString());
    return Padding(
      padding: EdgeInsets.only(left: 40, top: 10, bottom: 10, right: 30),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          print(index.toString() + '88888888888888888888888888888');
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PlatformDetailRoute.sub(subPlatforms[index])));
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    subPlatforms[index].platformKey,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(subPlatforms[index].dateThisStage ?? 'N/A'),
                  )
                ],
              ),
            ),
            Expanded(
              child: Text((subPlatforms[index].numThisStage -
                      subPlatforms[index].paidNum)
                  .toString()),
            ),
            IconButton(
              icon: Icon(
                Icons.confirmation_number,
                size: 30,
                color: subPlatforms[index].isPaidOff == 0
                    ? Colors.redAccent
                    : Colors.greenAccent,
              ),
              onPressed: () {
                BlocProvider.of<SubPlatformBloc>(context).add(SubPlatformEvent(
                    eventId: SubPlatformEvent.CHANGE_PAY_STATE,
                    data: subPlatforms[index]));
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
      if (o.isPaidOff == 1) {
        owePaid += o.numThisStage;
      } else {
        owePaid += o.paidNum;
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
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
          child: Text(
            'total: ' + oweTotal.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        Text(
          'paid: ' + owePaid.toString(),
          style: TextStyle(color: Colors.white),
        )
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
