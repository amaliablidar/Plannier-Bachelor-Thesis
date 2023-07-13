import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:plannier/utils/colors.dart';

import '../../utils/yuv_conversion.dart';

class UploadPictureScreen extends StatefulWidget {
  const UploadPictureScreen({Key? key}) : super(key: key);

  @override
  State<UploadPictureScreen> createState() => _UploadPictureScreenState();
}

class _UploadPictureScreenState extends State<UploadPictureScreen> {
  final controller = MultiImagePickerController(
    maxImages: 10,
    withReadStream: true,
    allowedImageTypes: ['png', 'jpg', 'jpeg'],
  );
  final ImagePicker _picker = ImagePicker();

  List<File> images = [];
  bool isLoading = false;
  bool isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            if (images.isNotEmpty)
              Expanded(
                child: GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  children: List.generate(
                    images.length + 1,
                    (index) => index == images.length
                        ? GestureDetector(
                            onTap: () async {
                              var imagesList = await _picker.pickMultiImage();
                              for (var image in imagesList) {
                                final File imageFile = File(image.path ?? '');
                                setState(() => images.add(imageFile));
                              }
                            },
                            child: Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                          )
                        : Stack(
                            alignment: Alignment.topRight,
                            children: [
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    images[index].readAsBytesSync(),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(
                                    () => images.remove(images[index])),
                                child: Card(
                                  color: Colors.white.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(80)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        var imagesList = await _picker.pickMultiImage();
                        for (var image in imagesList) {
                          final File imageFile = File(image.path);
                          setState(() => images.add(imageFile));
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              FaIcon(
                                FontAwesomeIcons.upload,
                                color: PlannerieColors.primary,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Add Photos',
                                style: TextStyle(
                                    fontFamily: 'Northwell',
                                    fontSize: 40,
                                    color: PlannerieColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              margin: const EdgeInsets.all(20),
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: PlannerieColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                  : ElevatedButton(
                      onPressed: () async {
                        try {
                          setState(() => isLoading = true);
                          List<Uint8List> imagesBytes = [];
                          for (var image in images) {
                            var bytesList = await image.readAsBytes();

                            imagesBytes.add(bytesList);
                          }
                          await YuvConversion.jpgToYuv(
                            imagesBytes,
                            () => Navigator.pop(context),
                            () => Navigator.pop(context),
                          );

                          setState(() => isLoading = false);
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: const Text(
                        'Create Video',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
      appBar: AppBar(),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
