import 'dart:io';
import 'dart:math';

import 'package:eco_app/common/extensions/custom_theme_extension.dart';
import 'package:eco_app/common/features/camera_page/pages/image_picker_page.dart';
import 'package:eco_app/common/utils/common_colors.dart';
import 'package:eco_app/common/widgets/custom_elevated_button.dart';
import 'package:eco_app/common/widgets/custom_icon_button.dart';
import 'package:eco_app/common/widgets/custom_text_style.dart';
import 'package:eco_app/common/widgets/show_h_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? filePath;
  File? imageCamera;
  Uint8List? imageGallery;
  Interpreter? _interpreter;
  static const outputSize = 8;
  static const classNames = [
    'cardboard',
    'danger',
    'facemask',
    'glass',
    'metal',
    'nilon',
    'paper',
    'plastic'
  ];

  @override
  void initState() {
    super.initState();
    _tfliteInit();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _tfliteInit() async {
    try {
      final interpreterOptions = InterpreterOptions()..threads = 1;
      final interpreter = await Interpreter.fromAsset(
          'assets/ai_models/tflite_garbage_model.tflite',
          options: interpreterOptions);
      interpreter.allocateTensors();
      setState(() {
        _interpreter = interpreter;
      });
    } catch (e) {
      // log(e.toString());
    }
  }

  Future<Float32List> imageToByteListFloat32(img.Image image, int width) async {
    // var convertedBytes = Uint8List.fromList(img.encodeJpg(image));
    var buffer = Float32List(width * width * 3);
    int bufferIndex = 0;
    for (int y = 0; y < width; y++) {
      for (int x = 0; x < width; x++) {
        img.Pixel pixel = image.getPixelSafe(x, y);
        buffer[bufferIndex++] = pixel.r / 255.0; // Red
        buffer[bufferIndex++] = pixel.g / 255.0; // Green
        buffer[bufferIndex++] = pixel.b / 255.0; // Blue
      }
    }
    return buffer;
  }

  Future<String> predictImage(Uint8List imageBytes) async {
    const imgHeight = 160;
    const imgWidth = 160;
    if (_interpreter == null) {
      await _tfliteInit();
    }
    img.Image image = img.decodeImage(imageBytes)!;
    img.Image resizedImg =
        img.copyResize(image, width: imgWidth, height: imgHeight);
    Float32List input = await imageToByteListFloat32(resizedImg, imgWidth);
    List output = List.filled(1 * outputSize, 0).reshape([1, outputSize]);
    _interpreter?.run(input, output);
    List<double> softMax = output[0]
        .map((x) => exp(x) / output[0].reduce((a, b) => a + b))
        .toList();
    int index = softMax.indexOf(softMax.reduce(max));
    String className = classNames[index];
    _interpreter?.close();
    return 'Garbage in image is $className';
    // try {
    // } catch (e) {
    //   return 'Error occurred while predicting the image: $e';
    // }
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
                    onTap: () async {
                      Navigator.of(context).pop();
                      final image = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ImagePickerPage(),
                        ),
                      );
                      if (image == null) return;
                      setState(() {
                        imageGallery = image;
                        imageCamera = null;
                      });
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
        imageGallery = null;
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
                    child: imageGallery == null
                        ? Image.asset(
                            'assets/images/upload.jpg',
                            fit: BoxFit.fill,
                          )
                        : Image.memory(
                            imageGallery!,
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
                predictImage(imageGallery!);
              },
              text: "Predict Image",
            )
          ],
        ),
      ),
    );
  }
}
