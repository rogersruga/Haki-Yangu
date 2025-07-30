import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Simple Dart script to generate app icon
/// Run with: dart run generate_icon.dart

void main() async {
  print('Generating Haki Yangu app icon...');
  
  // Create the icon widget
  final iconWidget = AppIconWidget();
  
  // This would need to be run in a Flutter environment
  // For now, let's create a simple description
  print('Icon design:');
  print('- Green circular background (#1B5E20)');
  print('- White inner circle');
  print('- Balance/scales of justice in green');
  print('- "HAKI YANGU" text at bottom');
  print('');
  print('To generate the actual icon:');
  print('1. Open create_simple_icon.html in a web browser');
  print('2. Click "Generate Icon" then "Download PNG"');
  print('3. Save the downloaded file as assets/images/app_icon.png');
  print('4. Run: flutter pub get');
  print('5. Run: flutter pub run flutter_launcher_icons');
}

class AppIconWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1024,
      height: 1024,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1B5E20), // Green background
      ),
      child: Container(
        margin: EdgeInsets.all(100),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Balance icon
            Icon(
              Icons.balance,
              size: 400,
              color: Color(0xFF1B5E20),
            ),
            SizedBox(height: 50),
            // App name
            Text(
              'HAKI YANGU',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
