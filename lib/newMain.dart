import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(NewApp());

class NewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: NewHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NewHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NewHomeState();
}

class NewHomeState extends State<NewHome> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10),
              child: SafeArea(
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      onPressed: () => {},
                    ),
                    Expanded(
                        child: Text(
                      'bank',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    )),
                    IconButton(
                      icon: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                      onPressed: () => {},
                    )
                  ],
                ),
              )),
          Expanded(
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26)),
                  color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(40),
                    margin: EdgeInsets.all(40),
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                        color: Colors.amber),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('本月需还:'),
                        Text('已       还:'),
                        Text('未       还:')
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: IconButton(
                            icon: Icon(Icons.ac_unit),
                          ),
                          title: Text('title'),
                          subtitle: Text('subtitle'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: Icon(
                              Icons.image,
                              color: Colors.red,
                            ),
                            onPressed: () => {},
                          )

                        );
                      },
                      itemCount: 50,
                      itemExtent: 40,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
