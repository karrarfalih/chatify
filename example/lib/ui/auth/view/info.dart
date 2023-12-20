import 'package:example/theme/app_colors.dart';
import 'package:example/ui/auth/controllers/auth_controller.dart';
import 'package:example/ui/common/image.dart';
import 'package:example/utilz/upload_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kr_button/kr_button.dart';

class AddInfoScreen extends StatefulWidget {
  const AddInfoScreen({super.key});

  @override
  State<AddInfoScreen> createState() => _AddInfoScreenState();
}

class _AddInfoScreenState extends State<AddInfoScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  String? imageUrl;
  bool isUploading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var outlineInputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            children: [
              ListView(
                children: [
                  SizedBox(height: 30),
                  Center(
                    child: Text(
                      'Your info',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Enter your name and add profile picture',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        StatefulBuilder(
                          builder: (context, setState) {
                            return GestureDetector(
                              onTap: () async {
                                setState(() => isUploading = true);
                                try {
                                  final url = await getPhoto();
                                  if (url != null) {
                                    setState(() {
                                      imageUrl = url;
                                    });
                                  }
                                } finally {
                                  setState(() => isUploading = false);
                                }
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: 90,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade200,
                                    ),
                                    child: imageUrl == null
                                        ? Icon(
                                            Iconsax.camera,
                                            size: 32,
                                          )
                                        : CustomImage(
                                            fit: BoxFit.cover,
                                            radius: 90,
                                            url: imageUrl,
                                            onLoading: SizedBox(),
                                          ),
                                  ),
                                  if (isUploading)
                                    SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: firstNameController,
                          readOnly: false,
                          showCursor: true,
                          autofocus: true,
                          onTap: () => setState(() {}),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            inherit: false,
                            textBaseline: TextBaseline.alphabetic,
                            backgroundColor: Colors.white,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'First name',
                            labelStyle: TextStyle(color: Colors.grey.shade500),
                            border: outlineInputBorder,
                            enabledBorder: outlineInputBorder,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: lastNameController,
                          readOnly: false,
                          showCursor: true,
                          onTap: () => setState(() {}),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            inherit: false,
                            textBaseline: TextBaseline.alphabetic,
                            backgroundColor: Colors.white,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Last name (optional)',
                            labelStyle: TextStyle(color: Colors.grey.shade500),
                            border: outlineInputBorder,
                            enabledBorder: outlineInputBorder,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: KrTextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () async {
                      await Get.find<AuthController>().submitUserInfo(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        image: imageUrl,
                      );
                    },
                    onLoading: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
