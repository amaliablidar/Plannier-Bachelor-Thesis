import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:plannier/home/widgets/count_down.dart';
import 'package:plannier/home/widgets/invitation_response.dart';
import 'package:plannier/utils/colors.dart';
import 'package:plannier/utils/yuv_conversion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_writer/flutter_media_writer.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.onSeeAllInvitations}) : super(key: key);
  final VoidCallback? onSeeAllInvitations;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ui.Image? image;
  Uint8List? imageRGB;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () async {
                onUpload();
              },
              child: const Text('here'),
            ),
            Image.asset('assets/event_placeholder.jpg'),
            if (imageRGB != null)
              SizedBox(
                height: 50,
                width: 50,
                child: Image.memory(imageRGB!),
              ),
            const SizedBox(height: 20),
            const CountDown(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invitations',
                  style: TextStyle(fontSize: 16),
                ),
                GestureDetector(
                  onTap: widget.onSeeAllInvitations,
                  child: Container(
                    height: 30,
                    width: 80,
                    decoration: BoxDecoration(
                      color: PlannerieColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'See all',
                        style: TextStyle(
                            color: PlannerieColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const InvitationResponse(),
          ],
        ),
      ),
    );
  }

  Future<void> onUpload() async {
    try {
      final xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (xfile == null) return;
      final imageTemp = File(xfile.path);

      final result = await xfile.readAsBytes();
      YuvConversion.jpgToYuv(result, imageTemp.path);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    } catch (e) {
      print("error $e");
    }
  }
}
