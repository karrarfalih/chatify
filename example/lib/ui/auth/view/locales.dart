import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneLocale {
  final String code;
  final String image;
  final String name;

  const PhoneLocale({
    required this.code,
    required this.image,
    required this.name,
  });
}

const locales = [
  PhoneLocale(code: '964', image: 'assets/images/iraq.png', name: 'Iraq'),
];

class LocalesScreen extends StatelessWidget {
  const LocalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a country'),
      ),
      body: ListView(
        children: [
          Divider(
            color: Colors.grey.shade200,
          ),

          ...locales.map((e) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
              onPressed: () => Get.back(result: e.code),
              child: Row(
                children: [
                  Image.asset(
                    e.image,
                    height: 13,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    e.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  Text('+${e.code}'),
                ],
              ),
            ),
          ),)
          
        ],
      ),
    );
  }
}
