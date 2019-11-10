import 'package:flutter/material.dart';
import 'package:empty_wallet/ui/custom_ui.dart';

class AddItemRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AddItemHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AddItemHome extends StatefulWidget {
  @override
  _AddItemHomeState createState() => _AddItemHomeState();
}

class _AddItemHomeState extends State<AddItemHome>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => {
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (_, a1, a2) => SimpleDialog(
                      children: <Widget>[
                        Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey,
                        )
                      ],
                    ),
                    
                  )
                },
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
                          onSaved: null,
                          validator: null,
                        ),
                        CusTextField(
                          title: 'stage num',
                          onSaved: null,
                          validator: null,
                        ),
                        CusTextField(
                          title: 'first date',
                          onSaved: null,
                          validator: null,
                        ),
                      ],
                    ),
                  ),
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
        child: Icon(
          Icons.done,
          color: Colors.white,
          size: 30,
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
  }
}
