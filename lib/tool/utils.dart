//获取指定月份的天数
var dayOfMonth = [31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
int dayInMonth(int year, int month) {
  if (month != 2) {
    return dayOfMonth[month - 1];
  } else {
    return year % 4 == 0 ? 29 : 28;
  }
}

//根据当前月份和分期数，返回分期时间内所有月份的列表
List<String> getMonthList(DateTime dateTime, int stageNum) {
  List<String> list = List(stageNum);
  var nowTime = dateTime;
  for (int i = 0; i < stageNum; i++) {
    var s = nowTime
        .year
        .toString() +
        '.' +
        nowTime.month
            .toString();

    list[i] = s;

    nowTime = nowTime = nowTime.add(Duration(
        days: dayInMonth(nowTime.year, nowTime.month)));
  }
  return list;
}


