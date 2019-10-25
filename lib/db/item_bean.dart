import 'dart:core';
import 'package:flutter/material.dart';

//
//class MonthItem {
//  String monthString;
//  String itemsInMonth;
//
//  MonthItem({this.monthString, this.itemsInMonth});
//
//  Map<String, dynamic> toMap() {
//    return {'monthString': monthString, 'ItemInMonth': itemsInMonth};
//  }
//}

class Platform {
  int id;
  String platformName;
  String dueDate;
  double totalNum;

  Platform({@required this.platformName,
    @required this.dueDate,
    this.totalNum = 0.0,
    this.id});

  Map<String, dynamic> toMap() {
    return {
      'platformName': platformName,
      'dueDate': dueDate,
      'totalNum': totalNum
    };
  }

  static Platform mapTo(Map<String, dynamic> map) {
    return Platform(
        id: map['id'],
        platformName: map['platformName'],
        dueDate: map['dueDate'],
        totalNum: map['totalNum']);
  }

  @override
  String toString() {
    return 'Platform Info: id:[$id], platformName:[$platformName], dueDate:[$dueDate], totalNum:[$totalNum]';
  }
}

class SubPlatform {
  int id;
  String monthKey;
  String platformKey;
  double numThisStage;
  int isPaidOff;

  SubPlatform({this.id,
    @required this.monthKey,
    @required this.platformKey,
    @required this.numThisStage,
    this.isPaidOff = 0});

  Map<String, dynamic> toMap() {
    return {
      'monthKey': monthKey,
      'platformKey': platformKey,
      'numThisStage': numThisStage,
      'isPaidOff': isPaidOff
    };
  }

  static SubPlatform mapTo(Map<String, dynamic> map) {
    return SubPlatform(
        id: map['id'],
        monthKey: map['monthKey'],
        platformKey: map['platformKey'],
        numThisStage: map['numThisStage'],
        isPaidOff: map['isPaidOff']);
  }

  @override
  String toString() {
    return 'SubPlatform Info: id:[$id], monthKey:[$monthKey], platformKey:[$platformKey], numThisStage:[$numThisStage], isPaidOff:[$isPaidOff]';
  }
}

class Item {
  int id;
  String platformKey;
  int stageNum;
  double numPerStage;
  String itemName;
  int paidStageNum;

  Item({this.id,
    @required this.platformKey,
    @required this.stageNum,
    @required this.numPerStage,
    @required this.itemName,
    this.paidStageNum: 0});

  Map<String, dynamic> toMap() {
    return {
      'platformKey': platformKey,
      'stageNum': stageNum,
      'numPerStage': numPerStage,
      'itemName': itemName,
      'paidStageNum': paidStageNum
    };
  }

  static Item mapTo(Map<String, dynamic> map) {
    return Item(
        id: map['id'],
        platformKey: map['platformKey'],
        stageNum: map['stageNum'],
        numPerStage: map['numPerStage'],
        itemName: map['itemName'],
        paidStageNum: map['paidStageNum']);
  }

  @override
  String toString() {
    return 'Item Info: id:[$id], platformKey:[$platformKey], stageNum:[$stageNum], numPerStage:[$numPerStage], itemName:[$itemName], paidStageNum:[$paidStageNum]';
  }
}

class SubItem {
  int id;
  String itemKey;
  String monthKey;
  double numThisStage;
  int currentStage;

  SubItem({this.id,
    @required this.itemKey,
    @required this.monthKey,
    @required this.numThisStage,
    @required this.currentStage});

  Map<String, dynamic> toMap() {
    return {
      'itemKey': itemKey,
      'monthKey': monthKey,
      'numThisStage': numThisStage,
      'currentStage': currentStage
    };
  }

  static SubItem mapTo(Map<String, dynamic> map) {
    return SubItem(
        id: map['id'],
        itemKey: map['itemKey'],
        monthKey: map['monthKey'],
        numThisStage: map['numThisStage'],
        currentStage: map['currentStage']);
  }

  @override
  String toString() {
    return 'SubPlatform Info: id:[$id], itemKey:[$itemKey], monthKey:[$monthKey], numThisStage:[$numThisStage], currentStage:[$currentStage]';
  }
}

class HumanLoan {
  int id;
  String hName;
  double hTotal;
  double hPaid;
  double hNotPaid;

  HumanLoan({
    this.id,
    @required this.hName,
    @required this.hTotal,
    this.hPaid = 0.0,
    this.hNotPaid = 0.0
  });

  Map<String, dynamic> toMap() {
    return {
      'hName': hName,
      'hTotal': hTotal,
      'hPaid': hPaid,
      'hNotPaid': hNotPaid
    };
  }

  static HumanLoan mapTo(Map<String, dynamic> map) {
    return HumanLoan(id: map['id'],
        hName: map['hName'],
        hTotal: map['hTotal'],
        hPaid: map['hPaid'],
        hNotPaid: map['hNotPaid']);
  }

  String toString() {
    return 'HumanLoan Info: id:[$id], hName:[$hName], hTotal:[$hTotal], hPaid:[$hPaid], hNotPaid:[$hNotPaid]';
  }
}

class SubHuman {
  int id;
  String sName;
  double subNum;
  String loanDate;
  //0: wechat 1:zhifubao 2: cash(use this if forget)
  int paymentMethod;
  double currentTotal;

  SubHuman({this.id, @required this.sName, @required this.subNum, @required this.loanDate, @required this.paymentMethod, @required this.currentTotal});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sName': sName,
      'subNum': subNum,
      'loanDate': loanDate,
      'paymentMethod': paymentMethod,
      'currentTotal': currentTotal
    };
  }

  static SubHuman mapTo(Map<String, dynamic> map) {
    return SubHuman(sName: map['sName'], subNum: map['subNum'], loanDate: map['loanDate'], paymentMethod: map['paymentMethod'], currentTotal: map['currentTotal']);
  }

  String toString() {
    return 'SubHuman Info: id: [$id], sName: [$sName], subNum: [$subNum], loanDate: [$loanDate], paymentMethod: [$paymentMethod], currentTotal: [$currentTotal]';
  }
}

class PlatformDetail {
  Platform pf;
  SubPlatform spf;
  List<Item> its;

  PlatformDetail(this.pf, this.spf, this.its);

  PlatformDetail.empty();
}

class ItemAddArgs {
  Platform platform;
  SubPlatform subPlatform;
  int itemSN;//分期数
  double itemNPS;

  ItemAddArgs(this.platform, this.subPlatform, this.itemSN,
      this.itemNPS); //每期数目

  ItemAddArgs.empty();
}

class SubHumanAddArgs{
  HumanLoan humanLoan;
  List<SubHuman> subHumans;

  SubHumanAddArgs({this.humanLoan, this.subHumans});

  SubHumanAddArgs.empty();
}

class SubHumanAddArgs2{
  HumanLoan humanLoan;
  double num;
  String date;
  int payMethod;

  SubHumanAddArgs2({this.humanLoan, this.num, this.date, this.payMethod});

  SubHumanAddArgs2.empty();
}
