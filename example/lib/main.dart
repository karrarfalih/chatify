import 'package:example/firebase/datasource.dart';
import 'package:example/routing/app_pages.dart';
import 'package:example/theme/app_colors.dart';
import 'package:example/ui/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'IQ Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        primaryColor: AppColors.primary,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialBinding: BindingsBuilder(() {
        Get.lazyPut(() => Datasource(), fenix: true);
        Get.lazyPut(() => AuthController(Get.find()), fenix: true);
      }),
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("en", "US"),
        Locale("ar", "IQ"),
      ],
      locale: Locale('en'),
      getPages: AppPages.pages,
      initialRoute: AppPages.initial,
    );
  }
}
