import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/firestore/users_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:image_picker/image_picker.dart';
import 'package:load/load.dart';

class UserProfileScreenArgumanet {
  final User user;
  final bool editable;
  final bool initial;
  UserProfileScreenArgumanet({this.user, this.editable = false, this.initial = false});
}

class UserProfileScreen extends StatefulWidget {

  final User user;
  final bool editable;
  final bool initial;
  UserProfileScreen({Key key, this.user, this.editable, this.initial = false}) : super(key: key);

  @override
  _UserProfileScreen createState() => _UserProfileScreen();

}

class _UserProfileScreen extends State<UserProfileScreen> {

  TextEditingController _textController;
  TextEditingController _nameTextController;
  FocusNode _focusNode = FocusNode();

  File _selectedBackImage;
  File _selectedImage;

  @override
  void initState() {
    _textController = TextEditingController(text: widget.user?.profile ?? '');
    _nameTextController = TextEditingController(text: widget.user?.name ?? '');
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _nameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.editable)
          _focusNode.unfocus();
        else
          Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: null,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            widget.initial ? Container() :
            IconButton(
              icon: Icon(
                Icons.close,
              ),
              color: AppTheme.primaryLight,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            !widget.editable ? Container() :
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Container(
                  width: 72,
                  height: 36,
                  decoration: new BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    border: Border.all(
                      color: AppTheme.primary,
                      width: 1.5
                    )
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.white24,
                      onTap: () {
                        
                        if (_nameTextController.text == '') return;
                        showAppLoadingWidget();
                        _update();
                        
                      },
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      child: Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: Center(
                          child: Text(
                            'Save',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyText2.merge(AppTheme.whiteStyle).merge(AppTheme.medium),
                          ),
                        )
                      ),
                    ),
                  )
                )
              )
            )
          ],
        ),
        body: SafeArea(
          child: Padding(
              padding: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: widget.editable ? 40 : 60),
              child: GestureDetector(
                child: _card(),
                onTap: () {},
              )
            // )
          ),
        ),
      ),
    );
  }

  Widget _card() {
    double circleSize = 128;
    return Card(
      elevation: 3.0,
      child: Stack(
        children: <Widget>[
          Container(height: double.infinity),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 9 / 16,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: OverflowBox(
                minWidth: 0.0, 
                minHeight: 0.0, 
                // maxWidth: double.infinity,
                maxHeight: double.infinity, 
                child: _selectedBackImage != null 
                ? Image.file(
                    _selectedBackImage,
                    fit: BoxFit.cover,
                  )
                : widget.user?.bgImage != null
                  ? CachedNetworkImage(
                      imageUrl: widget.user.bgImage,
                      httpHeaders: {'Authorization': 'Bearer $token'},
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, downloadProgress) => 
                        CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                    
                  : Image.asset(
                      'assets/images/noimage.png',
                      color: Colors.white,
                      // fit: BoxFit.cover,
                    ),
              )
            )
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 9 / 16,
            decoration: BoxDecoration(
              color: widget.editable ? Colors.black38 : Colors.black12,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  widget.editable ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        getImage(true);
                      },
                      splashColor: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 160,
                        color: Colors.transparent,
                      ),
                    )
                  )
                  : SizedBox(height: 160),
                  PhysicalShape(
                    color: Theme.of(context).cardColor,
                    elevation: 0.0,
                    clipper: UserDetailClipper(radius: (circleSize / 2) + 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 6),
                        Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(circleSize / 2),
                                color: AppTheme.lightGray
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(circleSize / 2),
                                child: OverflowBox(
                                  minWidth: 0.0, 
                                  minHeight: 0.0, 
                                  // maxWidth: double.infinity,
                                  maxHeight: double.infinity, 
                                  child: _selectedImage != null
                                  ? Image.file(
                                      _selectedImage,
                                      fit: BoxFit.cover,
                                    )
                                  : widget.user?.img == null
                                    ? Image.asset('assets/images/person.png', color: Colors.white)
                                    : CachedNetworkImage(
                                      imageUrl: widget.user?.img,
                                      httpHeaders: {'Authorization': 'Bearer $token'},
                                      fit: BoxFit.cover,
                                      height: circleSize,
                                      width: circleSize,
                                      progressIndicatorBuilder: (context, url, downloadProgress) => 
                                        CircularProgressIndicator(value: downloadProgress.progress),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  
                                )
                              )
                            ),
                            widget.editable ? Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  getImage(false);
                                },
                                borderRadius: BorderRadius.circular(circleSize),
                                splashColor: Colors.white24,
                                child: Container(
                                  width: circleSize,
                                  height: circleSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(circleSize),
                                    color: Colors.black38
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.white,
                                      size: 32,
                                    )
                                  ),
                                )
                              )
                            ) : Container()
                          ],
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.only(left: 24, right: 24),
                          child: Material(
                            color: Colors.transparent,
                            child: widget.editable 
                            ? TextField(
                              controller: _nameTextController,
                              decoration: InputDecoration(
                                labelText: 'UserName',
                                hintText: 'Enter username...'
                              ),
                              style: Theme.of(context).textTheme.bodyText1.merge(AppTheme.medium),
                            )
                            : Text(
                              widget.user?.name ?? '',
                              style: Theme.of(context).textTheme.bodyText1.merge(AppTheme.medium),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            )
                          )
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 0),
                          child: Container(
                            height: 1,
                            color: AppTheme.primaryLight.withOpacity(0.5),
                          )
                        ),
                      ],
                    )
                  ),
                  _contents(),
                  SizedBox(height: 12),
                ],
              )
            )
          ),
        ]
      )
    );
  }

  Widget _contents() {
    return Container(
      color: Theme.of(context).cardColor,
      child: Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        child: TextFormField(
          controller: _textController,
          focusNode: _focusNode,
          style: Theme.of(context).textTheme.bodyText1,
          enabled: widget.editable,
          maxLines: null,
          minLines: null,
          decoration: InputDecoration(
            hintText: '',
            hintStyle: Theme.of(context).textTheme.bodyText1,
            contentPadding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 80),
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 0.0,
              ),
            ), 
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 0.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 0.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ), 
          ),
        )
      ),
    );
  }

  Future getImage(bool isBack) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    setState(() {
      if (isBack)
        _selectedBackImage = image;
      else
        _selectedImage = image;
    });
  }

  Future<void> _update() async {
    UsersFirestore firestore = UsersFirestore();

    var authUser = await auth.authUser();
    if (authUser == null) {
      var newUser = await auth.signinInAnonymously();
      token = await auth.token();
      authUser = newUser;
      self = null;
    }

    var id = authUser.uid;

    var user = self;
    if (user == null) {
      user = User(
        id: id,
        name: _nameTextController.text,
        img: null,
        age: null,
        lang: 'ja',
        profile: _textController.text,
        bgImage: null,
        available: true,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        notification: true,
        active: true
      );
    }
    else {
      user.name = _nameTextController.text;
      user.profile = _textController.text;
    }

    if (_selectedBackImage != null) {
      var bgImage = await firestore.uploadImage(id, _selectedBackImage, true);
      user.bgImage = bgImage;
    }
    if (_selectedImage != null) {
      var image = await firestore.uploadImage(id, _selectedImage, false);
      user.img = image;
    }
    
    await firestore.update(user);

    hideLoadingDialog();
    if (widget.initial)
      Navigator.of(context).pushNamed(RouteName.home);
    else
      Navigator.of(context).pop();

  }

}


class UserDetailClipper extends CustomClipper<Path> {

  final double radius;
  UserDetailClipper({this.radius = 80.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    double curveRadius = 8;
    double circleTop = radius / 2;
    double line = math.sqrt(math.pow(radius, 2) - math.pow(radius - circleTop, 2));
  
    path.moveTo(0, (circleTop + curveRadius));
    path.arcToPoint(
      Offset(
        curveRadius,
        circleTop,
      ),
      clockwise: true,
      radius: Radius.circular(curveRadius)
    );
    path.lineTo(size.width / 2  - line, circleTop);

    path.arcToPoint(
      Offset(
        size.width / 2 + line,
        circleTop,
      ),
      clockwise: true,
      radius: Radius.circular(radius)
    );

    path.lineTo(size.width - curveRadius, circleTop);
    path.arcToPoint(
      Offset(
        size.width,
        circleTop + curveRadius,
      ),
      clockwise: true,
      radius: Radius.circular(curveRadius)
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(UserDetailClipper oldClipper) => true;

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}


