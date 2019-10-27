import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:flutter/cupertino.dart';

//A base class provided to be inherited by other event class.
class SubPlatformEvent {
  static const SHOW_SUBPLATFORMS = 0;

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
      }
    }
  }

  //程序初始化，显示主界面列表
  Future<List<SubPlatform>> getSubPlatforms() async {
    await openDB();
    var nowTime = DateTime.now();
    var monthKey = nowTime.year.toString() + '.' + nowTime.month.toString();
    return await getSubPlatformsByMonth(monthKey);
  }
}
