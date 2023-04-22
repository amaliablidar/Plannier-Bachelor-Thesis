import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:plannier/utils/colors.dart';

import 'firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class FirebaseUploadImage extends StatefulWidget {
  final String imageUrl;
  final String path;
  final Function(String) onUploaded;
  final VoidCallback isLoading;
  final double imageHeight;
  final Color backgroundColor;
  final Color borderColor;

  const FirebaseUploadImage(
    this.imageUrl, {
    Key? key,
    required this.path,
    required this.onUploaded,
    required this.isLoading,
    this.imageHeight = 150,
    this.borderColor = const Color(0xFFE6E8EC),
    this.backgroundColor = const Color(0xffF4F4F4),
  }) : super(key: key);

  @override
  State<FirebaseUploadImage> createState() => _FirebaseUploadImageState();
}

class _FirebaseUploadImageState extends State<FirebaseUploadImage> {
  FirebaseStorageService? storage;
  Uint8List? imageBytes;
  String? filePath;
  String? imageUrl;
  bool isLoading = false;

  @override
  void initState() {
    imageUrl = widget.imageUrl;
    storage = Provider.of<FirebaseStorageService>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.backgroundColor,
        border: Border.all(color: widget.borderColor, width: 2),
      ),
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: widget.imageUrl != ''
                ? FadeInImage(
                    placeholder: Image.asset(
                      'assets/user_placeholder.png',
                    ).image,
                    image: Image.network(widget.imageUrl).image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Container(
                    decoration: const BoxDecoration(
                      color: PlannerieColors.secondary,
                    ),
                  ),
          ),
          !isLoading
              ? SizedBox(
                  width: double.infinity,
                  height: 20,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        padding: MaterialStateProperty.all(EdgeInsets.zero)),
                    onPressed: () async {
                      var res = await onUpload();
                      print('picked image ${res?.paths.first}');

                      if (res != null) {
                        setState(() {
                          isLoading = true;
                          imageBytes = res.files.single.bytes;
                          var fileName = res.files.single.name;
                          filePath = widget.path + fileName;
                        });
                        widget.isLoading();
                        if (imageBytes != null && filePath != null) {
                          storage
                              ?.uploadFile(imageBytes!, filePath!)
                              .then((_) async {
                            String? url = await storage?.downloadURL(filePath!);
                            setState(() => imageUrl = url);
                            if (imageUrl != null) {
                              widget.onUploaded(imageUrl!);
                            }
                            isLoading = false;
                          });
                        }
                      }
                    },
                    child: Row(
                      children: const [
                        Icon(
                          Icons.upload_rounded,
                          color: Colors.black,
                          size: 12,
                        ),
                        Flexible(
                          child: Text(
                            'Upload Image',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
        ],
      ),
    );
  }

  Future<FilePickerResult?> onUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );
    return result;
  }
}
