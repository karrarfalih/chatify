import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class NewDataMessage extends StatelessWidget {
  const NewDataMessage({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              DateFormat('d MMM').format(date),
              style:
                  const TextStyle(fontSize: 12, color: Colors.black, height: 1),
            ),
          ),
        ),
      ),
    );
  }
}
