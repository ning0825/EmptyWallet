import 'package:empty_wallet/advan/localizations.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/routes/platform_detail_route.dart';
import 'package:empty_wallet/ui/custom_ui.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

BuildContext mContext;

class AddPlatformRoute extends StatelessWidget {
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
  @override
  State<StatefulWidget> createState() => EditItemState();
}

class EditItemState extends State<EditItemHome> {
  GlobalKey _key = GlobalKey<FormState>();
  GlobalKey _scaffordKey = GlobalKey<ScaffoldState>();

  //平台名称
  String name;
  //还款日
  String dueDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffordKey,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
            child: CusToolbar(
              title: EwLocalizations.of(mContext).title,
              leftIcon: Icons.close,
              leftOnPress: () => Navigator.pop(mContext),
              rightIcon: Icons.save,
              rightOnPress: () {
                if ((_key.currentState as FormState).validate()) {
                  (_key.currentState as FormState).save();
                  saveAndGo();
                }
              },
            ),
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
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              CusTextField(
                                title: 'Name',
                                onSaved: (s) => name = s,
                                validator: (s) => s.isEmpty
                                    ? 'Please input name'
                                    : null,
                              ),
                              CusTextField(
                                title: 'dueDate',
                                onSaved: (s) => dueDate = s,
                                validator: (s) => (!(int.parse(s) > 0 &&
                                    (int.parse(s) < 32))
                                    ? 'dueDate must be between 1 and 31'
                                    : null),
                              ),
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
    );
  }

  //save this platform and go to platform_detail_route.
  void saveAndGo() async {
    //check if this platform already exist.
    var pfInDB = await getPlatformByName(name);
    if (pfInDB != null) {
      var snackbar = SnackBar(
          content: Text('A platform contains this name already existed, please check the name'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating);
      (_scaffordKey.currentState as ScaffoldState).showSnackBar(snackbar);
      return;
    }

    var p = Platform(platformName: name, dueDate: dueDate);
    int i = await insertDate(p);
    p.id = i;
    Navigator.of(mContext)
      ..pop()
      ..push(MaterialPageRoute(builder: (context) => PlatformDetailRoute(p)));
  }
}
