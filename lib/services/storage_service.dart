import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage and return its download URL
  Future<String?> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final task = await ref.putFile(file);
      final url = await task.ref.getDownloadURL();
      print('File uploaded successfully: $url');
      return url;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  /// Download a file from Firebase Storage
  Future<File?> downloadFile(String storagePath, String localPath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final file = File(localPath);
      await ref.writeToFile(file);
      print('File downloaded successfully: $localPath');
      return file;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  /// Delete a file from Firebase Storage
  Future<bool> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
      print('File deleted successfully: $storagePath');
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Get file metadata (size, updated time, etc.)
  Future<FullMetadata?> getFileMetadata(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final metadata = await ref.getMetadata();
      return metadata;
    } catch (e) {
      print('Error fetching metadata: $e');
      return null;
    }
  }

  /// List all files in a directory
  Future<List<String>> listFiles(String directory) async {
    try {
      final ref = _storage.ref().child(directory);
      final result = await ref.listAll();
      return result.items.map((item) => item.fullPath).toList();
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }
}

