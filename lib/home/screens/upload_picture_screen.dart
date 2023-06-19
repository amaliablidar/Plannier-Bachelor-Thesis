import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:plannier/utils/colors.dart';
import 'package:plannier/utils/platform_specific_dialog.dart';

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
  List<ImageFile> images = [];
  bool isLoading = false;
  bool isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // GestureDetector(
                    //   onTap: () async {
                    //     final ImagePicker picker = ImagePicker();
                    //     final XFile? image =
                    //         await picker.pickImage(source: ImageSource.gallery);
                    //     final File file = File(image?.path ?? '');
                    //     print(image?.path);
                    //     final bytes = await file.readAsBytes();
                    //     var image1 = ImageFile('',
                    //         name: 'name',
                    //         extension: '.jpg',
                    //         bytes: bytes,
                    //         path: image?.path);
                    //     images.add(image1);
                    //     print(image1);
                    //   },
                    //   child: Container(
                    //     child: Text("Add photo"),
                    //   ),
                    // )
                    MultiImagePickerView(
                      onChange: (list) =>
                          setState(() => images = list.toList()),
                      addButtonTitle: 'Upload photos',
                      initialContainerBuilder: (context, picker) =>
                          GestureDetector(
                        onTap: picker,
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          height: 200,
                          width: double.infinity,
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
                      addMoreBuilder: (context, picker) => GestureDetector(
                        onTap: picker,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 30,
                              color: PlannerieColors.primary,
                            ),
                          ),
                        ),
                      ),
                      controller: controller,
                      padding: const EdgeInsets.all(10),
                    ),
                  ],
                ),
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
                          print(images.length);
                          for (var image in images) {
                            print("image for ${image}");
                            if (image.path != null) {
                              var imageFile = File(image.path!);
                              print(image.path!);
                              var bytesList = await imageFile.readAsBytes();
                              print(bytesList.length);

                              imagesBytes.add(bytesList);
                            }
                          }
                          await YuvConversion.jpgToYuv(
                            imagesBytes,
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
