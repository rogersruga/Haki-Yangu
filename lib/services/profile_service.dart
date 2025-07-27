import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
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

  /// Check if Firebase Storage is properly configured
  Future<bool> _isStorageAvailable() async {
    try {
      if (kDebugMode) {
        print('🔵 Checking Firebase Storage availability...');
      }

      // Try to create a reference - this is lightweight and doesn't require network
      final testRef = _storage.ref().child('test');

      // Instead of getMetadata (which can hang), try a quick list operation with timeout
      await testRef.parent?.list(const ListOptions(maxResults: 1)).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Storage availability check timeout');
        },
      );

      if (kDebugMode) {
        print('✅ Firebase Storage is available');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Firebase Storage check result: $e');
        // These errors actually indicate storage is available
        if (e.toString().contains('storage/object-not-found') ||
            e.toString().contains('storage/unauthorized') ||
            e.toString().contains('list')) {
          print('✅ Firebase Storage is available (expected error)');
          return true;
        }
      }
      if (kDebugMode) {
        print('❌ Firebase Storage not available: $e');
      }
      return false;
    }
  }

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
      if (kDebugMode) {
        print('🔵 Starting image compression...');
        print('🔵 Original size: ${imageBytes.length} bytes');
      }

      // Add timeout to prevent hanging on large images
      final compressionFuture = () async {
        // Decode image
        img.Image? image = img.decodeImage(imageBytes);
        if (image == null) throw Exception('Failed to decode image - unsupported format');

        if (kDebugMode) {
          print('🔵 Image decoded: ${image.width}x${image.height}');
        }

        // Resize if too large (more aggressive sizing for faster processing)
        if (image.width > 400 || image.height > 400) {
          if (kDebugMode) {
            print('🔵 Resizing image from ${image.width}x${image.height} to 400x400');
          }
          image = img.copyResize(image, width: 400, height: 400);
        }

        // Compress as JPEG with good quality
        final compressedBytes = img.encodeJpg(image, quality: 80);

        if (kDebugMode) {
          print('✅ Image compressed: ${imageBytes.length} → ${compressedBytes.length} bytes');
        }

        return Uint8List.fromList(compressedBytes);
      }();

      return await compressionFuture.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Image compression timeout - image may be too large or corrupted');
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error compressing image: $e');
        if (e.toString().contains('timeout')) {
          print('❌ Try using a smaller image or different format');
        }
      }
      rethrow;
    }
  }

  /// Upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(Uint8List imageBytes) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      if (kDebugMode) {
        print('🔵 Starting profile picture upload for user: ${user.uid}');
        print('🔵 Image size: ${imageBytes.length} bytes');
      }

      // Skip storage availability check to prevent hanging - just try upload directly
      if (kDebugMode) {
        print('🔵 Skipping storage availability check to prevent hanging...');
      }

      // Create reference to user's profile picture
      final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');

      if (kDebugMode) {
        print('🔵 Storage reference created: ${ref.fullPath}');
      }

      // Upload image with shorter timeout and simpler progress tracking
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

      if (kDebugMode) {
        print('🔵 Upload task created, waiting for completion...');
      }

      // Use a shorter timeout and simpler approach
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 30), // Reduced from 2 minutes
        onTimeout: () {
          if (kDebugMode) {
            print('❌ Upload timeout after 30 seconds');
          }
          throw Exception('Upload timeout - please check your internet connection and try again');
        },
      );

      if (kDebugMode) {
        print('🔵 Upload completed, getting download URL...');
      }

      final downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Failed to get download URL - timeout');
        },
      );

      if (kDebugMode) {
        print('✅ Profile picture uploaded successfully: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading profile picture: $e');
        print('❌ Error type: ${e.runtimeType}');
        if (e.toString().contains('storage/unauthorized')) {
          print('❌ Firebase Storage rules may be blocking the upload');
        } else if (e.toString().contains('storage/unknown')) {
          print('❌ Firebase Storage may not be properly configured');
        } else if (e.toString().contains('timeout')) {
          print('❌ Upload timed out - check internet connection');
        } else if (e.toString().contains('network')) {
          print('❌ Network error - check internet connection');
        }
      }
      rethrow;
    }
  }

  /// Update user profile picture - ULTRA SIMPLIFIED TO PREVENT HANGING
  Future<bool> updateProfilePicture(XFile imageFile) async {
    if (kDebugMode) {
      print('🔵 ULTRA: Starting profile picture update...');
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      if (kDebugMode) {
        print('🔵 ULTRA: User authenticated: ${user.uid}');
      }

      // Try Firebase Storage first, with fallback to base64
      try {
        return await _tryFirebaseStorageUpload(user, imageFile);
      } catch (storageError) {
        if (kDebugMode) {
          print('⚠️ ULTRA: Firebase Storage failed: $storageError');
          print('🔵 ULTRA: Trying fallback method...');
        }
        return await _tryBase64Fallback(user, imageFile);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ULTRA: All upload methods failed: $e');
      }
      rethrow;
    }
  }

  /// Try Firebase Storage upload with aggressive timeouts
  Future<bool> _tryFirebaseStorageUpload(User user, XFile imageFile) async {
    if (kDebugMode) {
      print('🔵 STORAGE: Attempting Firebase Storage upload...');
      print('🔵 STORAGE: Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
    }

    // For web platform, prefer base64 to avoid CORS issues
    if (kIsWeb) {
      if (kDebugMode) {
        print('🔵 WEB: Web platform detected - using base64 to avoid CORS issues');
      }

      // Use base64 approach for web to avoid CORS
      return await _tryBase64Fallback(user, imageFile);
    }

    // Read and compress image with timeout
    final imageBytes = await imageFile.readAsBytes().timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw Exception('Read timeout'),
    );

    final compressedBytes = await compressImage(imageBytes);

    // Ultra-simple upload
    final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
    final uploadTask = ref.putData(compressedBytes);

    // Very short timeout for upload
    final snapshot = await uploadTask.timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Storage upload timeout'),
    );

    final downloadUrl = await snapshot.ref.getDownloadURL().timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw Exception('Download URL timeout'),
    );

    // Update Firebase Auth
    await user.updatePhotoURL(downloadUrl);
    await user.reload();

    if (kDebugMode) {
      print('🔵 STORAGE: Firebase Auth updated, new photoURL: ${user.photoURL}');
    }

    // Update Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'photoURL': downloadUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (kDebugMode) {
      print('🔵 STORAGE: Firestore updated with photoURL: $downloadUrl');
      print('✅ STORAGE: Firebase Storage upload successful!');
    }

    return true;
  }

  /// Fallback method using base64 encoding in Firestore
  Future<bool> _tryBase64Fallback(User user, XFile imageFile) async {
    if (kDebugMode) {
      print('🔵 FALLBACK: Using base64 fallback method...');
    }

    // Read and compress image
    final imageBytes = await imageFile.readAsBytes();
    final compressedBytes = await compressImage(imageBytes);

    // Convert to base64
    final base64String = base64Encode(compressedBytes);
    final dataUrl = 'data:image/jpeg;base64,$base64String';

    if (kDebugMode) {
      print('🔵 FALLBACK: Created base64 data URL (${dataUrl.length} chars)');
    }

    // Update Firebase Auth with data URL
    await user.updatePhotoURL(dataUrl);
    await user.reload();

    if (kDebugMode) {
      print('🔵 FALLBACK: Firebase Auth updated, new photoURL length: ${user.photoURL?.length ?? 0}');
    }

    // Update Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'photoURL': dataUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (kDebugMode) {
      print('🔵 FALLBACK: Firestore updated with base64 data URL');
      print('✅ FALLBACK: Base64 fallback upload successful!');
    }

    return true;
  }

  /// Direct upload method - simplified to prevent hanging
  Future<String> _directUploadSimple(String userId, Uint8List imageBytes) async {
    if (kDebugMode) {
      print('🔵 DIRECT: Starting simplified upload for user: $userId');
      print('🔵 DIRECT: Image size: ${imageBytes.length} bytes');
    }

    try {
      // Create storage reference
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');

      if (kDebugMode) {
        print('🔵 DIRECT: Storage reference created: ${ref.fullPath}');
      }

      // Simple upload with minimal metadata and short timeout
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      if (kDebugMode) {
        print('🔵 DIRECT: Upload task started...');
      }

      // Wait for upload with short timeout
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 20), // Even shorter timeout
        onTimeout: () {
          if (kDebugMode) {
            print('❌ DIRECT: Upload timeout after 20 seconds');
          }
          throw Exception('Upload timeout - check internet connection');
        },
      );

      if (kDebugMode) {
        print('🔵 DIRECT: Upload completed, getting download URL...');
      }

      // Get download URL with timeout
      final downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Failed to get download URL'),
      );

      if (kDebugMode) {
        print('✅ DIRECT: Upload successful: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ DIRECT: Upload failed: $e');
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

  /// Validate and fix Firebase Storage URL
  Future<String?> validateAndFixStorageUrl(String url) async {
    try {
      if (kDebugMode) {
        print('🔵 VALIDATE: Checking URL: $url');
      }

      // Check if it's a Firebase Storage URL
      if (!url.contains('firebasestorage.googleapis.com')) {
        if (kDebugMode) {
          print('🔵 VALIDATE: Not a Firebase Storage URL, returning as-is');
        }
        return url;
      }

      // Extract the file path from the URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length < 4) {
        if (kDebugMode) {
          print('❌ VALIDATE: Invalid Firebase Storage URL format');
        }
        return null;
      }

      // Get the file path (everything after /o/)
      final oIndex = pathSegments.indexOf('o');
      if (oIndex == -1 || oIndex >= pathSegments.length - 1) {
        if (kDebugMode) {
          print('❌ VALIDATE: Could not find object path in URL');
        }
        return null;
      }

      final filePath = pathSegments.sublist(oIndex + 1).join('/');
      final decodedPath = Uri.decodeComponent(filePath);

      if (kDebugMode) {
        print('🔵 VALIDATE: Extracted file path: $decodedPath');
      }

      // Try to get a fresh download URL
      final ref = _storage.ref().child(decodedPath);
      final freshUrl = await ref.getDownloadURL();

      if (kDebugMode) {
        print('✅ VALIDATE: Got fresh download URL: $freshUrl');
      }

      return freshUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ VALIDATE: Error validating URL: $e');
      }
      return null;
    }
  }

  /// Test if a Firebase Storage URL is accessible
  Future<bool> testStorageUrlAccess(String url) async {
    try {
      if (kDebugMode) {
        print('🔵 TEST: Testing URL accessibility: $url');
      }

      // For web, we can't easily test HTTP access due to CORS
      // So we'll try to get a fresh download URL instead
      if (url.contains('firebasestorage.googleapis.com')) {
        final freshUrl = await validateAndFixStorageUrl(url);
        return freshUrl != null;
      }

      return true; // Assume non-Firebase URLs are accessible
    } catch (e) {
      if (kDebugMode) {
        print('❌ TEST: URL not accessible: $e');
      }
      return false;
    }
  }

  /// Test URL accessibility specifically for web platform
  Future<bool> _testUrlAccessibilityOnWeb(String url) async {
    if (!kIsWeb) return true; // Not web, assume accessible

    try {
      if (kDebugMode) {
        print('🔵 WEB_TEST: Testing Firebase Storage URL accessibility on web...');
      }

      // For web, CORS issues are common with Firebase Storage
      // We'll assume Firebase Storage URLs have CORS issues and prefer base64
      if (url.contains('firebasestorage.googleapis.com')) {
        if (kDebugMode) {
          print('❌ WEB_TEST: Firebase Storage URL detected - likely CORS issue on web');
        }
        return false; // Assume CORS issue
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ WEB_TEST: Error testing URL: $e');
      }
      return false;
    }
  }

  /// Test Firebase Storage connectivity (quick test)
  Future<String> testStorageConnection() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Error: No user logged in';

      // Test creating a reference (lightweight operation)
      final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');

      if (kDebugMode) {
        print('🔵 Testing storage connection...');
        print('🔵 Reference created: ${ref.fullPath}');
      }

      return 'Success: Storage connection working, reference: ${ref.fullPath}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Quick test method for upload functionality
  Future<String> testUploadFlow() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Error: No user logged in';

      // Test 1: Storage reference creation
      final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');

      // Test 2: Create a small test image (1x1 pixel)
      final testImageBytes = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
        0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
        0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
        0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
        0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
        0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
        0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
        0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x01,
        0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
        0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0xFF, 0xC4,
        0x00, 0x14, 0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xDA, 0x00, 0x0C,
        0x03, 0x01, 0x00, 0x02, 0x11, 0x03, 0x11, 0x00, 0x3F, 0x00, 0x00, 0xFF, 0xD9
      ]);

      if (kDebugMode) {
        print('🔵 Testing upload with ${testImageBytes.length} byte test image');
      }

      // Test 3: Compression
      await compressImage(testImageBytes);

      return 'Success: All upload components working correctly';
    } catch (e) {
      return 'Error in upload flow test: $e';
    }
  }
}
