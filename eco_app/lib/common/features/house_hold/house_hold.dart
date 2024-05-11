import 'dart:developer';

import 'package:eco_app/common/api/firebase_api.dart';
import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/models/bin_item.dart';
import 'package:eco_app/common/utils/common_colors.dart';
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
  static const streamURL = "http://192.168.1.6:81/stream";
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
        child: GestureDetector(
          onTap: () {
            setState(() {
              isLive = !isLive;
            });
          },
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
}
