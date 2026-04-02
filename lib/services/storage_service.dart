import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // Upload profile photo
  Future<String> uploadProfilePhoto(String userId, File file) async {
    final ref = _storage.ref().child('profiles/$userId/photo.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // Upload chat file (notes/PDF/images)
  Future<Map<String, String>> uploadChatFile({
    required String matchId,
    required File file,
    required String fileName,
  }) async {
    final fileId = _uuid.v4();
    final ext = fileName.split('.').last;
    final ref = _storage.ref().child('chat_files/$matchId/$fileId.$ext');

    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return {
      'url': downloadUrl,
      'name': fileName,
    };
  }

  // Delete file
  Future<void> deleteFile(String fileUrl) async {
    final ref = _storage.refFromURL(fileUrl);
    await ref.delete();
  }
}