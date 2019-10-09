import 'package:empty_wallet/db/Item.dart';
import 'package:empty_wallet/routes/platformDetailRoute.dart';
import 'package:empty_wallet/ui/cus_ui.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

BuildContext mContext;

class EditItemRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    mContext = context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EditItemHome(),
    );
  }
}

class EditItemHome extends StatefulWidget {
//  final BuildContext context;
//
//  EditItemHome(this.context);

  @override
  State<StatefulWidget> createState() => EditItemState();
}

class EditItemState extends State<EditItemHome> {
//  BuildContext context;
  GlobalKey _key = GlobalKey<FormState>();

  String name;
  String dueDate;

//  EditItemState(this.context);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
            child: SafeArea(
                child: CusToolbar(
              title: 'Edit',
              leftIcon: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(mContext),
              ),
              rightIcon: IconButton(
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                onPressed: () {
                  if((_key.currentState as FormState).validate()) {
                    (_key.currentState as FormState).save();
                    saveAndGo();
                  }
                },
              ),
            )),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.loose,
                        child: Form(
                          key: _key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(top: 26, bottom: 10),
                                  child: Text(
                                    "Name",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24),
                                  )),
                              TextFormField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                ),
                                onSaved: (s) => {name = s},
                                validator: (s) => s.isEmpty ? 'Please input name' : null, //todo 用isEmpty判空，用==null报invalidate异常
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 26, bottom: 10),
                                  child: Text(
                                    "dueDate",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24),
                                  )),
                              TextFormField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.numberWithOptions(),
                                onSaved: (s) => dueDate = s,
                                validator: (s) => (
                                    !(int.parse(s) > 0 && (int.parse(s) < 32))
                                        ? 'dueDate must be between 1 and 31'
                                        : null
                              )),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          )
        ],
      ),
    ));
  }

  void saveAndGo() async{
    //保存这个platform，并显示platform详情页面
    var p = Platform(platformName: name, dueDate: dueDate);
    int i = await insertDate(p);
    p.id = i;
    Navigator.of(mContext)..pop()..push(MaterialPageRoute(builder: (context) => PlatformDetailRoute(p)));
  }
}
