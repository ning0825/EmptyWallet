import 'package:bloc/bloc.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/routes/platform_detail_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main.dart';
import 'bloc_month.dart';
import 'bloc_platform_detail.dart';
import 'bloc_subplatform.dart';

class ItemDetailEvent {
  static const SHOW_SUBITEMS = 0;
  static const CHANGE_SUBITEM_STATE = 1;

  int methodId;
  dynamic data;

  ItemDetailEvent({this.methodId, this.data});
}

class ItemDetailBloc extends Bloc<ItemDetailEvent, List<SubItem>> {
  @override
  List<SubItem> get initialState => [];

  @override
  Stream<List<SubItem>> mapEventToState(ItemDetailEvent event) async* {
    switch (event.methodId) {
      case ItemDetailEvent.SHOW_SUBITEMS:
        yield await getSIs(event.data);
        break;
      case ItemDetailEvent.CHANGE_SUBITEM_STATE:
        yield await changeSubItemState(event.data);
        //update PlatformDetailRoute
        break;
    }
  }

  Future<List<SubItem>> getSIs(Item item) async {
    return await getSubItems(item.itemName);
  }

  Future<List<SubItem>> changeSubItemState(SubItem subItem) async {
    bool z2o = subItem.isPaidOff == 0;

    //update subItem
    subItem.isPaidOff = z2o ? 1 : 0;
    updateSubItem(subItem);

    //update Item
    var item = await getItemByName(subItem.itemKey);
    item.paidStageNum += z2o ? 1 : -1;
    await updateItem(item);

    //update subPlatform
    var subPlatform = await getSubPlatform(item.platformKey, subItem.monthKey);
    subPlatform.paidNum +=
        z2o ? -subItem.numThisStage : subItem.numThisStage;
    await updateSubPlatform(subPlatform);

    //update platform
    Platform platform = await getPlatformByName(subPlatform.platformKey);
    platform.paidNum += z2o ? subItem.numThisStage : -subItem.numThisStage;
    await updatePlatform(platform);

    //update month
    Month month = await getMonth(subItem.monthKey);
    month.monthTotal += z2o ? -subItem.numThisStage : subItem.numThisStage;
    await updateMonth(month);

    BlocProvider.of<PlatformDetailBloc>(pdrContext).add(PlatformDetailEvent(methodId: PlatformDetailEvent.SHOW_PLATFORM_DETAIL));
    //update main
    BlocProvider.of<SubPlatformBloc>(mContext)
        .add(SubPlatformEvent(eventId: SubPlatformEvent.SHOW_SUBPLATFORMS));
    BlocProvider.of<MonthBloc>(mContext).add(MonthEvent.UPDATE_MONTH);

    return await getSubItems(item.itemName);
  }
}
