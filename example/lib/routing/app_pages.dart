import 'package:example/ui/auth/controllers/wrapper_controller.dart';
import 'package:example/ui/auth/view/login.dart';
import 'package:example/ui/auth/view/info.dart';
import 'package:example/ui/auth/view/wrapper.dart';
import 'package:example/ui/home/controllers/home_controller.dart';
import 'package:example/ui/home/view/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.wrapper;

  static final List<GetPage> pages = [
    GetPage(
      name: Routes.wrapper,
      binding: BindingsBuilder.put(() => WrapperController(), permanent: true),
      page: () => const Wrapper(),
    ),
    GetPage(
      name: Routes.home,
      binding: BindingsBuilder.put(() => HomeController()),
      page: () => const HomeScreen(),
      middlewares: [WrapperMiddleware()],
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      middlewares: [WrapperMiddleware()],
    ),
    GetPage(
      name: Routes.info,
      page: () => const AddInfoScreen(),
    ),
  ];
}

class WrapperMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (Get.isRegistered<WrapperController>() || route == Routes.wrapper) {
      return null;
    }
    return RouteSettings(
      name: Routes.wrapper,
      arguments: route,
    );
  }
}
