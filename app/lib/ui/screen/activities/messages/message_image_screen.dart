
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/main.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';

class MessageImageScreenArgument {
  final String img;
  final File file;
  MessageImageScreenArgument({this.img, this.file});
}

class MessageImageScreen extends StatelessWidget {

  final String img;
  final File file;
  MessageImageScreen({Key key, this.img, this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          title: Text(''),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: null,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(
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
          child: Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: OverflowBox(
                minWidth: 0.0, 
                minHeight: 0.0, 
                // maxWidth: double.infinity,
                maxHeight: double.infinity, 
                child: file == null 
                  ? CachedNetworkImage(
                    imageUrl: img,
                    httpHeaders: {'Authorization': 'Bearer $token'},
                    fit: BoxFit.contain,
                    progressIndicatorBuilder: (context, url, downloadProgress) => 
                      CircularProgressIndicator(value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )
                  : Image.file(
                    file,
                    fit: BoxFit.contain,
                  )
              )
            )
          ),
        ),
      )
    );
  }

}