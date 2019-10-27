import 'package:empty_wallet/bloc/bloc_month.dart';
import 'package:empty_wallet/bloc/bloc_platform_detail.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/ui/custom_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Platform pf;
BuildContext mContext;

class PlatformDetailRoute extends StatelessWidget {
  PlatformDetailRoute(Platform platform) {
    pf = platform;
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;

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

    _pdBloc = BlocProvider.of<PlatformDetailBloc>(context);

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
                    leftOnPress: () => Navigator.pop(mContext),
                    rightIcon: Icons.add,
                    rightOnPress: () => _showAddDialog()),
                Text(
                  '平台名称' + (s.pf != null ? s.pf.platformName : ' '),
                  style: TextStyle(color: Colors.white, fontSize: 50),
                ),
                Text('总待还' + (s.pf != null ? s.pf.totalNum.toString() : ' ')),
                Text('本月待还' +
                    (s.spf != null ? s.spf.numThisStage.toString() : ' ')),
                Expanded(
                    child: s.its != null
                        ? ListView.builder(
                            itemCount: s.its.length,
                            itemBuilder: (context, i) {
                              return ListTile(
                                title: Text(s.its[i].numPerStage.toString()),
                                trailing: Text(s.its[i].stageNum.toString()),
                              );
                            })
                        : Text('no date'))
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
