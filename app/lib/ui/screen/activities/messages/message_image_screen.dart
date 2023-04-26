import 'dart:io';

import 'package:app/main.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MessageImageScreenArgument {
  final String? img;
  final File? file;
  MessageImageScreenArgument({
    this.img,
    this.file,
  });
}

class MessageImageScreen extends StatelessWidget {
  final String? img;
  final File? file;
  const MessageImageScreen({
    super.key,
    required this.img,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          title: const Text(''),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: null,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.close,
              ),
              color: AppTheme.primaryLight,
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              // maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: file == null
                  ? CachedNetworkImage(
                      imageUrl: img!,
                      httpHeaders: {'Authorization': 'Bearer $token'},
                      fit: BoxFit.contain,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : Image.file(
                      file!,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
