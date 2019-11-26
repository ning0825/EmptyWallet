import 'package:bloc/bloc.dart';
import 'package:empty_wallet/db/dbhelper.dart';
import 'package:empty_wallet/db/item_bean.dart';

enum PfRemainEvent{SHOW_PF_REMAIN}

class PfRemainBloc extends Bloc<PfRemainEvent, List<Platform>> {
  @override
  List<Platform> get initialState => [];

  @override
  Stream<List<Platform>> mapEventToState(PfRemainEvent event) async*{
    if (event == PfRemainEvent.SHOW_PF_REMAIN) {
      yield await getPfs();
    }
  }

  Future<List<Platform>> getPfs() async {
    return await getAllPlatforms();
  }
}