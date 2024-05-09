import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:eco_app/common/api/firebase_api.dart';
import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/helpers/show_loading_dialog.dart';
import 'package:eco_app/common/models/bin_item.dart';
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
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ScannerAndMonitorPage extends ConsumerStatefulWidget {
  const ScannerAndMonitorPage({super.key});

  @override
  ConsumerState<ScannerAndMonitorPage> createState() =>
      _ScannerAndMonitorPageState();
}

class _ScannerAndMonitorPageState extends ConsumerState<ScannerAndMonitorPage> {
  static const streamURL = "http://192.168.1.6:81/stream";
  File? filePath;
  File? imageCamera;
  late ApiService apiService;
  final PredictService _predictService = PredictService();
  bool isLive = false;
  late List<BinItem> binItems = [
    BinItem(
      id: 'glass',
      name: 'Glass',
      servoName: 'servo1',
      state: false,
      imageDir: 'glass',
      color: CommonColors.glassColor,
    ),
    BinItem(
      id: 'recycle',
      name: 'Recycle',
      servoName: 'servo2',
      state: false,
      imageDir: 'recycle',
      color: CommonColors.recycleColor,
    ),
    BinItem(
      id: 'danger',
      name: 'Danger',
      servoName: 'servo3',
      state: false,
      imageDir: 'danger',
      color: CommonColors.dangerColor,
    ),
    BinItem(
      id: 'organic',
      name: 'Organic',
      servoName: 'servo4',
      state: false,
      imageDir: 'organic',
      color: CommonColors.organicColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    apiService = ref.read(apiServiceProvider);
    FirebaseApi().getServos().then((servos) {
      Map<String, bool> servoStates = {
        for (var servo in servos) servo.name: servo.state == 1
      };
      setState(() {
        for (var binItem in binItems) {
          binItem.state = servoStates[binItem.servoName] ?? false;
        }
      });
    });
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
    Uint8List imageBytes = await image.readAsBytes();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            contentWidget: Container(
              height: 200,
              width: 200,
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
                          onOKButtonPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            _predictService
                                .addPredictItem(
                              PredictItem(
                                id: const Uuid().v4(),
                                name: response['prediction'],
                                accuracy: response['accuracy'],
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.theme.modalBackgroundColor,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          scrolledUnderElevation: 0,
          title: const Align(
            alignment: Alignment.center,
            child: HeadlineText('Scanner And Monitor'),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  icon: Icon(
                    FontAwesomeIcons.camera,
                    color: CommonColors.darkGreen,
                  ),
                ),
                Tab(
                  icon: Icon(
                    FontAwesomeIcons.desktop,
                    color: CommonColors.darkGreen,
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        const HeadlineText("Prediction history"),
                        SingleChildScrollView(
                          child: ValueListenableBuilder(
                            valueListenable:
                                Hive.box<PredictItem>('predictList')
                                    .listenable(),
                            builder: (context, Box<PredictItem> box, _) {
                              return FutureBuilder(
                                future: _predictService.getPredictItems(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<PredictItem>> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    List<PredictItem> predictItems =
                                        snapshot.data!;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        top: 50,
                                        left: 5,
                                        right: 5,
                                      ),
                                      child: Column(
                                        children:
                                            predictItems.map((predictItem) {
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLive = !isLive;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HeadlineText("Camera view"),
                          const SizedBox(height: 10),
                          Container(
                            height: screenSize.height * 0.4,
                            width: screenSize.width,
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
                            child: Center(
                              child: isLive
                                  ? Center(
                                      child: Mjpeg(
                                        isLive: true,
                                        stream: streamURL,
                                        timeout: const Duration(minutes: 5),
                                        error: (context, error, stack) {
                                          log(error.toString());
                                          return Text(
                                            error.toString(),
                                            style: const TextStyle(
                                                color: Colors.red),
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      FontAwesomeIcons.videoSlash,
                                      size: 50,
                                      color: CommonColors.darkGreen,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const HeadlineText("Monitoring"),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              for (var binItem in binItems)
                                monitorCard(binItem),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  GestureDetector monitorCard(BinItem binItem) {
    Size screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        setState(() {
          binItem.state = !binItem.state;
          FirebaseApi().updateServo(binItem.servoName, binItem.state ? 1 : 0);
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 10,
        ),
        child: Column(
          children: [
            Container(
              height: screenSize.height * 0.1,
              width: screenSize.width * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: binItem.state ? binItem.color : const Color(0xFFF2F2F2),
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
              child: Image.asset(
                'assets/images/${binItem.state ? '${binItem.imageDir}-white' : binItem.imageDir}.png',
                fit: BoxFit.none,
              ),
            ),
            const SizedBox(height: 5),
            ContentText(binItem.name)
          ],
        ),
      ),
    );
  }

  Padding predictCard(PredictItem predictItem) {
    return Padding(
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
          subtitle: ContentText("${predictItem.accuracy.toStringAsFixed(3)}%"),
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
    );
  }
}
