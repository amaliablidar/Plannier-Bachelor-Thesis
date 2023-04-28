import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  List<ImageFile> images = [];
  bool isLoading = false;

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
                    const SizedBox(height: 32),
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
                        setState(() => isLoading = true);
                        List<Uint8List> imagesBytes = [];
                        for (var image in images) {
                          if (image.path != null) {
                            var imageFile = File(image.path!);
                            var bytesList = await imageFile.readAsBytes();
                            imagesBytes.add(bytesList);
                          }
                        }
                        await YuvConversion.jpgToYuv(imagesBytes);
                        setState(() => isLoading = false);
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
