import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'addNewItemPage.dart';
import 'dbhelper.dart';

import 'Item.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;

    //init database
    openDB();

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
  Item(name: '信用卡', num: 2400, dateTime: "2019-8-15"),
  Item(name: '众享金', num: 1000, dateTime: "2019-8-15"),
  Item(name: '花呗', num: 300, dateTime: "2019-8-15"),
  Item(name: '分期乐', num: 8000, dateTime: "2019-8-15"),
  Item(name: '小米金融', num: 4000, dateTime: "2019-8-15"),
  Item(name: '爱学贷', num: 8000, dateTime: "2019-8-15"),
  Item(name: '京东金融', num: 5400, dateTime: "2019-8-15"),
  Item(name: '借呗', num: 1500, dateTime: "2019-8-15"),
];

String getNowDataString() {
  return DateTime.now().year.toString() +
      "-" +
      DateTime.now().month.toString() +
      "-" +
      DateTime.now().day.toString();
}

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
      floatingActionButton: FloatingActionButton(onPressed: () => addNewItem()),
    );
  }

  void addNewItem() {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => AddNewItemPage()));
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

  String db2string = '';

  void printItems() async {
    StringBuffer dbString = StringBuffer('');
    final s = await getDebts();
    for (var i in s) {
      dbString.writeln(i.name +
          "-" +
          i.num.toString() +
          "-" +
          i.fen.toString() +
          "-" +
          i.dateTime);
    }
    setState(() {
      db2string = dbString.toString();
    });
  }

  void delDebt() {
    for(int i = 0; i < 40; i++) {
      delById(i);
    }
  }

  ///statistic page
  Widget statisticPage() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: () => insertDebt(itemData[0]),
              child: Text('insert'),
              color: Colors.yellow,
            ),
            MaterialButton(
              onPressed: () => delDebt(),
              child: Text('del'),
              color: Colors.red,
            ),
            MaterialButton(
              onPressed: () => printItems(),
              child: Text('change'),
              color: Colors.blue,
            ),
            MaterialButton(
              onPressed: () => printItems(),
              child: Text('get'),
              color: Colors.green,
            ),
          ],
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        Expanded(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical, child: Text(db2string)))
      ],
    );
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
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: Text(
                  this.items[index].num.toString(),
                  style: TextStyle(fontSize: 30),
                  textAlign: TextAlign.start,
                ),
                flex: 1,
              ),
              Expanded(
                child: Text(
                  this.items[index].dateTime,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.end,
                ),
              )
            ],
          ),
        ));
  }
}
