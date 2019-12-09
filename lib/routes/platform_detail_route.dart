import 'package:empty_wallet/bloc/bloc_platform_detail.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/routes/add_item_route.dart';
import 'package:empty_wallet/ui/custom_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'item_detail_route.dart';

Platform pf;
SubPlatform sp;
BuildContext pContext;
BuildContext pdrContext;

class PlatformDetailRoute extends StatelessWidget {
  PlatformDetailRoute(Platform platform) {
    pf = platform;
  }

  PlatformDetailRoute.sub(SubPlatform subPlatform) {
    sp = subPlatform;
  }

  @override
  Widget build(BuildContext context) {
    pContext = context;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider<PlatformDetailBloc>(
          builder: (context) => PlatformDetailBloc(),
          child: PlatformDetailHome()),
    );
  }
}

class PlatformDetailHome extends StatefulWidget {
  @override
  _PlatformDetailHomeState createState() => _PlatformDetailHomeState();
}

class _PlatformDetailHomeState extends State<PlatformDetailHome> {
  String pfName; //平台名称
  String pfSubNum; //平台总待还

  double itemNPS; //num per stage
  int itemSN; //stage num

  List<Item> items;
  String pfTotalNum;

  GlobalKey gk = GlobalKey<FormState>();

  PlatformDetailBloc _pdBloc;

//用来在应用退出时判断当前platform是否有数据
  // SubPlatform sp;
  // Platform pf;

  @override
  void initState() {
    super.initState();

    pdrContext = context;
    _pdBloc = BlocProvider.of<PlatformDetailBloc>(context);

    _getPf();
  }

  Future<void> _getPf() async {
    if (pf == null) {
      pf = await getPlatformByName(sp.platformKey);
    }
    _pdBloc.add(PlatformDetailEvent(
        methodId: PlatformDetailEvent.SHOW_PLATFORM_DETAIL, pf: pf));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[200],
      body: BlocBuilder<PlatformDetailBloc, PlatformDetail>(
        builder: (context, s) {
          sp = s.spf;
          pf = s.pf;
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CusToolbar(
                    title: 'detail',
                    leftIcon: Icons.close,
                    leftOnPress: () {
                      if (s.spf == null) {
                        delPlatform(s.pf);
                        Navigator.pop(pContext);
                      } else {
                        Navigator.pop(pContext);
                      }
                    },
                    rightIcon: Icons.add,
                    rightOnPress: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AddItemRoute(null)))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    s.pf != null ? s.pf.platformName : '',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'total num to pay: \$',
                        style: TextStyle(color: Colors.white54),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          s.pf != null ? s.pf.totalNum.toString() : ' ',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'num this month: \$',
                        style: TextStyle(color: Colors.white54),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          s.spf != null
                              ? (s.spf.isPaidOff == 0
                                  ? (s.spf.numThisStage - s.spf.paidNum)
                                      .toString()
                                  : 0.toString())
                              : ' ',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: s.sis != null
                        ? ListView.builder(
                            itemCount: s.sis.length,
                            itemBuilder: (context, i) {
                              return _buildItem(context, i, s);
                            })
                        : Text(''))
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, int i, PlatformDetail s) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(s.sis[i].dueDay,
                            style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Text(
                          '${s.sis[i].currentStage}/${s.sis[i].totalStages}',
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 70.0),
                    child: Text(
                      '\$ ${s.sis[i].numThisStage.toString()}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50.0))),
          ),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ItemDetailRoute(s.sis[i]))),
        ),
        Positioned(
          child: FloatingActionButton(
            heroTag: '$i',
            backgroundColor:
                s.sis[i].isPaidOff == 0 ? Colors.redAccent : Colors.greenAccent,
            onPressed: () => _pdBloc.add(PlatformDetailEvent(
                methodId: PlatformDetailEvent.CHANGE_ITEM_STATE,
                subItem: s.sis[i],
                pf: pf)),
            child: Text(s.sis[i].isPaidOff == 0 ? 'pay' : 'paid'), 
          ),
          right: -0,
          top: 10,
          bottom: 10,
        )
      ],
    );
  }

  @override
  void dispose() {
    if (sp == null) {
      delPlatform(pf);
      Navigator.pop(pContext);
    }
    pf = null;
    sp = null;
    super.dispose();
  }
}
