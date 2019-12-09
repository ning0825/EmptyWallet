import 'package:bloc/bloc.dart';
import 'package:empty_wallet/bloc/bloc_month.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:empty_wallet/tool/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../main.dart';
import 'bloc_platform.dart';
import 'bloc_subplatform.dart';

class PlatformDetailEvent {
  static const SHOW_PLATFORM_DETAIL = 0;
  static const ADD_ITEM = 1;
  static const CHANGE_ITEM_STATE = 2;

  int methodId;
  Platform pf;
  ItemAddArgs itemAddArgs;
  SubItem subItem;

  PlatformDetailEvent(
      {@required this.methodId, this.pf, this.itemAddArgs, this.subItem});
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
        BlocProvider.of<PfRemainBloc>(mContext)
            .add(PfRemainEvent.SHOW_PF_REMAIN);
        break;

      case PlatformDetailEvent.CHANGE_ITEM_STATE:
        await _changeItemState(event.subItem);
        yield await getPlatformDetail(event.pf);
        BlocProvider.of<SubPlatformBloc>(mContext)
            .add(SubPlatformEvent(eventId: SubPlatformEvent.SHOW_SUBPLATFORMS));
        BlocProvider.of<MonthBloc>(mContext).add(MonthEvent.UPDATE_MONTH);
        BlocProvider.of<PfRemainBloc>(mContext)
            .add(PfRemainEvent.SHOW_PF_REMAIN);
        break;
    }
  }

  //instantiate a PlatformDetail base on subPlatform
  Future<PlatformDetail> getPlatformDetail(Platform pf) async {
    var now = DateTime.now();
    var nowString = now.year.toString() + '.' + now.month.toString();
    var subPlatform = await getSubPlatform(pf.platformName, nowString);
    var items = await getItems(pf.platformName);
    List<SubItem> subItems = [];
    for (var o in items) {
      var si = await getSubItem(o.itemName, subPlatform.monthKey);
      if (si != null) {
        subItems.add(si);
      }
    }
    return PlatformDetail(pf, subPlatform, subItems);
  }

  Future<void> _addItem(ItemAddArgs iaas) async {
    var itemTag = DateTime.now().toString();

    //insert item.
    insertDate(Item(
        platformKey: iaas.platform.platformName,
        stageNum: iaas.itemSN,
        numPerStage: iaas.itemNPS,
        itemName: itemTag,
        dueDate:
            iaas.firstDate.split('.')[2]));

    List<String> firstDateList = iaas.firstDate.split('.');

    var nowTime = DateTime(int.parse(firstDateList[0]),
        int.parse(firstDateList[1]), int.parse(firstDateList[2]));

    for (int i = 0; i < iaas.itemSN; i++) {
      var s = nowTime.year.toString() + '.' + nowTime.month.toString();

      //insertSubItem
      insertDate(SubItem(
          itemKey: itemTag,
          monthKey: s,
          numThisStage: iaas.itemNPS,
          currentStage: i + 1,
          totalStages: iaas.itemSN,
          dueDay: nowTime.year.toString() +
              '.' +
              nowTime.month.toString() +
              '.' +
              nowTime.day.toString()));

      //UpdateMonth
      Month m = await getMonth(s);
      if (m == null) {
        insertDate(Month(month: s, monthTotal: iaas.itemNPS));
      } else {
        m.monthTotal += iaas.itemNPS;
        await updateMonth(m);
      }

      //update subplatform
      var sp = await getSubPlatform(iaas.platform.platformName, s);
      if (sp == null) {
        sp = SubPlatform(
            monthKey: nowTime.year.toString() + '.' + nowTime.month.toString(),
            platformKey: iaas.platform.platformName,
            numThisStage: 0, 
            dateThisStage: nowTime.day.toString());
        int i = await insertDate(sp);
        sp.id = i;
      }
      sp.numThisStage += iaas.itemNPS;
      updateSubPlatform(sp);
      nowTime =
          nowTime.add(Duration(days: dayInMonth(nowTime.year, nowTime.month)));
    }
    //update platform
    iaas.platform.totalNum += iaas.itemNPS * iaas.itemSN;
    updatePlatform(iaas.platform);
  }

  Future<void> _changeItemState(SubItem subItem) async {
    bool z2o = subItem.isPaidOff == 0;

    //update SubItem
    subItem.isPaidOff = z2o ? 1 : 0;
    await updateSubItem(subItem);

    //update Item
    Item item = await getItemByName(subItem.itemKey);
    item.paidStageNum += z2o ? 1 : -1;
    await updateItem(item);

    //update subPlatform
    SubPlatform subPlatform =
        await getSubPlatform(item.platformKey, subItem.monthKey);
    subPlatform.paidNum += z2o ? subItem.numThisStage : -subItem.numThisStage;

    List<Item> items = await getItems(subPlatform.platformKey);
    List<SubItem> subItems = [];
    int paidOffThisSubPlatform = 1;
    for (var o in items) {
      subItems.add(await getSubItem(o.itemName, subPlatform.monthKey));
    }
    
    //只要有一个subItem没还，则subPlatform没还清
    for (var o in subItems) {
      if (o.isPaidOff == 0) {
        paidOffThisSubPlatform = 0;
      }
    }
    subPlatform.isPaidOff = paidOffThisSubPlatform;
    await updateSubPlatform(subPlatform);

    //update Platform
    Platform platform = await getPlatformByName(subPlatform.platformKey);
    platform.paidNum += z2o ? subItem.numThisStage : -subItem.numThisStage;
    await updatePlatform(platform);

    //update month
    Month month = await getMonth(subItem.monthKey);
    month.monthTotal -= z2o ? subItem.numThisStage : -subItem.numThisStage;
    await updateMonth(month);
  }
}
