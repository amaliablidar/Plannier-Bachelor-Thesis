import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plannier/home/screens/upload_picture_screen.dart';
import 'package:plannier/home/widgets/count_down.dart';
import 'package:plannier/home/widgets/invitation_response.dart';
import 'package:plannier/invitations/widgets/invitation_card.dart';
import 'package:plannier/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../events/bloc/event_bloc.dart';
import '../../events/models/event.dart';
import '../../invitations/bloc/invitation_bloc.dart' hide InvitationResponse;

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
            if (imageRGB != null)
              SizedBox(
                height: 50,
                width: 50,
                child: Image.memory(imageRGB!),
              ),
            const SizedBox(height: 20),
            MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: context.read<EventBloc>(),
                ),
                BlocProvider.value(
                  value: context.read<InvitationBloc>(),
                ),
              ],
              child: const CountDown(),
            ),
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
            BlocBuilder<InvitationBloc, InvitationState>(
              builder: (context, state) {
                if (state is InvitationLoaded) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  Event? event;
                  int invitationIndex = state.invitations.indexWhere(
                      (element) => element.response == Response.pending);
                  int eventIndex = state.invitationEvents.indexWhere(
                      (element) =>
                          element.id ==
                          state
                              .invitations[
                                  invitationIndex != -1 ? invitationIndex : 0]
                              .eventId);
                  if (eventIndex != -1) {
                    event = state.invitationEvents[eventIndex];
                  }
                  if (event != null) {
                    return InvitationCard(
                        invitation: state.invitations[
                            invitationIndex != -1 ? invitationIndex : 0],
                        event: event);
                  }
                }
                return const SizedBox();
              },
            ),
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
