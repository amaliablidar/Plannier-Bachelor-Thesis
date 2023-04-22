import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:plannier/events/screens/event_persist_screen.dart';
import 'package:plannier/home/screens/upload_picture_screen.dart';
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
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EventPersistScreen())),
              child: Container(
                width: double.infinity,
                height: 70,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: PlannerieColors.secondary,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Add a new event',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Icon(
                      Icons.add,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () async => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UploadPictureScreen(),
                ),
              ),
              // onPressed: ()async=>onUpload(),
              child: const Text('Add a photo'),
            ),
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

      final result = await imageTemp.readAsBytes();
      // YuvConversion.jpgToYuv(result);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    } catch (e) {
      print("error $e");
    }
  }

}
