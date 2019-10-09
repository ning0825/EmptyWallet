import 'package:empty_wallet/db/Item.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/tool/utilities.dart';
import 'package:empty_wallet/ui/cus_ui.dart';
import 'package:flutter/material.dart';

Platform pf;
BuildContext mContext;

/*
todo why build twice.
I/flutter ( 5955): build PlatformDetailRoute
I/flutter ( 5955): build PlatformDetailHome
I/flutter ( 5955): _PlatformDetailHomeState.initState//初始化只一次
I/flutter ( 5955): build PlatformDetailHomeState

I/flutter ( 5955): build PlatformDetailRoute
I/flutter ( 5955): build PlatformDetailHomeState*/

class PlatformDetailRoute extends StatelessWidget {

  PlatformDetailRoute(Platform platform) {
    pf = platform;
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlatformDetailHome(),
    );
  }

  Future<void> getPlatform(String key) async{
    pf = await getPf(key);
  }
}

class PlatformDetailHome extends StatefulWidget {
  @override
  _PlatformDetailHomeState createState() {
    return _PlatformDetailHomeState();
  }
}

class _PlatformDetailHomeState extends State<PlatformDetailHome> {
  String pfName;
  String pfTotalNum;
  String pfSubNum;

  double itemNPS; //num per stage
  int itemSN; //stage num

  GlobalKey gk = GlobalKey<FormState>();

  List<Item> items;

  @override
  void initState() {
    super.initState();

    pfName = pf.platformName;
    pfTotalNum = pf.totalNum.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
        child: Scaffold(
          backgroundColor: Colors.blueGrey,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CusToolbar(
                title: 'detail',
                leftIcon: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(mContext);
                  },
                ),
                rightIcon: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => new SimpleDialog(
                              children: <Widget>[
                                Form(
                                    key: gk,
                                    child: Column(
                                      children: <Widget>[
                                        TextFormField(
                                          decoration: InputDecoration(
                                            labelText: 'NumPerStage',
                                          ),
                                          onSaved: (s) =>
                                              itemNPS = double.parse(s),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                        ),
                                        TextFormField(
                                          decoration: InputDecoration(
                                              labelText: 'StageNum'),
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
                                                if ((gk.currentState
                                                        as FormState)
                                                    .validate()) {
                                                  (gk.currentState as FormState)
                                                      .save();
                                                  _upgradeDB();
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        )
                                      ],
                                    ))
                              ],
                            ));
                  },
                ),
              ),
              Text(
                '平台名称' + pf.platformName,
                style: TextStyle(color: Colors.white, fontSize: 50),
              ),
              Text('总待还' + pfTotalNum.toString()),
              Text('本月待还' + pfSubNum.toString()),
              Expanded(
                child: items != null ?
                ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        title: Text(items[i].numPerStage.toString()),
                        trailing: Text(items[i].stageNum.toString()),
                      );
                    }) : Text('no date')
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _upgradeDB() async{
    var itemTag = DateTime.now().toString();

    //insertItem
    insertDate(Item(
        platformKey: pfName,
        stageNum: itemSN,
        numPerStage: itemNPS,
        itemName:
        itemTag));

    var nowTime = DateTime.now();

    for (int i = 0; i < itemSN; i++) {
      var s = nowTime.year.toString() +
          '.' +
          nowTime.month
              .toString();

      //insertSubItem
      insertDate(SubItem(itemKey: itemTag, monthKey: s, numThisStage: itemNPS, currentStage: i + 1)); //insert subItem

      //update subplatform
      var sp = await getSubPlatform(pfName, s);
      sp.numThisStage += itemNPS;
      updateSubPlatform(sp);

      if (i == 0) {
        pfSubNum = sp.numThisStage.toString();
      }

      nowTime = nowTime.add(Duration(
          days: dayInMonth(
                  nowTime.year,
                  nowTime
                      .month)));
    }
    //update platform
    pf.totalNum += itemNPS * itemSN;
    updatePlatform(pf);

    //update UI
    pfTotalNum = pf.totalNum.toString();
    items = await getItem(pfName);
    setState(() {});
  }
}
