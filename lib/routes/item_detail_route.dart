import 'package:empty_wallet/bloc/bloc_item_detail.dart';
import 'package:empty_wallet/bloc/bloc_month.dart';
import 'package:empty_wallet/bloc/bloc_platform_detail.dart';
import 'package:empty_wallet/bloc/bloc_subplatform.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/routes/platform_detail_route.dart';
import 'package:empty_wallet/ui/custom_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main.dart';

BuildContext idrContext;
SubItem mSubItem;
//List<SubItem> subItems = [];

class ItemDetailRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    idrContext = context;

    return MaterialApp(
      home: BlocProvider<ItemDetailBloc>(
          builder: (_) => ItemDetailBloc(), child: ItemDetailHome()),
    );
  }

  ItemDetailRoute(SubItem subItem) {
    mSubItem = subItem;
  }
}

class ItemDetailHome extends StatefulWidget {
  @override
  _ItemDetailHomeState createState() => _ItemDetailHomeState();
}

class _ItemDetailHomeState extends State<ItemDetailHome> {
  var style = TextStyle(color: Colors.white);

  ItemDetailBloc _itemDetailBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _itemDetailBloc = BlocProvider.of<ItemDetailBloc>(context);
    _showSubItems();
  }

  Future<void> _showSubItems() async {
    Item item = await getItemByName(mSubItem.itemKey);
    _itemDetailBloc.add(
        ItemDetailEvent(methodId: ItemDetailEvent.SHOW_SUBITEMS, data: item));
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
                leftOnPress: () => Navigator.pop(idrContext),
              ),
              Expanded(
                child: BlocBuilder<ItemDetailBloc, List<SubItem>>(
                  builder: (_, subItems) {
                    if(subItems.length == 0) {
                      return Container();
                    }
                    return ListView.builder(
                        itemCount: subItems.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => ListTile(
                              leading: Text(
                                subItems[index].numThisStage.toString(),
                                style: TextStyle(color: subItems[index].isPaidOff == 0 ? Colors.redAccent : Colors.white),
                              ),
                              title:
                                  Text(subItems[index].monthKey, style: style),
                              subtitle: Text(
                                subItems[index].currentStage.toString() +
                                    '/' +
                                    subItems.length.toString(),
                                style: style,
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.adb,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  //update ItemDetailRoute
                                  _itemDetailBloc.add(
                                      ItemDetailEvent(
                                          methodId: ItemDetailEvent
                                              .CHANGE_SUBITEM_STATE,
                                          data: subItems[index]));
                                }
                              ),
                            ));
                  },
                ),
              )
            ],
          ),
        ));
  }
}
