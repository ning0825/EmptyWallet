import 'package:empty_wallet/bloc/bloc_platform_detail.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
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
  _PlatformDetailHomeState createState() {
    return _PlatformDetailHomeState();
  }
}

class _PlatformDetailHomeState extends State<PlatformDetailHome> {
  String pfName; //平台名称
  String pfSubNum; //平台总待还

  double itemNPS; //num per stage
  int itemSN; //stage num

  List<Item> items;
  String pfTotalNum;

  GlobalKey gk = GlobalKey<FormState>();

  PlatformDetail _platformDetail;

  PlatformDetailBloc _pdBloc;

  @override
  void initState() {
    super.initState();

    pdrContext = context;
    _pdBloc = BlocProvider.of<PlatformDetailBloc>(context);

    _getPf();
  }

  Future<void> _getPf()async{
    if(pf == null) {
      pf = await getPlatformByName(sp.platformKey);
    }
    _pdBloc.add(PlatformDetailEvent(
        methodId: PlatformDetailEvent.SHOW_PLATFORM_DETAIL, pf: pf));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
      child: Scaffold(
        backgroundColor: Colors.amberAccent,
        body: BlocBuilder<PlatformDetailBloc, PlatformDetail>(
          builder: (context, s) {
            _platformDetail = s;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CusToolbar(
                    title: 'detail',
                    leftIcon: Icons.close,
                    leftOnPress: () => Navigator.pop(pContext),
                    rightIcon: Icons.add,
                    rightOnPress: () => _showAddDialog()),
                Text(
                  '平台名称' + (s.pf != null ? s.pf.platformName : ' '),
                  style: TextStyle(color: Colors.white, fontSize: 50),
                ),
                Text('总待还' + (s.pf != null ? s.pf.totalNum.toString() : ' ')),
                Text('本月待还' +
                    (s.spf != null ? (s.spf.isPaidOff == 0 ? (s.spf.numThisStage - s.spf.paidNum).toString() : 0.toString()) : ' ')),
                Expanded(
                    child: s.sis != null
                        ? ListView.builder(
                            itemCount: s.sis.length,
                            itemBuilder: (context, i) {
                              return ListTile(
                                title: Text(s.sis[i].numThisStage.toString()),
                                subtitle: Text(s.sis[i].currentStage.toString() + '/' + s.sis[i].totalStages.toString()),
                                trailing: IconButton(icon: Icon(Icons.add, color: s.sis[i].isPaidOff == 0 ? Colors.redAccent : Colors.greenAccent,), onPressed: (){
                                    _pdBloc.add(PlatformDetailEvent(methodId: PlatformDetailEvent.CHANGE_ITEM_STATE, subItem: s.sis[i], pf: pf));
                                }),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailRoute(s.sis[i]))),
                              );
                            })
                        : Text(' '))
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
        context: context,
        builder: (context) => new SimpleDialog(children: <Widget>[
              Form(
                  key: gk,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'NumPerStage',
                        ),
                        onSaved: (s) => itemNPS = double.parse(s),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'StageNum'),
                        keyboardType: TextInputType.number,
                        onSaved: (s) => itemSN = int.parse(s),
                      ),
                      Row(
                        children: <Widget>[
                          OutlineButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          Spacer(),
                          OutlineButton(
                            onPressed: () {
                              if ((gk.currentState as FormState).validate()) {
                                (gk.currentState as FormState).save();
                                _pdBloc.add(
                                    PlatformDetailEvent(
                                        methodId: PlatformDetailEvent.ADD_ITEM,
                                        itemAddArgs: ItemAddArgs(
                                            _platformDetail.pf,
                                            _platformDetail.spf,
                                            itemSN,
                                            itemNPS)));
                                Navigator.pop(context);
                              }
                            },
                            child: Text('OK'),
                          ),
                        ],
                      )
                    ],
                  ))
            ]));
  }
}
