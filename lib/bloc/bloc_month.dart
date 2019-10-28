import 'package:bloc/bloc.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';

class MonthArgs {
  List<String> monthList;
  List<double> dataList;

  MonthArgs({this.monthList, this.dataList});
}

enum MonthEvent { UPDATE_MONTH }

class MonthBloc extends Bloc<MonthEvent, MonthArgs> {
  @override
  // TODO: 构造参数既然是Optional，还特么用啥empty。
  MonthArgs get initialState => MonthArgs();

  @override
  Stream<MonthArgs> mapEventToState(MonthEvent event) async*{
    yield await getCurveData();
  }

  Future<MonthArgs> getCurveData() async {
    List<String> monthArray = [];
    List<double> dataArray = [];

    List<Month> list = await getMonths();
    for (var o in list) {
      dataArray.add(o.monthTotal);
      monthArray.add(o.month);
    }
    return MonthArgs(monthList: monthArray, dataList: dataArray);
  }
}
