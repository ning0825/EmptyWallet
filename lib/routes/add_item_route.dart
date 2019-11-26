import 'package:empty_wallet/bloc/bloc_platform_detail.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:empty_wallet/ui/custom_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'platform_detail_route.dart';

Platform mPf;
SubPlatform mSp;

BuildContext aContext;

class AddItemRoute extends StatelessWidget {
  AddItemRoute(Platform pf) {
    mPf = pf;
  }

  @override
  Widget build(BuildContext context) {
    aContext = context;

    return MaterialApp(
      home: AddItemHome(),
    );
  }
}

class AddItemHome extends StatefulWidget {
  @override
  _AddItemHomeState createState() => _AddItemHomeState();
}

class _AddItemHomeState extends State<AddItemHome>
    with TickerProviderStateMixin {
  AnimationController controller;
  AnimationController pickerController;
  Animation<Offset> pickerAnimation;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //每期金额
  double amountPerstage;
  //分期数
  int stageNum;
  //首次还款日
  String firstDate;

  TextEditingController textController;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    pickerController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));

    pickerAnimation =
        Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0))
            .chain(CurveTween(curve: Curves.ease))
            .animate(pickerController);

    textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            //主界面
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(aContext),
                  ),
                ),
                titleAndSubmit(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            CusTextField(
                              title: 'amount per stage',
                              onSaved: (s) => amountPerstage = double.parse(s),
                              validator: (s) => double.parse(s) < 0
                                  ? 'must not be negative'
                                  : null,
                            ),
                            CusTextField(
                              title: 'stage num',
                              onSaved: (s) => stageNum = int.parse(s),
                              validator: (s) => int.parse(s) < 0
                                  ? 'must not be negative'
                                  : null,
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode()); //隐藏软键盘
                                pickerController.forward(from: 0.0);
                              },
                              child: CusTextField(
                                title: 'first date',
                                onSaved: null,
                                validator: null,
                                enable: false,
                                controller: textController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            //DatePicker
            Positioned(
              bottom: 0,
              child: SlideTransition(
                position: pickerAnimation,
                child: CusDatePicker(
                  firstMonth: DateTime(2019, 11),
                  lastMonth: DateTime(2020, 06),
                  initDay: DateTime.now(),
                  onRetureDate: (d) {
                    firstDate = d.year.toString() +
                        "." +
                        d.month.toString() +
                        '.' +
                        d.day.toString();
                    textController.text = firstDate;
                    pickerController.reverse(from: 1.0);
                    controller.forward(from: 0.0);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget titleAndSubmit() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 30),
          child: Text(
            'Add a item',
            style: TextStyle(fontSize: 36, color: Colors.white),
          ),
        ),
        Spacer(),
        submitButton()
      ],
    );
  }

  SlideTransition submitButton() {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(-0.0, 0.0))
          .chain(CurveTween(curve: Curves.easeInOutQuart))
          .animate(controller),
      child: Container(
        child: IconButton(
          icon: Icon(
            Icons.done,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            _formKey.currentState.save();
            BlocProvider.of<PlatformDetailBloc>(pdrContext).add(
                PlatformDetailEvent(
                    methodId: PlatformDetailEvent.ADD_ITEM,
                    itemAddArgs: ItemAddArgs(
                        pf, sp, stageNum, amountPerstage, firstDate)));
            Navigator.pop(aContext);
          },
        ),
        width: 70,
        height: 60,
        decoration: BoxDecoration(
            color: Colors.green[300],
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8), topLeft: Radius.circular(8))),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    pickerController.dispose();
    mPf = null;
  }
}
