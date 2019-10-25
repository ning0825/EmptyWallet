import 'package:empty_wallet/bloc/bloc_human.dart';
import 'package:empty_wallet/bloc/bloc_human_detail.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/ui/custom_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:empty_wallet/main.dart' as main;

BuildContext mContext;

HumanLoan _humanLoan;

class HumanDetailRoute extends StatelessWidget {
  HumanDetailRoute(HumanLoan humanLoan) {
    _humanLoan = humanLoan;
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;

    return MaterialApp(
      home: BlocProvider<SubHumanBloc>(
          builder: (context) => SubHumanBloc(), child: HumanDetailHome()),
    );
  }
}

class HumanDetailHome extends StatefulWidget {
  @override
  _HumanDetailHomeState createState() => _HumanDetailHomeState();
}

class _HumanDetailHomeState extends State<HumanDetailHome> {
//  String hName; //人名
//  String hTotal; //总额
//  List<SubHuman> subHumans;
  SubHumanBloc _subHumanBloc;

  GlobalKey formKey = new GlobalKey<FormState>();

  //For constructing a SubHuman.
  String name;
  double num;
  String date;
  int method;
  double currentTotal;

  @override
  void initState() {
    super.initState();

    _subHumanBloc = BlocProvider.of<SubHumanBloc>(context);
    _subHumanBloc.add(SubHumanEvent(
        method: SubHumanEvent.SHOW_SUBHUMANS, humanLoan: _humanLoan));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: BlocBuilder<SubHumanBloc, SubHumanAddArgs>(
          builder: (context, s) {
            return Column(
              children: <Widget>[
                CusToolbar(
                  title: 'Human Detail',
                  leftIcon: Icons.close,
                  leftOnPress: () => Navigator.pop(mContext),
                  rightIcon: Icons.add,
                  rightOnPress: () => _showAddDialog(),
                ),
                Text('name: ' +
                    (s.humanLoan != null ? s.humanLoan.hName : 'null')),
                Text('total: ' +
                    (s.humanLoan != null
                        ? s.humanLoan.hTotal.toString()
                        : 'null')),
                Expanded(
                  child: ListView.builder(
                    itemCount: (s.subHumans != null ? s.subHumans.length : 0),
                    itemBuilder: (context, i) {
                      return ListTile(
                        title: Text(s.subHumans[i].subNum.toString()),
                        trailing: Text(s.subHumans[i].loanDate),
                      );
                    },
                  ),
                )
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
        builder: (context) => SimpleDialog(
              title: Text('add a item'),
              children: <Widget>[
                Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(labelText: 'num'),
                          onSaved: (s) => num = double.parse(s),
                          validator: (s) => s.isEmpty ? 'null' : null,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'date'),
                          validator: (s) => s.isEmpty ? 'null' : null,
                          onSaved: (s) => date = s,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'method'),
                          validator: (s) => s.isEmpty ? 'null' : null,
                          onSaved: (s) => method = int.parse(s),
                        ),
                        Row(
                          children: <Widget>[
                            OutlineButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Spacer(),
                            OutlineButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                if ((formKey.currentState as FormState)
                                    .validate()) {
                                  (formKey.currentState as FormState).save();
                                  Navigator.pop(context);
//                                  _saveSubHuman();
                                  _subHumanBloc.add(SubHumanEvent(
                                      method: SubHumanEvent.ADD_SUB_HUMAN,
                                      subHumanAddArgs2: SubHumanAddArgs2(humanLoan: _humanLoan, num: num, date: date, payMethod: method)));
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ))
              ],
              backgroundColor: Colors.redAccent,
            ));
  }

  Future<void> _saveSubHuman() async {

  }
}
