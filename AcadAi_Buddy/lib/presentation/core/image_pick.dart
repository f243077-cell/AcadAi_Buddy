import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'theme.dart';
import 'widgets/app_snack.dart';

/// Lets the user choose Camera or Gallery, then returns the image bytes
/// resized to at most 1600 px on the long side (or null if cancelled).
Future<Uint8List?> pickImageBytes(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Camera'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Gallery'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return null;

  try {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    return file == null ? null : await file.readAsBytes();
  } catch (_) {
    if (context.mounted) {
      AppSnack.show(
        context,
        source == ImageSource.camera
            ? "Couldn't open the camera. Check the app's permissions."
            : "Couldn't open your photos. Check the app's permissions.",
        tone: SnackTone.error,
      );
    }
    return null;
  }
}
