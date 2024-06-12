import 'dart:developer';

import 'package:eco_app/common/api/firebase_api.dart';
import 'package:eco_app/common/constants.dart';
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
import 'package:speech_to_text/speech_to_text.dart';

class HouseHoldPage extends ConsumerStatefulWidget {
  const HouseHoldPage({super.key});

  @override
  ConsumerState<HouseHoldPage> createState() => _HouseHoldPageState();
}

class _HouseHoldPageState extends ConsumerState<HouseHoldPage> {
  static const streamURL = "${Constants.localUrl}:81/stream";
  final SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;
  String wordsSpoken = "";
  bool isRecord = false;
  bool isLive = false;
  late ApiService apiService;
  bool flashState = false;
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
    apiService = ref.read(apiServiceProvider);
    initSpeech();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initSpeech() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  void handleCommand(String wordsSpokenDetected) {
    wordsSpokenDetected = wordsSpokenDetected.toLowerCase();
    bool isOpenCommand = wordsSpokenDetected.contains("open");
    bool isCloseCommand = wordsSpokenDetected.contains("close");
    String compartmentNumber = "";

    if ((isOpenCommand && isCloseCommand) ||
        (!isOpenCommand && !isCloseCommand)) {
      log("Invalid command.");
      return;
    }

    final Map<String, String> compartmentNames = {
      "1": "glass",
      "2": "recyclable",
      "3": "danger",
      "4": "organic",
      "one": "glass",
      "two": "recyclable",
      "three": "danger",
      "four": "organic",
    };

    final Map<String, String> nameToNumber = {
      "1": "1",
      "2": "2",
      "3": "3",
      "4": "4",
      "one": "1",
      "two": "2",
      "three": "3",
      "four": "4",
    };

    if (isOpenCommand) {
      compartmentNumber = wordsSpokenDetected.replaceAll("open ", "");
    } else if (isCloseCommand) {
      compartmentNumber = wordsSpokenDetected.replaceAll("close ", "");
    }

    if (compartmentNumber.isNotEmpty) {
      compartmentNumber = nameToNumber[compartmentNumber] ?? "";
      String servoControlValue = "servo$compartmentNumber";
      int operationValue = isOpenCommand ? 1 : 0;

      if (compartmentNumber == "1" ||
          compartmentNumber == "2" ||
          compartmentNumber == "3" ||
          compartmentNumber == "4") {
        FirebaseApi().updateServo(servoControlValue, operationValue);
        NotificationHelper.pushNotification(
          title: "${isOpenCommand ? "OPENED" : "CLOSED"} YOUR COMPARTMENT!!!",
          body:
              "Your ${compartmentNames[compartmentNumber]} compartment is ${isOpenCommand ? "opened" : "closed"}",
          isToggleServo: true,
        );
      } else {
        log("Invalid compartment number.");
      }
    } else {
      log("Command not recognized.");
    }
  }

  void listenToNotify() {}

  void openRecordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: ((context, setState) {
            void stopListening() async {
              await speechToText.stop();
              setState(() {});
            }

            void onSpeechResult(result) {
              setState(() {
                wordsSpoken = result.recognizedWords;
              });
              if (result.finalResult) {
                stopListening();
                setState(() {
                  isRecord = false;
                });
                handleCommand(wordsSpoken);
              }
            }

            void startListening() async {
              await speechToText.listen(onResult: onSpeechResult);
            }

            return CustomAlertDialog(
              contentWidget: SizedBox(
                height: 250,
                width: 250,
                child: Column(
                  children: [
                    const HeadlineText("Recorded words"),
                    const SizedBox(height: 30),
                    ContentText(
                      speechToText.isListening
                          ? "Listening..."
                          : speechEnabled
                              ? "Tap to record"
                              : "Speech not enabled",
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isRecord = !isRecord;
                        });
                        if (speechEnabled) {
                          if (speechToText.isListening) {
                            stopListening();
                          } else {
                            startListening();
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.1),
                        ),
                        child: isRecord
                            ? Image.asset(
                                'assets/images/recording-button.gif',
                                height: 100,
                                width: 100,
                              )
                            : Image.asset(
                                'assets/images/recording-button.png',
                                height: 100,
                                width: 100,
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ContentText(wordsSpoken),
                    )
                  ],
                ),
              ),
              hasCloseButton: true,
              onCloseButtonPressed: () {
                stopListening();
                setState(() {
                  wordsSpoken = "";
                  isRecord = false;
                });
                Navigator.of(context).pop();
              },
            );
          }),
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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const HeadlineText("Camera view"),
                GestureDetector(
                  onTap: () {
                    openRecordDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: CommonColors.rubyBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      FontAwesomeIcons.microphone,
                      size: 30,
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
                    apiService.dioSetFlash(flashState);
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
                          stream: streamURL,
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
    );
  }

  GestureDetector monitorCard(BinItem binItem) {
    Size screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        setState(() {
          binItem.state = !binItem.state;
        });
        FirebaseApi().updateServo(binItem.servoName, binItem.state ? 1 : 0);
        NotificationHelper.pushNotification(
          title: binItem.state
              ? "OPENED YOUR COMPARTMENT!!!"
              : "CLOSED YOUR COMPARTMENT!!!",
          body:
              "Your ${binItem.name} compartment is ${binItem.state ? "closed" : "opened"}",
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
}
