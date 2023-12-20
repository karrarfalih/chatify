library numeric_keyboard;

import 'dart:async';

import 'package:example/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class NumericKeyboard extends StatelessWidget {
  const NumericKeyboard({
    Key? key,
    this.controller,
    this.focusNode,
    required this.onChanged,
  }) : super(key: key);

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 20),
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _calcButton('1', ''),
              _calcButton('2', 'ABC'),
              _calcButton('3', 'DEF'),
            ],
          ),
          Row(
            children: <Widget>[
              _calcButton('4', 'GHI'),
              _calcButton('5', 'JKL'),
              _calcButton('6', 'MNO'),
            ],
          ),
          Row(
            children: <Widget>[
              _calcButton('7', 'PQRS'),
              _calcButton('8', 'TUV'),
              _calcButton('9', 'WXYZ'),
            ],
          ),
          Row(
            children: <Widget>[
              Spacer(),
              _calcButton('0', '+'),
              _deleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcButton(String value, String letters) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: TextButton(
          onPressed: () {
            onChanged(value);
            Vibration.hasVibrator().then((canVibrate) {
              if (canVibrate == true)
                Vibration.vibrate(duration: 5, amplitude: 100);
            });
          },
          style: TextButton.styleFrom(
            backgroundColor: AppColors.lightGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
          ),
          child: Container(
            alignment: Alignment.center,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(color: Colors.black, fontSize: 22),
                ),
                Text(
                  letters,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Timer? timer;

  Widget _deleteButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: GestureDetector(
          onTap: () {
            onChanged('x');
            Vibration.hasVibrator().then((canVibrate) {
              if (canVibrate == true)
                Vibration.vibrate(duration: 5, amplitude: 100);
            });
          },
          onLongPressCancel: () => timer?.cancel(),
          onLongPressStart: (details) {
            timer = Timer.periodic(Duration(milliseconds: 120), (timer) {
              onChanged('x');
              Vibration.hasVibrator().then((canVibrate) {
                if (canVibrate == true)
                  Vibration.vibrate(duration: 5, amplitude: 100);
              });
            });
          },
          onLongPressEnd: (_) => timer?.cancel(),
          onLongPressUp: () => timer?.cancel(),
          child: Container(
            alignment: Alignment.center,
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColors.lightGrey,
            ),
            child: Icon(
              CupertinoIcons.delete_left_fill,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
