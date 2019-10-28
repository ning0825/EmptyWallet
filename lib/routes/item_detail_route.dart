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

  ItemDetailRoute(Item item){
    mItem = item;
  }
}

class ItemDetailHome extends StatefulWidget {
  @override
  _ItemDetailHomeState createState() => _ItemDetailHomeState();
}

class _ItemDetailHomeState extends State<ItemDetailHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          CusToolbar(
            title: 'Item Detail',
            leftIcon: Icons.close,
            leftOnPress: () => Navigator.pop(mContext),
          )
        ],
      )
    );
  }
}

