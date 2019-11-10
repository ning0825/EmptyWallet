import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Custom Toolbar
class CusToolbar extends StatelessWidget {
  final String title;
  final IconData leftIcon;
  final Function leftOnPress;
  final IconData rightIcon;
  final GlobalKey rightIconKey;
  final Function rightOnPress;

  CusToolbar(
      {@required this.title,
      this.leftIcon,
      this.leftOnPress,
      this.rightIcon,
      this.rightIconKey,
      this.rightOnPress})
      : super() {
    assert(title != null);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              leftIcon,
              color: Colors.white,
            ),
            onPressed: leftOnPress,
          ),
          Expanded(
              child: Text(
            this.title,
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )),
          IconButton(
            key: rightIconKey,
            icon: Icon(
              rightIcon,
              color: Colors.white,
            ),
            onPressed: rightOnPress,
          ),
        ],
      ),
    );
  }
}

//Cards in main UI.
class BaseCard extends Container {
  final Widget child;

  BaseCard({this.child})
      : super(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      spreadRadius: 0, blurRadius: 12, color: Colors.grey[400])
                ],
                image: DecorationImage(
                    image: AssetImage('assets/CardBG.webp'), fit: BoxFit.fill)),
            padding: EdgeInsets.all(40),
            width: 300,
            margin: EdgeInsets.only(top: 20, left: 2, right: 2, bottom: 20),
            height: 280);
}

class CusTextField extends StatelessWidget {
  final String title;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator validator;
  final String hintText;
  final TextInputType keyboardType;

  CusTextField(
      {this.title,
      this.onSaved,
      this.validator,
      this.hintText,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[350]),
            ),
          ),
          TextFormField(
              decoration: InputDecoration(
                fillColor: Colors.grey[800],
                filled: true,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
                // focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3)),
                labelStyle: TextStyle(color: Colors.black),
              ),
              cursorColor: Colors.black,
              keyboardType: keyboardType,
              onSaved: onSaved,
              validator: validator),
        ],
      ),
    );
  }
}

class CusDatePicker extends StatefulWidget {
  final DateTime firstMonth;
  final DateTime lastMonth;
  final DateTime initDate;

  final String selectedDate = '';

  CusDatePicker({this.firstMonth, this.lastMonth, this.initDate});

  @override
  State<StatefulWidget> createState() => CusDatePickerState();
}

class CusDatePickerState extends State<CusDatePicker> {
  @override
  Widget build(BuildContext context) {
    return _buildPageItme(28, 3);
  }

  Widget _buildPageItme(int days, int initWeek) {
    return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[900],
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemCount: days,
          itemBuilder: (_, index) {
            return Container(
              margin: EdgeInsets.all(8.0),
              child: CircleAvatar(child: Text(index.toString()), backgroundColor: Colors.grey[700],),
            );
          },
        ));
  }
}
