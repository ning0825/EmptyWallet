import 'package:bloc/bloc.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:flutter/cupertino.dart';

class HumanEvent{
  static const SHOW_HUMAN_LOAN = 0;
  static const ADD_HUMAN_ITEM = 1;

  int methodId;

  HumanEvent({@required this.methodId});
}

class HumanBloc extends Bloc<HumanEvent, List<HumanLoan>>{
  @override
  List<HumanLoan> get initialState => [];

  @override
  Stream<List<HumanLoan>> mapEventToState(HumanEvent event) async*{
    switch(event.methodId) {
      case HumanEvent.SHOW_HUMAN_LOAN:
        yield await getHls();
        break;
      case HumanEvent.ADD_HUMAN_ITEM:
        break;
    }
  }
}