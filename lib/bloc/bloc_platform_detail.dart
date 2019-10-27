import 'package:bloc/bloc.dart';
import 'package:empty_wallet/bloc/bloc_month.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/tool/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../main.dart';
import 'bloc_subplatform.dart';

class PlatformDetailEvent {
  static const SHOW_PLATFORM_DETAIL = 0;
  static const ADD_ITEM = 1;

  int methodId;
  Platform pf;
  ItemAddArgs itemAddArgs;

  PlatformDetailEvent({@required this.methodId, this.pf, this.itemAddArgs});
}

class PlatformDetailBloc extends Bloc<PlatformDetailEvent, PlatformDetail> {
  @override
  PlatformDetail get initialState => PlatformDetail.empty();

  @override
  Stream<PlatformDetail> mapEventToState(PlatformDetailEvent event) async* {
    switch (event.methodId) {
      case PlatformDetailEvent.SHOW_PLATFORM_DETAIL:
        yield await getPlatformDetail(event.pf);
        break;
      case PlatformDetailEvent.ADD_ITEM:
        await _addItem(event.itemAddArgs);
        yield await getPlatformDetail(event.itemAddArgs.platform);
        BlocProvider.of<SubPlatformBloc>(mContext)
            .add(SubPlatformEvent(eventId: SubPlatformEvent.SHOW_SUBPLATFORMS));
        BlocProvider.of<MonthBloc>(mContext).add(MonthEvent.UPDATE_MONTH);
        break;
    }
  }

  //instantiate a PlatformDetail base on subPlatform
  Future<PlatformDetail> getPlatformDetail(Platform pf) async{
    var now = DateTime.now();
    var nowString = now.year.toString() + '.' + now.month.toString();
    var subPlatform = await getSubPlatform(pf.platformName, nowString);
    var items = await getItems(pf.platformName);
    return PlatformDetail(pf, subPlatform, items);
  }

  Future<void> _addItem(ItemAddArgs iaas) async {
    var itemTag = DateTime.now().toString();

    //insert item.
    insertDate(Item(
        platformKey: iaas.platform.platformName,
        stageNum: iaas.itemSN,
        numPerStage: iaas.itemNPS,
        itemName: itemTag));

    var nowTime = DateTime.now();

    for (int i = 0; i < iaas.itemSN; i++) {
      var s = nowTime.year.toString() + '.' + nowTime.month.toString();

      //insertSubItem
      insertDate(SubItem(
          itemKey: itemTag,
          monthKey: s,
          numThisStage: iaas.itemNPS,
          currentStage: i + 1));

      //UpdateMonth
      Month m = await getMonth(s);
      if(m == null) {
        insertDate(Month(month: s, monthTotal: iaas.itemNPS));
      } else {
        //m != null
        m.monthTotal += iaas.itemNPS;
        await updateMonth(m);
      }

      //update subplatform
      var sp = await getSubPlatform(iaas.platform.platformName,  s);
      sp.numThisStage += iaas.itemNPS;
      updateSubPlatform(sp);

      nowTime =
          nowTime.add(Duration(days: dayInMonth(nowTime.year, nowTime.month)));
    }
    //update platform
    iaas.platform.totalNum += iaas.itemNPS * iaas.itemSN;
    updatePlatform(iaas.platform);
  }
}


