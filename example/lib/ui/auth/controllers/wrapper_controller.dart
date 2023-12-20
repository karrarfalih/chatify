import 'package:example/routing/app_pages.dart';
import 'package:example/services/init.dart';
import 'package:example/ui/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class WrapperController extends GetxController {
  @override
  void onReady() async {
    await init();
    final authController = Get.find<AuthController>();
    if (authController.isAuthorised) {
      authController.init();
    } else {
      Get.offAllNamed(Routes.login);
    }
    super.onReady();
  }
}
