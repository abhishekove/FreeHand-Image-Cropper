import 'dart:ui';

import 'package:flutter/material.dart';

class MyClipper extends CustomClipper<Path> {
  final List<Offset> pointsList;
  List<Offset> offsetList = [];

  MyClipper({required this.pointsList});
  @override
  Path getClip(Size size) {
    Path path = new Path();
    for (int i = 0; i < pointsList.length; i++) {
      offsetList.add(pointsList[i]);
    }
    if (offsetList.isNotEmpty) path.moveTo(offsetList[0].dx, offsetList[0].dy);
    for (int i = 1; i < offsetList.length; i++) {
      path.lineTo(offsetList[i].dx, offsetList[i].dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    throw false;
  }
}
