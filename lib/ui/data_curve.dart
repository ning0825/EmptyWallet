import 'package:flutter/material.dart';

var dataArray = [1890, 1200, 2000, 2700, 1000, 2300, 3200, 2400, 1500];
var monthArray = [
  '2019.1',
  '2019.2',
  '2019.3',
  '2019.4',
  '2019.5',
  '2019.6',
  '2019.7',
  '2019.8',
  '2019.9'
];

//Offset os = Offset(0, 0); //点击曲线时，显示数值的位置

class DataCurveWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: GestureDetector(
            child: CustomPaint(
              painter: DataCurvePainter(),
              size: Size(1000, 500),
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
  var maxData = 0;
  List<double> timeArrayAxis = List(9); //X轴坐标
  List<double> dataArrayAxis = List(9); //Y轴坐标
  List<Offset> offsetArray = List(9); //坐标数组

  double dateHeight = 30.0; //空出显示日期的地方

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = Color.fromARGB(255, 255, 21, 119)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    var pxPerTime = size.width / 10;
    for (int i = 0; i < timeArrayAxis.length; i++) {
      timeArrayAxis[i] = pxPerTime * (i + 1);
    } //这里是X轴坐标

    for (int j = 0; j < dataArray.length; j++) {
      if (dataArray[j] > maxData) {
        maxData = dataArray[j];
      }
    } //找出最大数值，确定纵坐标高度

    var pxPerData = size.height / maxData;
    for (int m = 0; m < dataArray.length; m++) {
      dataArrayAxis[m] = size.height - dataArray[m] * pxPerData;
    } //这里是Y轴坐标

    for (int n = 0; n < timeArrayAxis.length; n++) {
      var os = Offset(timeArrayAxis[n], dataArrayAxis[n]);
      offsetArray[n] = os;
    } //这里是坐标数组

    Path curvePath = new Path();
    for (int q = 0; q < timeArrayAxis.length - 1; q++) {
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
    var curveWidth = pxPerTime * 8;
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
      ..moveTo(offsetArray[8].dx, offsetArray[8].dy)
      ..lineTo(offsetArray[8].dx, size.height - 110)
      ..lineTo(offsetArray[0].dx, size.height - 110)
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
          canvas, Offset(o.dx - textPainter.width / 2, size.height - 110));
    }

//    canvas.drawCircle(os, 10, paint);

    canvas.clipPath(path); //先clip，再draw
    canvas.drawRect(rectToDraw, shadowPaint);
    canvas.drawPath(curvePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
