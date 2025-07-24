import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  /// Update user display name
  Future<bool> updateDisplayName(String newDisplayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update Firebase Auth profile
      await user.updateDisplayName(newDisplayName);
      await user.reload();

      // Update Firestore user document
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': newDisplayName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Display name updated successfully: $newDisplayName');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating display name: $e');
      }
      rethrow;
    }
  }

  /// Update user password
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      if (kDebugMode) {
        print('✅ Password updated successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating password: $e');
      }
      rethrow;
    }
  }

  /// Pick image from gallery or camera
  Future<XFile?> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error picking image: $e');
      }
      rethrow;
    }
  }

  /// Compress image for upload
  Future<Uint8List> compressImage(Uint8List imageBytes) async {
    try {
      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Failed to decode image');

      // Resize if too large
      if (image.width > 512 || image.height > 512) {
        image = img.copyResize(image, width: 512, height: 512);
      }

      // Compress as JPEG
      final compressedBytes = img.encodeJpg(image, quality: 85);
      
      if (kDebugMode) {
        print('✅ Image compressed: ${imageBytes.length} → ${compressedBytes.length} bytes');
      }
      
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error compressing image: $e');
      }
      rethrow;
    }
  }

  /// Upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(Uint8List imageBytes) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Create reference to user's profile picture
      final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');

      // Upload image
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        print('✅ Profile picture uploaded: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading profile picture: $e');
      }
      rethrow;
    }
  }

  /// Update user profile picture
  Future<bool> updateProfilePicture(XFile imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Read and compress image
      final imageBytes = await imageFile.readAsBytes();
      final compressedBytes = await compressImage(imageBytes);

      // Upload to Firebase Storage
      final downloadUrl = await uploadProfilePicture(compressedBytes);

      // Update Firebase Auth profile
      await user.updatePhotoURL(downloadUrl);
      await user.reload();

      // Update Firestore user document
      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Profile picture updated successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating profile picture: $e');
      }
      rethrow;
    }
  }

  /// Delete user's profile picture
  Future<bool> deleteProfilePicture() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Delete from Firebase Storage
      try {
        final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
        await ref.delete();
      } catch (e) {
        // Ignore if file doesn't exist
        if (kDebugMode) {
          print('⚠️ Profile picture file not found in storage: $e');
        }
      }

      // Update Firebase Auth profile
      await user.updatePhotoURL(null);
      await user.reload();

      // Update Firestore user document
      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Profile picture deleted successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting profile picture: $e');
      }
      rethrow;
    }
  }

  /// Delete user account completely
  Future<bool> deleteAccount(String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete profile picture from storage
      try {
        await deleteProfilePicture();
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error deleting profile picture during account deletion: $e');
        }
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user progress data
      try {
        final progressDoc = await _firestore.collection('user_progress').doc(user.uid).get();
        if (progressDoc.exists) {
          await _firestore.collection('user_progress').doc(user.uid).delete();
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error deleting progress data: $e');
        }
      }

      // Delete user authentication record
      await user.delete();

      if (kDebugMode) {
        print('✅ User account deleted successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting account: $e');
      }
      rethrow;
    }
  }

  /// Show image source selection dialog
  Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Get user's current profile picture URL
  String? getCurrentProfilePictureUrl() {
    return _auth.currentUser?.photoURL;
  }

  /// Check if user has a profile picture
  bool hasProfilePicture() {
    final url = getCurrentProfilePictureUrl();
    return url != null && url.isNotEmpty;
  }
}
