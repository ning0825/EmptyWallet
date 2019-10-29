import 'package:bloc/bloc.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';

class ItemDetailEvent {
  static const SHOW_SUBITEMS = 0;
  static const CHANGE_SUBITEM_STATE = 1;

  int methodId;
  Item item;

  ItemDetailEvent({this.methodId, this.item});
}

class ItemDetailBloc extends Bloc<ItemDetailEvent, List<SubItem>> {
  @override
  List<SubItem> get initialState => null;

  @override
  Stream<List<SubItem>> mapEventToState(ItemDetailEvent event) async*{
    switch(event.methodId) {
      case ItemDetailEvent.SHOW_SUBITEMS:
        yield await getSIs(event.item);
        break;
      case ItemDetailEvent.CHANGE_SUBITEM_STATE:
        break;
    }
  }

  Future<List<SubItem>> getSIs(Item item) async{
    return await getSubItems(item.itemName);
  }
}

