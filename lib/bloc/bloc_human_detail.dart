
import 'package:bloc/bloc.dart';
import 'package:empty_wallet/bloc/bloc_human.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main.dart' as main;

class SubHumanEvent{
  static const SHOW_SUBHUMANS = 0;
  static const ADD_SUB_HUMAN = 1;

  int method;
  HumanLoan humanLoan;
  SubHumanAddArgs2 subHumanAddArgs2;

  SubHumanEvent({this.method, this.humanLoan, this.subHumanAddArgs2});
}

class SubHumanBloc extends Bloc<SubHumanEvent, SubHumanAddArgs> {

  @override
  SubHumanAddArgs get initialState => SubHumanAddArgs.empty();

  @override
  Stream<SubHumanAddArgs> mapEventToState(SubHumanEvent event) async*{
    switch(event.method) {
      case SubHumanEvent.SHOW_SUBHUMANS:
        yield await getSubHumans(event.humanLoan);
        break;
      case SubHumanEvent.ADD_SUB_HUMAN:
        await addSubHuman(event.subHumanAddArgs2);
        yield await getSubHumans(event.subHumanAddArgs2.humanLoan);
        BlocProvider.of<HumanBloc>(main.mContext)
            .add(HumanEvent(methodId: HumanEvent.SHOW_HUMAN_LOAN));
    }
  }

  Future<SubHumanAddArgs> getSubHumans(HumanLoan humanLoan) async{
    List<SubHuman> shs = await getSubHumanByName(humanLoan.hName);
    return SubHumanAddArgs(humanLoan: humanLoan, subHumans: shs);
  }

  Future<void> addSubHuman(SubHumanAddArgs2 subHumanAddArgs2) async{
    var subHuman = SubHuman(
        sName: subHumanAddArgs2.humanLoan.hName,
        subNum: subHumanAddArgs2.num,
        loanDate: subHumanAddArgs2.date,
        paymentMethod: subHumanAddArgs2.payMethod,
        currentTotal: subHumanAddArgs2.humanLoan.hTotal + subHumanAddArgs2.num);
    await insertDate(subHuman);

    subHumanAddArgs2.humanLoan.hTotal += subHumanAddArgs2.num;
    await updateHuman(subHumanAddArgs2.humanLoan);
  }
}