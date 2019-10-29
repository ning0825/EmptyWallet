import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/ui/custom_ui.dart';
import 'package:flutter/material.dart';

BuildContext mContext;
Item mItem;
List<SubItem> subItems = [];

class ItemDetailRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    mContext = context;

    print('------------------' + mItem.toString());

    return MaterialApp(
      home: ItemDetailHome(),
    );
  }

  ItemDetailRoute(Item item) {
    mItem = item;
  }
}

class ItemDetailHome extends StatefulWidget {
  @override
  _ItemDetailHomeState createState() => _ItemDetailHomeState();
}

class _ItemDetailHomeState extends State<ItemDetailHome> {
  var style = TextStyle(color: Colors.white);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setSubItems().whenComplete(()=>{
      setState((){})
    });
  }

  Future<void> setSubItems() async {
    subItems = await getSubItems(mItem.itemName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
          child: Column(
            children: <Widget>[
              CusToolbar(
                title: 'Item Detail',
                leftIcon: Icons.close,
                leftOnPress: () => Navigator.pop(mContext),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: subItems.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => ListTile(
                          leading: Text(subItems[index].numThisStage.toString(), style: style,),
                          title: Text(subItems[index].monthKey, style: style),
                          trailing: Text(subItems[index].currentStage.toString(), style: style),
                        )),
              )
            ],
          ),
        ));
  }
}
