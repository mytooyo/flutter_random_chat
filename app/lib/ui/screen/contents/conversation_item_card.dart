import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';

class ConversationItemCard extends StatelessWidget {

  final BuildContext context;
  final Animation animation;
  final Conversation conv;
  final Function onTap;

  ConversationItemCard({Key key, this.context, this.conv, this.animation, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: Padding(
        padding: EdgeInsets.only(left: 0, right: 0, bottom: 4),
        child: _card()
      )
    );
  }

  Widget _card() {
    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: AppTheme.primaryLight.withOpacity(0.4),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _standard()
          )
        )
      )
    );
  }

  Widget _standard() {
    const double _imageSize = 60;
    
    var unread = 0;
    if (conv.message.from.id == self.id) {
      unread = conv.unreadMessagener;
    }
    else {
      unread = conv.unreadReplyer;
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
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
              child: conv.to?.img == null
              ? Image.asset('assets/images/person.png', color: Colors.white)
              : CachedNetworkImage(
                imageUrl: conv.to?.img,
                httpHeaders: {'Authorization': 'Bearer $token'},
                fit: BoxFit.cover,
                height: _imageSize,
                width: _imageSize,
                progressIndicatorBuilder: (context, url, downloadProgress) => 
                  CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            )
          )
        ),
        SizedBox(width: 16),
        Expanded(
          // fit: FlexFit.loose,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  conv.to?.name ?? '',
                  style: Theme.of(context).textTheme.bodyText1.merge(AppTheme.medium),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              ),
              SizedBox(height: 4),
              Container(
                child: Text(
                  conv.message.message ?? '',
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              )
            ],
          ),
        ),
        unread == 0 ? Container() : Padding(
          padding: EdgeInsets.only(left: 4, right: 0),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.attension,
            ),
            child: Center(
              child: Text(
                unread.toString(),
                style: Theme.of(context).textTheme.bodyText2.merge(AppTheme.whiteStyle),
              ),
            ),
          )
        )
      ],
    );
  }
}