import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/helpers/show_loading_dialog.dart';
import 'package:eco_app/common/models/predict_item.dart';
import 'package:eco_app/common/services/api_service.dart';
import 'package:eco_app/common/services/predict_service.dart';
import 'package:eco_app/common/utils/common_colors.dart';
import 'package:eco_app/common/widgets/custom_alert_dialog.dart';
import 'package:eco_app/common/widgets/custom_icon_button.dart';
import 'package:eco_app/common/widgets/custom_text_style.dart';
import 'package:eco_app/common/widgets/show_h_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  File? filePath;
  File? imageCamera;
  late ApiService apiService;
  final PredictService _predictService = PredictService();

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
    showPredictedImageDialog(image);
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
                  "Choose photo",
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

  showPredictedImageDialog(XFile image) async {
    Uint8List imageBytes = await image.readAsBytes();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            contentWidget: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: MemoryImage(imageBytes),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            hasCloseButton: true,
            hasOKButton: true,
            okButtonText: 'Predict image',
            onOKButtonPressed: () {
              String imageBase64 = base64Encode(imageBytes);
              showLoadingDialog(context: context, message: "Predicting image");
              apiService.dioPredictImage(imageBase64).then(
                (response) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
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
                                color: CommonColors.green,
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
                                      text: ', with confident: ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          "${response['confident'].toStringAsFixed(3)}%",
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
                          onOKButtonPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            _predictService
                                .addPredictItem(
                              PredictItem(
                                id: const Uuid().v4(),
                                name: response['prediction'],
                                accuracy: response['confident'],
                                imageUint8List: imageBytes,
                              ),
                            )
                                .then((value) {
                              AnimatedSnackBar.material(
                                'Save successfully',
                                type: AnimatedSnackBarType.success,
                                mobileSnackBarPosition:
                                    MobileSnackBarPosition.bottom,
                                duration: const Duration(seconds: 2),
                                animationCurve: Curves.linearToEaseOut,
                                snackBarStrategy: RemoveSnackBarStrategy(),
                              ).show(context);
                            });
                          },
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
                },
              );
            },
          );
        },
      );
    }
  }

  pickImageFromCamera() async {
    Navigator.of(context).pop();
    try {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      showPredictedImageDialog(image);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.theme.modalBackgroundColor,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          scrolledUnderElevation: 0,
          title: const Align(
            alignment: Alignment.center,
            child: HeadlineText('Scanner'),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    const HeadlineText("Prediction history"),
                    SingleChildScrollView(
                      child: ValueListenableBuilder(
                        valueListenable:
                            Hive.box<PredictItem>('predictList').listenable(),
                        builder: (context, Box<PredictItem> box, _) {
                          return FutureBuilder(
                            future: _predictService.getPredictItems(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<PredictItem>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                List<PredictItem> predictItems = snapshot.data!;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 50,
                                    left: 5,
                                    right: 5,
                                  ),
                                  child: Column(
                                    children: predictItems.map((predictItem) {
                                      return predictCard(predictItem);
                                    }).toList(),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: context.theme.textColor,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: screenSize.height * 0.1,
                      right: 20,
                      child: GestureDetector(
                        onTap: imagePickerTypeBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: CommonColors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.cameraRetro,
                            size: 32,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  openPredictCardDialog(PredictItem predictItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          contentWidget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                child: Image.memory(predictItem.imageUint8List),
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
                      text: predictItem.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const TextSpan(
                      text: ', with confident: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: "${predictItem.accuracy.toStringAsFixed(3)}%",
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
          onOKButtonPressed: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  GestureDetector predictCard(PredictItem predictItem) {
    return GestureDetector(
      onTap: () {
        openPredictCardDialog(predictItem);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFFF2F2F2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                offset: const Offset(0, 3),
                blurRadius: 3,
              ),
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                offset: const Offset(0, -3),
                blurRadius: 3,
              ),
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                offset: const Offset(-3, 0),
                blurRadius: 3,
              ),
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                offset: const Offset(3, 0),
                blurRadius: 3,
              ),
            ],
          ),
          child: ListTile(
            title: HeadlineText(predictItem.name),
            subtitle:
                ContentText("${predictItem.accuracy.toStringAsFixed(3)}%"),
            leading: SizedBox(
              width: 80,
              child: Image.memory(predictItem.imageUint8List),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _predictService.deletePredictItem(predictItem.id);
              },
            ),
          ),
        ),
      ),
    );
  }
}
