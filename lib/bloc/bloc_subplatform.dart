import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:flutter/cupertino.dart';

//A base class provided to be inherited by other event class.
class SubPlatformEvent {
  static const SHOW_SUBPLATFORMS = 0;
  static const CHANGE_PAY_STATE = 1;

  ///[eventId] An ID to distinguish different events. See full list above.
  int eventId;
  //todo $data is unused, consider to remove.
  SubPlatform data;

  SubPlatformEvent({@required this.eventId, this.data});
}

//Show SubPlatforms in main page.
class SubPlatformBloc extends Bloc<SubPlatformEvent, List<SubPlatform>> {
  @override
  List<SubPlatform> get initialState => [];

  @override
  Stream<List<SubPlatform>> mapEventToState(event) async* {
    //todo condition judgment is not needed anymore if remove data above.
    if(event is SubPlatformEvent) {
      switch(event.eventId) {
        //show SubPlatforms.
        case SubPlatformEvent.SHOW_SUBPLATFORMS:
          var dat = await getSubPlatforms();
          yield dat;
          break;
        case SubPlatformEvent.CHANGE_PAY_STATE:
          var data = event.data;
          await changePayState(data);
          yield await getSubPlatforms();
          break;
      }
    }
  }

  //程序初始化，显示主界面列表
  Future<List<SubPlatform>> getSubPlatforms() async {
    await openDB();
    var nowTime = DateTime.now();
    var monthKey = nowTime.year.toString() + '.' + nowTime.month.toString();
    List<SubPlatform> list =  await getSubPlatformsByMonth(monthKey);
    return list;
  }

  Future<void> changePayState(SubPlatform sp) async{
    bool z2o;//0 to 1

    //update SubPlatform
    z2o = sp.isPaidOff == 0;
    z2o ? sp.isPaidOff = 1 : sp.isPaidOff = 0;
    await updateSubPlatform(sp);

    List<Item> items = await getItems(sp.platformKey);
    for (var o in items) {
      //update Item
      o.paidStageNum += z2o ? 1 : -1;
      await updateItem(o);

      //update SubItem
      SubItem subItem = await getSubItem(o.itemName, sp.monthKey);
      subItem.isPaidOff = z2o ? 1 : 0;
      await updateSubItem(subItem);
    }

    //update platform
    Platform pf = await getPlatformByName(sp.platformKey);
    pf.paidNum += z2o ? sp.numThisStage : -sp.numThisStage;
    await updatePlatform(pf);
  }
}
