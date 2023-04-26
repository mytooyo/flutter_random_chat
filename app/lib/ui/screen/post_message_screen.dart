import 'dart:io';

import 'package:app/firestore/messages_firestore.dart';
import 'package:app/main.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/activities/messages/message_image_screen.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:app/ui/utilities/app_images.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:load/load.dart';

class PostMessageScreen extends StatefulWidget {
  const PostMessageScreen({super.key});

  @override
  State<PostMessageScreen> createState() => _PostMessageScreen();
}

class _PostMessageScreen extends State<PostMessageScreen> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _textController;

  File? _selectedImage;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        } else {
          _focusNode.requestFocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post Message'),
          backgroundColor: Colors.transparent,
          centerTitle: true,
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
        body: SafeArea(child: _builder()),
      ),
    );
  }

  Widget _builder() {
    return Column(
      children: <Widget>[_main(), _keyboardAccessoryWidget()],
    );
  }

  Widget _main() {
    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
        child: Card(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    type: MaterialType.transparency,
                    child: TextFormField(
                      controller: _textController,
                      autofocus: true,
                      focusNode: _focusNode,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Post Meessage...',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.merge(AppTheme.lightGrayStyle),
                        contentPadding: const EdgeInsets.all(8),
                        fillColor: Theme.of(context).cardColor,
                        filled: false,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.primary.withOpacity(0.4),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      maxLines: null,
                      minLines: null,
                      keyboardType: TextInputType.multiline,
                      onTap: () {},
                      onChanged: (value) {},
                    ),
                  ),
                  _selectedImage == null
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _image(),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _image() {
    return Stack(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: OverflowBox(
                    minWidth: 0.0,
                    minHeight: 0.0,
                    // maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed(
                  RouteName.showImage,
                  arguments: MessageImageScreenArgument(file: _selectedImage!),
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.white12,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppTheme.primaryDark),
                child: const Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedImage = null;
                });
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _keyboardAccessoryWidget() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black26,
        //     spreadRadius: 1.0,
        //     blurRadius: 6.0,
        //     offset: Offset(0, -2)
        //   )
        // ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: AppTheme.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppTheme.primary),
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const <Widget>[
                          Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ))),
                  onTap: () {
                    getImage();
                  },
                ),
              ),
            ),
            Expanded(child: Container()),
            Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                border: Border.all(color: AppTheme.primary, width: 1.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.white24,
                  onTap: () {
                    if (_textController.text == '') return;

                    _focusNode.unfocus();
                    showAppLoadingWidget();

                    _post();
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 4, bottom: 4, left: 8, right: 8),
                    child: Center(
                      child: Text(
                        'Send',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.merge(AppTheme.whiteStyle)
                            .merge(AppTheme.medium),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Future getImage() async {
    final image = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );

    if (image?.path == null) return;

    // RotateはiOSの場合のみ行う
    File newImage = File(image!.path);
    if (Platform.isIOS) {
      newImage = await fixExifRotation(image.path);
    }

    setState(() {
      _selectedImage = newImage;
    });
  }

  Future<void> _post() async {
    final firestore = MessagesFirestore();

    // Firestore and Storageに登録
    firestore.post(_textController.text, file: _selectedImage!).then((_) {
      hideLoadingDialog();
      Navigator.of(context).pop();
    });
  }
}
