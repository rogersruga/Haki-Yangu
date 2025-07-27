import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// A robust profile image widget that handles Firebase Storage URLs, base64 data URLs,
/// and provides comprehensive error handling for HTTP status code 0 and CORS issues
class RobustProfileImage extends StatefulWidget {
  final User? user;
  final double size;
  final Color? iconColor;

  const RobustProfileImage({
    super.key,
    required this.user,
    this.size = 50,
    this.iconColor,
  });

  @override
  State<RobustProfileImage> createState() => _RobustProfileImageState();
}

class _RobustProfileImageState extends State<RobustProfileImage> {
  String? _validatedUrl;
  bool _isValidating = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _validateImageUrl();
  }

  @override
  void didUpdateWidget(RobustProfileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.photoURL != widget.user?.photoURL) {
      _validateImageUrl();
    }
  }

  Future<void> _validateImageUrl() async {
    final photoURL = widget.user?.photoURL;
    
    if (photoURL == null || photoURL.isEmpty) {
      setState(() {
        _validatedUrl = null;
        _isValidating = false;
        _hasError = false;
      });
      return;
    }

    if (kDebugMode) {
      print('🔵 ROBUST_IMAGE: Validating URL for user ${widget.user?.uid}');
      print('🔵 ROBUST_IMAGE: Original URL: $photoURL');
    }

    setState(() {
      _isValidating = true;
      _hasError = false;
    });

    try {
      // Handle base64 data URLs
      if (photoURL.startsWith('data:image/')) {
        if (kDebugMode) {
          print('🔵 ROBUST_IMAGE: Base64 data URL detected');
        }
        setState(() {
          _validatedUrl = photoURL;
          _isValidating = false;
        });
        return;
      }

      // Handle Firebase Storage URLs
      if (photoURL.contains('firebasestorage.googleapis.com')) {
        if (kDebugMode) {
          print('🔵 ROBUST_IMAGE: Firebase Storage URL detected, getting fresh download URL...');
        }
        
        final freshUrl = await _getFreshDownloadUrl(photoURL);
        if (freshUrl != null) {
          if (kDebugMode) {
            print('✅ ROBUST_IMAGE: Got fresh download URL: $freshUrl');
          }
          setState(() {
            _validatedUrl = freshUrl;
            _isValidating = false;
          });
        } else {
          if (kDebugMode) {
            print('❌ ROBUST_IMAGE: Failed to get fresh download URL');
          }
          setState(() {
            _validatedUrl = null;
            _isValidating = false;
            _hasError = true;
          });
        }
        return;
      }

      // Handle regular URLs
      if (kDebugMode) {
        print('🔵 ROBUST_IMAGE: Regular URL, using as-is');
      }
      setState(() {
        _validatedUrl = photoURL;
        _isValidating = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ ROBUST_IMAGE: Error validating URL: $e');
      }
      setState(() {
        _validatedUrl = null;
        _isValidating = false;
        _hasError = true;
      });
    }
  }

  Future<String?> _getFreshDownloadUrl(String originalUrl) async {
    try {
      final user = widget.user;
      if (user == null) return null;

      if (kDebugMode) {
        print('🔵 ROBUST_IMAGE: Attempting to get fresh download URL...');
        print('🔵 ROBUST_IMAGE: Original URL: $originalUrl');
      }

      // For web platform, try to get image data directly and convert to base64
      if (kIsWeb) {
        if (kDebugMode) {
          print('🔵 ROBUST_IMAGE: Web platform detected, trying direct Firebase Storage access...');
        }

        // Extract file path from the original URL
        final uri = Uri.parse(originalUrl);
        final pathSegments = uri.pathSegments;

        // Find the object path (after /o/)
        final oIndex = pathSegments.indexOf('o');
        if (oIndex == -1 || oIndex >= pathSegments.length - 1) {
          if (kDebugMode) {
            print('❌ ROBUST_IMAGE: Could not extract file path from URL');
          }
          return null;
        }

        final filePath = pathSegments.sublist(oIndex + 1).join('/');
        final decodedPath = Uri.decodeComponent(filePath);

        if (kDebugMode) {
          print('🔵 ROBUST_IMAGE: Extracted file path: $decodedPath');
        }

        // Try to get the image data directly from Firebase Storage
        final ref = FirebaseStorage.instance.ref().child(decodedPath);

        try {
          // Get image data as bytes
          final imageData = await ref.getData();
          if (imageData != null) {
            // Convert to base64 data URL
            final base64String = base64Encode(imageData);
            final dataUrl = 'data:image/jpeg;base64,$base64String';

            if (kDebugMode) {
              print('✅ ROBUST_IMAGE: Successfully converted to base64 data URL');
              print('🔵 ROBUST_IMAGE: Data URL length: ${dataUrl.length}');
            }

            return dataUrl;
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ ROBUST_IMAGE: Failed to get image data: $e');
          }
        }

        // Fallback: try to get a fresh download URL
        try {
          final freshUrl = await ref.getDownloadURL();
          if (kDebugMode) {
            print('🔵 ROBUST_IMAGE: Got fresh download URL: $freshUrl');
          }
          return freshUrl;
        } catch (e) {
          if (kDebugMode) {
            print('❌ ROBUST_IMAGE: Failed to get fresh download URL: $e');
          }
        }
      } else {
        // For mobile platforms, just get a fresh download URL
        final uri = Uri.parse(originalUrl);
        final pathSegments = uri.pathSegments;

        final oIndex = pathSegments.indexOf('o');
        if (oIndex == -1 || oIndex >= pathSegments.length - 1) {
          return null;
        }

        final filePath = pathSegments.sublist(oIndex + 1).join('/');
        final decodedPath = Uri.decodeComponent(filePath);

        final ref = FirebaseStorage.instance.ref().child(decodedPath);
        final freshUrl = await ref.getDownloadURL();

        if (kDebugMode) {
          print('✅ ROBUST_IMAGE: Got fresh download URL for mobile: $freshUrl');
        }

        return freshUrl;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ROBUST_IMAGE: Error getting fresh download URL: $e');
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? Theme.of(context).colorScheme.primary;
    
    // Show loading indicator while validating
    if (_isValidating) {
      return SizedBox(
        width: widget.size * 2,
        height: widget.size * 2,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // Show default icon if no URL or validation failed
    if (_validatedUrl == null || _hasError) {
      return Icon(
        Icons.person,
        size: widget.size,
        color: iconColor,
      );
    }

    // Handle base64 data URLs
    if (_validatedUrl!.startsWith('data:image/')) {
      return _buildBase64Image(_validatedUrl!, iconColor);
    }

    // Handle network URLs (Firebase Storage or regular)
    return _buildNetworkImage(_validatedUrl!, iconColor);
  }

  Widget _buildBase64Image(String dataUrl, Color iconColor) {
    try {
      final base64Data = dataUrl.split(',')[1];
      final imageBytes = base64Decode(base64Data);
      
      return ClipOval(
        child: Image.memory(
          imageBytes,
          width: widget.size * 2,
          height: widget.size * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              print('❌ ROBUST_IMAGE: Error loading base64 image: $error');
            }
            return Icon(Icons.person, size: widget.size, color: iconColor);
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ ROBUST_IMAGE: Error decoding base64: $e');
      }
      return Icon(Icons.person, size: widget.size, color: iconColor);
    }
  }

  Widget _buildNetworkImage(String url, Color iconColor) {
    return ClipOval(
      child: Image.network(
        url,
        width: widget.size * 2,
        height: widget.size * 2,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            if (kDebugMode) {
              print('✅ ROBUST_IMAGE: Network image loaded successfully');
            }
            return child;
          }
          return const CircularProgressIndicator(strokeWidth: 2);
        },
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('❌ ROBUST_IMAGE: Network image error: $error');
            print('❌ ROBUST_IMAGE: URL: $url');
            
            // Analyze error type
            final errorString = error.toString().toLowerCase();
            if (errorString.contains('statuscode: 0')) {
              print('❌ ROBUST_IMAGE: HTTP Status 0 - CORS or connectivity issue');
            } else if (errorString.contains('403')) {
              print('❌ ROBUST_IMAGE: HTTP 403 - Permission denied');
            } else if (errorString.contains('404')) {
              print('❌ ROBUST_IMAGE: HTTP 404 - Image not found');
            }
          }
          
          // Trigger re-validation on error
          Future.microtask(() => _validateImageUrl());
          
          return Icon(Icons.person, size: widget.size, color: iconColor);
        },
      ),
    );
  }
}
