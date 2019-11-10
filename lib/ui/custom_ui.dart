import 'package:flutter/material.dart';

//Custom Toolbar
class CusToolbar extends StatelessWidget {
  final String title;
  final IconData leftIcon;
  final Function leftOnPress;
  final IconData rightIcon;
  final GlobalKey rightIconKey;
  final Function rightOnPress;

  CusToolbar({@required this.title,
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
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
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
              image: AssetImage('assets/CardBG.webp'), fit: BoxFit.fill)
      ),
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

  CusTextField({this.title, this.onSaved, this.validator, this.hintText, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
//        Padding(
//            padding: EdgeInsets.only(top: 26, bottom: 10),
//            child: Text(
//              title,
//              style: TextStyle(
//                  color: Colors.grey, fontSize: 24),
//            )),
        TextFormField(
            decoration: InputDecoration(
              labelText: title,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 3)),
              labelStyle: TextStyle(color: Colors.black),
            ),
            cursorColor: Colors.black,
            keyboardType:keyboardType,
            onSaved: onSaved,
            validator: validator),
      ],
    );
  }
}
