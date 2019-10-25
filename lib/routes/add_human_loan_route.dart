import 'package:empty_wallet/bloc/bloc_human.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/routes/human_detail_route.dart';
import 'package:empty_wallet/ui/custom_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:empty_wallet/main.dart' as main;

BuildContext mContext;

class AddHumanLoanRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    mContext = context;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AddHumanLoanHome(),
    );
  }
}

class AddHumanLoanHome extends StatefulWidget {
  @override
  _AddHumanLoanHomeState createState() => _AddHumanLoanHomeState();
}

class _AddHumanLoanHomeState extends State<AddHumanLoanHome> {
  GlobalKey _key = GlobalKey<FormState>();
  GlobalKey _scaffordKey = GlobalKey<ScaffoldState>();

  //SubHuman
  //姓名
  String name;

  //数目
  double subNum;

  //日期
  String loanDate;

  //方式
  int method;

  //currentTotal
//  double currentTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffordKey,
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
            child: CusToolbar(
              title: 'Add Human Loan',
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
                                onSaved: (s) => {name = s},
                                validator: (s) =>
                                    s.isEmpty ? 'Please input name' : null,
                              ),
                              CusTextField(
                                  title: 'Num',
                                  keyboardType: TextInputType.number,
                                  onSaved: (s) => subNum = double.parse(s),
                              ),
                              CusTextField(
                                title: 'Method',
                                keyboardType: TextInputType.number,
                                onSaved: (s) => method = int.parse(s),
                              ),
                              CusTextField(
                                title: 'date',
                                onSaved: (s) => loanDate = s,
                              )
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

  void saveAndGo() async {
    //check existing.
    var hlInDB = await getHlByName(name);
    if (hlInDB != null) {
      var snackbar = SnackBar(
          content: Text('this human is existing, please check the name'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating);
      (_scaffordKey.currentState as ScaffoldState).showSnackBar(snackbar);
      return;
    }

    var humanLoan = HumanLoan(hName: name, hTotal: subNum);
    int hId = await insertDate(humanLoan);
    humanLoan.id = hId;

    var subHuman = SubHuman(
        sName: name,
        subNum: subNum,
        loanDate: loanDate,
        paymentMethod: method,
        currentTotal: subNum);
    int sId = await insertDate(subHuman);
    subHuman.id = sId;

    BlocProvider.of<HumanBloc>(main.mContext).add(HumanEvent(methodId: HumanEvent.SHOW_HUMAN_LOAN));

    Navigator.of(mContext)
      ..pop()
      ..push(
          MaterialPageRoute(builder: (context) => HumanDetailRoute(humanLoan)));
  }
}
