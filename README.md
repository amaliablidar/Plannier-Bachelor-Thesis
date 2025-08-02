# Plannier

A Flutter event planning app built as part of my Bachelor Thesis at Babeș-Bolyai University.

Plannier helps users manage events by creating to-do lists, sending invitations, and preserving memories through image-to-video conversion. The project includes a custom Flutter plugin developed in Kotlin and Swift that enables native video encoding on both Android and iOS platforms.

## Core Features
Event to-do list creation and invitation sending

Image-to-video conversion using a custom Flutter plugin

Manual image conversion from RGBA → YUV444 → YUV420 for efficient compression

Native integration with:

MediaCodec and MediaMuxer on Android

AVAssetWriter and CVPixelBuffer on iOS

Platform channels used for Dart ↔ Native communication

## Thesis & Documentation
Detailed technical documentation is available in the bachelor_thesis/ folder, including architecture, plugin logic, and video encoding process.
