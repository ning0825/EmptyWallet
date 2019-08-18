class Item {
  String name;
  double num;
  int fen;  //true:0, false:1
  String dateTime;

  Item({this.name, this.num, this.fen = 1, this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'name':name,
      'num':num,
      'fen':fen,
      'dateTime':dateTime,
    };
  }
}