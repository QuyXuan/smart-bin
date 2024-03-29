import 'dart:convert';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/services/api_service.dart';
import 'package:eco_app/common/utils/common_colors.dart';
import 'package:eco_app/common/widgets/custom_alert_dialog.dart';
import 'package:eco_app/common/widgets/custom_elevated_button.dart';
import 'package:eco_app/common/widgets/custom_icon_button.dart';
import 'package:eco_app/common/widgets/custom_text_style.dart';
import 'package:eco_app/common/widgets/show_h_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  File? filePath;
  File? imageCamera;
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ref.read(apiServiceProvider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  imagePickerIcon(
      {required VoidCallback onTap,
      required IconData icon,
      required String text}) {
    return Column(
      children: [
        CustomIconButton(
          onPressed: onTap,
          icon: icon,
          iconColor: CommonColors.darkGreen,
          minWidth: 50,
          border: Border.all(
            color: CommonColors.grey.withOpacity(0.8),
            width: 1,
          ),
        ),
        const SizedBox(height: 5),
        ContentText(text),
      ],
    );
  }

  pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    var imageMap = File(image.path);
    setState(() {
      filePath = imageMap;
    });
    if (mounted) {
      Navigator.pop(context);
    }
  }

  imagePickerTypeBottomSheet() {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.modalBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShortHBar(
                color: context.theme.darkGreen,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: HeadlineText(
                  "Profile photo",
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  imagePickerIcon(
                    onTap: pickImageFromCamera,
                    icon: Icons.camera_alt_rounded,
                    text: "Camera",
                  ),
                  const SizedBox(width: 50),
                  imagePickerIcon(
                    onTap: () {
                      pickImageGallery();
                    },
                    icon: Icons.photo_camera_back_rounded,
                    text: "Gallery",
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  pickImageFromCamera() async {
    Navigator.of(context).pop();
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      setState(() {
        imageCamera = File(image!.path);
      });
    } catch (e) {
      // log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: screenSize.height * 0.7,
                  width: screenSize.width * 0.8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CommonColors.greenDark,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: filePath == null
                        ? Image.asset(
                            'assets/images/upload.jpg',
                            fit: BoxFit.fill,
                          )
                        : Image.file(
                            filePath!,
                            fit: BoxFit.fill,
                          ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  right: screenSize.width * 0.5 - 80 + 2,
                  child: GestureDetector(
                    onTap: imagePickerTypeBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFececec),
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.cameraRetro,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            CustomElevatedButton(
              onPressed: () {
                if (filePath == null) {
                  AnimatedSnackBar.material(
                    'Choose an image first!',
                    type: AnimatedSnackBarType.warning,
                    mobileSnackBarPosition: MobileSnackBarPosition.bottom,
                    duration: const Duration(seconds: 2),
                    animationCurve: Curves.linearToEaseOut,
                    snackBarStrategy: RemoveSnackBarStrategy(),
                  ).show(context);
                  return;
                }
                filePath!.readAsBytes().then((imageBytes) {
                  String imageBase64 = base64Encode(imageBytes);
                  apiService.dioPredictImage(imageBase64).then((response) {
                    if (response['success'] != false) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomAlertDialog(
                            contentWidget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.check,
                                  color: Color(0xFFf87168),
                                  size: 50,
                                ),
                                const SizedBox(height: 10),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'That image can be a ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: response['prediction'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ', with accuracy: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: response['accuracy'].toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            hasCloseButton: true,
                            hasOKButton: true,
                            okButtonText: 'Save',
                          );
                        },
                      );
                    } else {
                      AnimatedSnackBar.material(
                        'Error',
                        type: AnimatedSnackBarType.error,
                        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
                        duration: const Duration(seconds: 2),
                        animationCurve: Curves.linearToEaseOut,
                        snackBarStrategy: RemoveSnackBarStrategy(),
                      ).show(context);
                    }
                  });
                });
              },
              icon: const FaIcon(
                FontAwesomeIcons.wandMagicSparkles,
                color: Colors.white,
              ),
              text: "Predict Image",
            )
          ],
        ),
      ),
    );
  }
}
