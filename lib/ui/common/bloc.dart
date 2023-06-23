
import 'package:flutter/material.dart';

class MyBlock extends StatelessWidget {

  final double height;
  final double width;
  final double space;
  final double radius;

  const MyBlock({super.key, required this.height, required this.width, this.space = 0, this.radius = 5});



  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.only(bottom: space),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius)
      ),
    );
  }
}

