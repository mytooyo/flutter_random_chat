import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/activities/messages/message_image_screen.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:app/ui/utilities/app_date.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HistoryItemCard extends StatelessWidget {
  final Animation<double> animation;
  final Message message;
  final void Function()? onTap;

  const HistoryItemCard({
    super.key,
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
          child: _card(context),
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
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
                _standard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _standard(BuildContext context) {
    const double imageSize = 60;
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
              Text(
                dateFormatted(
                    DateTime.fromMillisecondsSinceEpoch(message.timestamp),
                    format: 'yyyy/MM/dd HH:mm'),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                message.message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        message.img == null
            ? Container()
            : SizedBox(
                width: imageSize,
                height: imageSize,
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
                          imageUrl: message.img!,
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
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        RouteName.showImage,
                        arguments:
                            MessageImageScreenArgument(img: message.img!),
                      );
                    },
                  ),
                ),
              ),
      ],
    );
  }
}
