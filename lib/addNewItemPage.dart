import 'package:flutter/material.dart';

class AddNewItemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: _NewItemPage(),
    );
  }
}

class _NewItemPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewItemState();
}

class _NewItemState extends State<_NewItemPage> {
  var _nameController = TextEditingController();
  var _numController = TextEditingController();
  var _fenController = TextEditingController();
  var _dataTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('add'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[Text('name:'), Expanded(child: TextField())],
          ),
          Row(
            children: <Widget>[
              Text('num:'),
              Expanded(
                  child: TextField(
                keyboardType: TextInputType.number,
              ))
            ],
          ),
          Row(
            children: <Widget>[
              Text('fen'),
              Expanded(
                  child: DropdownButton(
                items: [
                  DropdownMenuItem(child: Text('yes')),
                  DropdownMenuItem(child: Text('no')),
                  DropdownMenuItem(child: Text('no')),
                  DropdownMenuItem(child: Text('no')),
                  DropdownMenuItem(child: Text('no'))
                ],
                onChanged: (T) => {},
                isExpanded: true,
              ))
            ],
          ),
          Row(
            children: <Widget>[Text('datatime:'), Expanded(child: TextField())],
          ),
          RaisedButton(onPressed: () => 's')
        ],
      ),
    );
  }
}
