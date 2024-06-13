import 'dart:developer';

import 'package:eco_app/common/api/firebase_api.dart';
import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/helpers/notification_helper.dart';
import 'package:eco_app/common/models/bin_item.dart';
import 'package:eco_app/common/services/api_service.dart';
import 'package:eco_app/common/utils/common_colors.dart';
import 'package:eco_app/common/widgets/custom_alert_dialog.dart';
import 'package:eco_app/common/widgets/custom_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HouseHoldPage extends ConsumerStatefulWidget {
  const HouseHoldPage({super.key});

  @override
  ConsumerState<HouseHoldPage> createState() => _HouseHoldPageState();
}

class _HouseHoldPageState extends ConsumerState<HouseHoldPage> {
  String endpoint = "";
  bool isLive = false;
  late ApiService apiService;
  bool flashState = false;
  bool addSizedBox = false;
  final TextEditingController textIPStreamController = TextEditingController();
  late List<BinItem> binItems = [
    BinItem(
      id: 'recyclable',
      name: 'Recyclable',
      isOpen: false,
      imageDir: 'recyclable',
      color: CommonColors.recyclableColor,
    ),
    BinItem(
      id: 'danger',
      name: 'Danger',
      isOpen: false,
      imageDir: 'danger',
      color: CommonColors.dangerColor,
    ),
    BinItem(
      id: 'organic',
      name: 'Organic',
      isOpen: false,
      imageDir: 'organic',
      color: CommonColors.organicColor,
    ),
    BinItem(
      id: 'glass',
      name: 'Glass',
      isOpen: false,
      imageDir: 'glass',
      color: CommonColors.glassColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    FirebaseApi().getCompartments().then((compartments) {
      Map<String, bool> compartmentStates = {
        for (var compartment in compartments)
          compartment.name: compartment.isOpen
      };
      setState(() {
        for (var binItem in binItems) {
          binItem.isOpen = compartmentStates[binItem.name] ?? false;
        }
      });
    });
    apiService = ref.read(apiServiceProvider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void openTextFieldDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          contentWidget: Padding(
            padding: const EdgeInsets.all(2),
            child: SizedBox(
              height: 100,
              child: Column(
                children: [
                  const HeadlineText("IP Stream"),
                  const SizedBox(height: 10),
                  TextFormField(controller: textIPStreamController)
                ],
              ),
            ),
          ),
          hasCloseButton: true,
          hasOKButton: true,
          okButtonText: "Save",
          onOKButtonPressed: () {
            setState(() {
              endpoint = textIPStreamController.text;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.theme.modalBackgroundColor,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        scrolledUnderElevation: 0,
        title: const Align(
          alignment: Alignment.center,
          child: HeadlineText('Household'),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            addSizedBox
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          FirebaseApi().updateEsp32("recyclable");
                        },
                        child: const ContentText(
                          "😘",
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        onTap: () {
                          FirebaseApi().updateEsp32("danger");
                        },
                        child: const ContentText(
                          "😂",
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        onTap: () {
                          FirebaseApi().updateEsp32("organic");
                        },
                        child: const ContentText(
                          "😁",
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        onTap: () {
                          FirebaseApi().updateEsp32("glass");
                        },
                        child: const ContentText(
                          "😎",
                          fontSize: 20,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(height: 0),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              addSizedBox = !addSizedBox;
                            });
                          },
                          child: const HeadlineText("Camera view")),
                      GestureDetector(
                        onTap: () {
                          openTextFieldDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: CommonColors.rubyBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            FontAwesomeIcons.wifi,
                            size: 25,
                            color: CommonColors.darkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ContentText("Flash intensity"),
                      Switch(
                        value: flashState,
                        onChanged: (value) {
                          setState(() {
                            flashState = value;
                          });
                          apiService.dioSetFlash(flashState, endpoint);
                        },
                        activeColor: CommonColors.darkGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLive = !isLive;
                      });
                    },
                    child: Container(
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
                      child: isLive
                          ? Center(
                              child: Mjpeg(
                                isLive: true,
                                stream: "http://192.168.$endpoint:81/stream",
                                timeout: const Duration(minutes: 5),
                                error: (context, error, stack) {
                                  log(error.toString());
                                  return Text(
                                    error.toString(),
                                    style: const TextStyle(color: Colors.red),
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
                      for (var binItem in binItems) monitorCard(binItem),
                    ],
                  )
                ],
              ),
            ),
            addSizedBox
                ? const SizedBox(height: 70)
                : const SizedBox(height: 0),
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
          binItem.isOpen = !binItem.isOpen;
        });
        FirebaseApi().updateServo(binItem.id, binItem.isOpen);
        NotificationHelper.pushNotification(
          title: binItem.isOpen
              ? "OPENED YOUR COMPARTMENT!!!"
              : "CLOSED YOUR COMPARTMENT!!!",
          body:
              "Your ${binItem.name} compartment is ${!binItem.isOpen ? "closed" : "opened"}",
          isToggleServo: true,
        );
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
                color:
                    !binItem.isOpen ? binItem.color : const Color(0xFFF2F2F2),
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
                'assets/images/${!binItem.isOpen ? '${binItem.imageDir}-white' : binItem.imageDir}.png',
                fit: BoxFit.none,
              ),
            ),
            const SizedBox(height: 5),
            ContentText(binItem.name),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () {
                FirebaseApi().notifyServo(
                  binItem.id == "recyclable"
                      ? 1
                      : binItem.id == "danger"
                          ? 2
                          : binItem.id == "organic"
                              ? 3
                              : 4,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  FontAwesomeIcons.volumeHigh,
                  color:
                      !binItem.isOpen ? binItem.color : CommonColors.darkGreen,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
