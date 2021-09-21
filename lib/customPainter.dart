import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MyImagePainter extends CustomPainter {
  ui.Image image;
  int height;
  final bool crop;
  final BuildContext context;
  MyImagePainter(
      {required this.image,
      required this.pointsList,
      required this.height,
      required this.crop,
      required this.context});
  final List<Offset> pointsList;
  double angle = 1.5686;
  List<Offset> offsetList = [];
  @override
  void paint(Canvas canvas, Size size) async {
    canvas.drawImage(image, new Offset(0.0, 0.0), new Paint());
    offsetList.clear();
    for (int i = 0; i < pointsList.length; i++) {
      offsetList.add(pointsList[i]);
    }
    if (pointsList.length > 0 && !crop) {
      canvas.drawPoints(
          PointMode.polygon,
          offsetList,
          Paint()
            ..strokeWidth = 3.0
            ..color = Colors.white
            ..strokeCap = StrokeCap.round);
      canvas.drawLine(
          offsetList[0],
          offsetList[offsetList.length - 1],
          Paint()
            ..strokeWidth = 3.0
            ..color = Colors.white
            ..strokeCap = StrokeCap.round);

      canvas.drawPoints(
          PointMode.points,
          offsetList,
          Paint()
            ..strokeWidth = 20 * (image.height / height)
            ..strokeCap = StrokeCap.round
            ..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
