import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'Item.dart';
import 'dbhelper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

var itemData = [
  Item(name: '哒哒哒', num: 1900, dateTime: DateTime.now()),
  Item(name: '啦啦啦', num: 32432, dateTime: DateTime.now()),
  Item(name: 'find bus', num: 342, dateTime: DateTime.now()),
  Item(name: 'find bus', num: 3245, dateTime: DateTime.now()),
  Item(name: 'jiebei', num: 5678, dateTime: DateTime.now()),
  Item(name: 'jiebei', num: 2435, dateTime: DateTime.now()),
  Item(name: 'jiebei', num: 7645, dateTime: DateTime.now()),
  Item(name: 'jiebei', num: 342, dateTime: DateTime.now()),
  Item(name: 'jiebei', num: 3425, dateTime: DateTime.now()),
  Item(name: 'jiebei', num: 1000, dateTime: DateTime.now()),
  Item(name: '65467', num: 100, dateTime: DateTime.now()),
  Item(name: 'huabei', num: 1900, dateTime: DateTime.now()),
  Item(name: 'xiaomi', num: 3400, dateTime: DateTime.now()),
];

class _MyHomePageState extends State<MyHomePage> {
  double total = 10000;
  List<Item> items;

  int _pageIndex = 0;
  var _pageController = new PageController();
  List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    setListItems(itemData);
    setPageItems();

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'empty wallet',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: new PageView.builder(
          onPageChanged: _onPageChange,
          controller: _pageController,
          physics: BouncingScrollPhysics(),
          itemCount: pages.length,
          itemBuilder: (BuildContext context, int index) {
            return pages[index];
          }),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.yellow[300],
        items: [
          BottomNavigationBarItem(
              icon: IconButton(
                  icon: Icon(
                    Icons.list,
                    size: 34,
                  ),
                  onPressed: null),
              title: Text('detail')),
          BottomNavigationBarItem(
              icon: IconButton(
                  icon: Icon(
                    Icons.dashboard,
                    size: 34,
                  ),
                  onPressed: null),
              title: Text('stastics')),
        ],
        onTap: _onTap,
        currentIndex: _pageIndex,
      ),
    );
  }

  void _onTap(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(microseconds: 1000), curve: Curves.ease);
  }

  void _onPageChange(int index) {
    setState(() {
      if (_pageIndex != index) {
        _pageIndex = index;
      }
    });
  }

  ///set list data
  void setListItems(List<Item> list) {
    setState(() {
      this.items = list;

      var tempTotal = 0.0;
      for (var s in list) {
        tempTotal = tempTotal + s.num;
      }
      this.total = tempTotal;
    });
  }

  ///set page data
  void setPageItems() {
    setState(() {
      this.pages = [listPage(), statisticPage()];
    });
  }

  ///list page
  Widget listPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Total: ￥$total"),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: this.items.length,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return getListTile(index);
                }))
      ],
    );
  }

  ///statistic page
  Widget statisticPage() {
    return Text('statistic page');
  }

  ///list item in list page
  Widget getListTile(int index) {
    return Container(
      height: 100,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(blurRadius: 3, spreadRadius: 4, color: Colors.black12)
        ], color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  this.items[index].name,
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Expanded(
                child: Text(
                  this.items[index].num.toString(),
                  style: TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                flex: 2,
              ),
              Expanded(
                child: Text(
                  this.items[index].dateTime.year.toString() +
                      "-" +
                      this.items[index].dateTime.month.toString() +
                      "-" +
                      this.items[index].dateTime.day.toString(),
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          ),
        ));
  }
}
