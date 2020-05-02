import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/bloc/messages/messages_bloc.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/activities/messages/message_image_screen.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:app/ui/utilities/app_date.dart';
import 'package:flutter/material.dart';

class MessageItemCard extends StatelessWidget {
  
  final BuildContext context;
  final Animation animation;
  final Message message;
  final Function onTap;

  MessageItemCard({Key key, this.context, this.message, this.animation, this.onTap}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 4),
        child: Hero(
          tag: message.id,
          child: _card()
        )
      )
    );
  }

  Widget _card() {
    return Card(
      elevation: 3.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: AppTheme.primaryLight.withOpacity(0.4),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _standard(),
                message.img == null ? Container() : _postImage(),
                // _bottomArea(),
              ],
            )
          )
        )
      )
      
    );
  }

  Widget _standard() {
    const double _imageSize = 60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: _imageSize,
          height: _imageSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.lightGray
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: OverflowBox(
              minWidth: 0.0, 
              minHeight: 0.0, 
              // maxWidth: double.infinity,
              maxHeight: double.infinity, 
              child: message.from?.img == null
              ? Image.asset('assets/images/person.png', color: Colors.white)
              : CachedNetworkImage(
                imageUrl: message.from.img,
                httpHeaders: {'Authorization': 'Bearer $token'},
                fit: BoxFit.cover,
                height: _imageSize,
                width: _imageSize,
                progressIndicatorBuilder: (context, url, downloadProgress) => 
                  CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
            )
          )
        ),
        SizedBox(width: 16),
        Flexible(
          // fit: FlexFit.loose,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  message.from?.name ?? '',
                  style: Theme.of(context).textTheme.bodyText1.merge(AppTheme.medium),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              ),
              SizedBox(height: 4),
              Container(
                child: Text(
                  message.message ?? '',
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                )
              )
            ],
          ),
        ),
        
      ],
    );
  }

  Widget _postImage() {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: OverflowBox(
                minWidth: 0.0, 
                minHeight: 0.0, 
                // maxWidth: double.infinity,
                maxHeight: double.infinity, 
                child: CachedNetworkImage(
                  imageUrl: message.img,
                  httpHeaders: {'Authorization': 'Bearer $token'},
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) => 
                    CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              )
            )
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              RouteName.showImage,
              arguments: MessageImageScreenArgument(img: message.img)
            );
          },
        )
      )
    );
  }

  bool get _isLiked => message.likes.contains(user?.uid ?? 'aaaaaaaa');

  Widget _bottomArea() {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 0),
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              dateFormatted(DateTime.now()),
              style: Theme.of(context).textTheme.caption,
            ),
            Expanded(child: Container()),
            InkWell(
              splashColor: Colors.white24,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 40,
                width: 40,
                child: Center(
                  child: Icon(
                    Icons.reply,
                    color: AppTheme.primary,
                    size: 28,
                  )
                )
              ),
              onTap: () {
                
              },
            ),
            SizedBox(width: 16),
            InkWell(
              splashColor: Colors.white24,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 40,
                width: 40,
                child: Center(
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.pinkAccent : Theme.of(context).cursorColor,
                    size: 28,
                  )
                )
              ),
              onTap: () {
                MessageBloc.shared.updateLike(message, !_isLiked);
              },
            ),
          ],
        )
      )
    );
  }

}