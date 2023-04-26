import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ConversationItemCard extends StatelessWidget {
  final Animation<double> animation;
  final Conversation conv;
  final void Function()? onTap;

  const ConversationItemCard({
    super.key,
    required this.conv,
    required this.animation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 4),
        child: _card(context),
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: AppTheme.primaryLight.withOpacity(0.4),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _standard(context),
          ),
        ),
      ),
    );
  }

  Widget _standard(BuildContext context) {
    const double imageSize = 60;

    var unread = 0;
    if (conv.message.from.id == self?.id) {
      unread = conv.unreadMessagener;
    } else {
      unread = conv.unreadReplyer;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.lightGray),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              // maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: conv.to.img == null
                  ? Image.asset('assets/images/person.png', color: Colors.white)
                  : CachedNetworkImage(
                      imageUrl: conv.to.img!,
                      httpHeaders: {'Authorization': 'Bearer $token'},
                      fit: BoxFit.cover,
                      height: imageSize,
                      width: imageSize,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          // fit: FlexFit.loose,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                conv.to.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.merge(AppTheme.medium),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                conv.message.message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        unread == 0
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(left: 4, right: 0),
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
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.merge(AppTheme.whiteStyle),
                    ),
                  ),
                ),
              )
      ],
    );
  }
}
