import 'package:example/routing/app_pages.dart';
import 'package:example/services/init.dart';
import 'package:get/get.dart';

class WrapperController extends GetxController {
  @override
  void onReady() async {
    await init();
    Get.offAllNamed(Routes.home);
    super.onReady();
  }
}
