import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirebaseStorageService {
  final firebase_storage.FirebaseStorage storage;

  FirebaseStorageService()
      : storage = firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile(Uint8List uploadFile, String path) async {
    try {
      await storage.ref(path).putData(uploadFile);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<String> downloadURL(String path) async {
    return await storage.ref(path).getDownloadURL();
  }
}
