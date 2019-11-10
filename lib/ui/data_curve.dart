import 'package:flutter/material.dart';
//Offset os = Offset(0, 0); //点击曲线时，显示数值的位置
List<double> dataArray;
List<String> monthArray;

class DataCurveWidget extends StatelessWidget {
  DataCurveWidget(List<double> dList, List<String> mList) {
    dataArray = dList;
    monthArray = mList;
  }

  @override
  Widget build(BuildContext context) {
    return DataCurveHome();
  }
}

class DataCurveHome extends StatefulWidget {
  @override
  _DataCurveHomeState createState() => _DataCurveHomeState();
}

class _DataCurveHomeState extends State<DataCurveHome> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    if(dataArray == null || dataArray.length == 0) {
      return Container();
    }

    return Container(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: GestureDetector(
            child: CustomPaint(
              painter: DataCurvePainter(),
              size: Size(100 * dataArray.length.toDouble(), 500),
            ),
            onTapUp: (tapUpDetails) {
//              os = tapUpDetails.localPosition;
//              print('$os.dx');
//              setState(() {});
            },
          ),
        ));
  }
}

class DataCurvePainter extends CustomPainter {
  static var arrayLength = dataArray.length;
  var maxData = 0.0;
  List<double> monthAxisArray = List(arrayLength); //X轴坐标
  List<double> dataAxisArray = List(arrayLength); //Y轴坐标
  List<Offset> offsetArray = List(arrayLength); //坐标数组

  double monthHeight = 100.0; //空出显示日期的地方
  double dataHeight = 60.0; //空出显示数据的地方

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = Color.fromARGB(255, 255, 21, 119)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    var pxPerTime = size.width / (arrayLength + 1);
    for (int i = 0; i < monthAxisArray.length; i++) {
      monthAxisArray[i] = pxPerTime * (i + 1);
    } //这里是X轴坐标

    for (int i = 0; i < dataArray.length; i++) {
      if (dataArray[i] > maxData) {
        maxData = dataArray[i];
      }
    } //找出最大数值，确定纵坐标高度

    var pxPerData = (size.height - monthHeight - dataHeight) / maxData;
    for (int m = 0; m < dataArray.length; m++) {
      dataAxisArray[m] = size.height - dataArray[m] * pxPerData - monthHeight;
    } //这里是Y轴坐标

    for (int n = 0; n < monthAxisArray.length; n++) {
      var os = Offset(monthAxisArray[n], dataAxisArray[n]);
      offsetArray[n] = os;
    } //这里是坐标数组

    Path curvePath = new Path();
    for (int q = 0; q < monthAxisArray.length - 1; q++) {
      if (q == 0) {
        curvePath.moveTo(offsetArray[q].dx, offsetArray[q].dy);
      }
      curvePath.cubicTo(
          offsetArray[q].dx + 30,
          offsetArray[q].dy,
          offsetArray[q + 1].dx - 30,
          offsetArray[q + 1].dy,
          offsetArray[q + 1].dx,
          offsetArray[q + 1].dy);
    }

    //画个渐变矩形
    Offset offsetCenter = Offset(
        (offsetArray[0].dx + offsetArray[offsetArray.length - 1].dx) / 2,
        maxData * pxPerData / 2);
    var curveWidth = pxPerTime * (arrayLength - 1);
    var curveHeight = offsetCenter.dy * 2;
    var rectToDraw = Rect.fromCenter(
        center: offsetCenter, width: curveWidth, height: curveHeight);
    var shadowPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = Color.fromARGB(255, 255, 21, 119)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    shadowPaint.shader = LinearGradient(
            colors: [Color.fromARGB(255, 255, 21, 119), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter)
        .createShader(rectToDraw);
    shadowPaint.style = PaintingStyle.fill;

    var path = Path()
      ..moveTo(offsetArray[arrayLength - 1].dx, offsetArray[arrayLength - 1].dy)
      ..lineTo(offsetArray[arrayLength - 1].dx, size.height - monthHeight)
      ..lineTo(offsetArray[0].dx, size.height - monthHeight)
      ..lineTo(offsetArray[0].dx, offsetArray[0].dy);
    path.addPath(curvePath, Offset(0, 0));
    path.close();

    for (var i = 0; i < dataArray.length; i++) {
      var o = offsetArray[i];
      TextSpan span = TextSpan(
          text: monthArray[i],
          style: TextStyle(fontSize: 20, color: Colors.white));
      var textPainter = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.rtl);
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(o.dx - textPainter.width / 2, size.height - monthHeight));

      TextSpan span1 = TextSpan(
          text: dataArray[i].toString(),
          style: TextStyle(fontSize: 20, color: Colors.white));
      var textPainter1 = TextPainter(
          text: span1,
          textAlign: TextAlign.left,
          textDirection: TextDirection.rtl);
      textPainter1.layout();
      textPainter1.paint(
          canvas, Offset(o.dx - textPainter1.width / 2, o.dy - textPainter1.height));
    }

//    canvas.drawCircle(os, 10, paint);

    canvas.clipPath(path); //先clip，再draw
    canvas.drawRect(rectToDraw, shadowPaint);
    canvas.drawPath(curvePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
