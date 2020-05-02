import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/activities/messages/message_image_screen.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:app/ui/utilities/app_date.dart';
import 'package:flutter/material.dart';

class HistoryItemCard extends StatelessWidget {

  final BuildContext context;
  final Animation animation;
  final Message message;
  final Function onTap;

  HistoryItemCard({Key key, this.context, this.message, this.animation, this.onTap}) : super(key: key);
  
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
        Expanded(
          // fit: FlexFit.loose,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  dateFormatted(
                    DateTime.fromMillisecondsSinceEpoch(message.timestamp),
                    format: 'yyyy/MM/dd HH:mm'
                  ),
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              ),
              SizedBox(height: 4),
              Container(
                child: Text(
                  message.message,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                )
              )
            ],
          ),
        ),
        SizedBox(width: 16),
        message.img == null ? Container()
        : Container(
          width: _imageSize,
          height: _imageSize,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
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
                    height: _imageSize,
                    width: _imageSize,
                    progressIndicatorBuilder: (context, url, downloadProgress) => 
                      CircularProgressIndicator(value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
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
        ),
      ],
    );
  }


}
