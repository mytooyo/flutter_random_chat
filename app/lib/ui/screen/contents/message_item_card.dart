import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/activities/messages/message_image_screen.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MessageItemCard extends StatelessWidget {
  final BuildContext context;
  final Animation<double> animation;
  final Message message;
  final void Function()? onTap;

  const MessageItemCard({
    super.key,
    required this.context,
    required this.message,
    required this.animation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
        child: Hero(
          tag: message.id,
          child: _card(),
        ),
      ),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _standard(),
                message.img == null ? Container() : _postImage(),
                // _bottomArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _standard() {
    const double imageSize = 60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
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
              child: message.from.img == null
                  ? Image.asset('assets/images/person.png', color: Colors.white)
                  : CachedNetworkImage(
                      imageUrl: message.from.img!,
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
        Flexible(
          // fit: FlexFit.loose,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message.from.name,
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
                message.message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _postImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: OverflowBox(
                minWidth: 0.0,
                minHeight: 0.0,
                // maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: message.img!,
                  httpHeaders: {'Authorization': 'Bearer $token'},
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              RouteName.showImage,
              arguments: MessageImageScreenArgument(img: message.img!),
            );
          },
        ),
      ),
    );
  }

  bool get _isLiked => message.likes.contains(user?.uid ?? 'aaaaaaaa');
}
