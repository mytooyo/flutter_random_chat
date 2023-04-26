import 'package:app/main.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/user_profile_screen.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HomeProfileComponent {
  final BuildContext context;
  final TextEditingController textController;
  final bool panelOpened;
  final double panelOffset;

  HomeProfileComponent({
    required this.context,
    required this.textController,
    required this.panelOpened,
    required this.panelOffset,
  });

  Widget card() {
    return Card(
      color: Theme.of(context).canvasColor.withOpacity(panelOffset),
      elevation: 0,
      child: Stack(
        children: _backgroundImage() + [_userMain()],
      ),
    );
  }

  List<Widget> _backgroundImage() {
    return [
      Opacity(
        opacity: panelOffset,
        child: Stack(
          children: <Widget>[
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
                  child: self?.bgImage != null
                      ? CachedNetworkImage(
                          imageUrl: self!.bgImage!,
                          httpHeaders: {'Authorization': 'Bearer $token'},
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Image.asset(
                          'assets/images/noimage.png',
                          color: Colors.white,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 9 / 16,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _userMain() {
    double circleSize = 120;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 160 * panelOffset),
        PhysicalShape(
          color: Theme.of(context).canvasColor,
          elevation: 0.0,
          clipper: UserDetailClipper(radius: (circleSize / 2) + 6),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(height: 6),
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(circleSize / 2),
                        color: AppTheme.lightGray),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(circleSize / 2),
                      child: OverflowBox(
                        minWidth: 0.0,
                        minHeight: 0.0,
                        // maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: self?.img == null
                            ? Image.asset('assets/images/person.png',
                                color: Colors.white, fit: BoxFit.cover)
                            : CachedNetworkImage(
                                imageUrl: self!.img!,
                                httpHeaders: {'Authorization': 'Bearer $token'},
                                fit: BoxFit.cover,
                                height: circleSize,
                                width: circleSize,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        self?.name ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.merge(AppTheme.medium),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: panelOffset,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 20),
                      child: Container(
                        height: 1,
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
              panelOpened ? _changeProfile() : Container()
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: _contents(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  Widget _changeProfile() {
    return Positioned(
      right: 12,
      top: 52,
      child: Container(
        width: 72,
        height: 36,
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            border: Border.all(color: AppTheme.primary, width: 1.5)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white24,
            onTap: () {
              Navigator.of(context).pushNamed(
                RouteName.userProfile,
                arguments:
                    UserProfileScreenArgumanet(user: self, editable: true),
              );
            },
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
              child: Center(
                child: Text(
                  'Change',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.merge(AppTheme.primaryStyle)
                      .merge(AppTheme.medium),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contents() {
    return Container(
      color: Theme.of(context).canvasColor,
      child: Material(
        color: Colors.transparent,
        type: MaterialType.transparency,
        child: TextFormField(
          controller: textController,
          style: Theme.of(context).textTheme.bodyLarge,
          enabled: false,
          maxLines: null,
          decoration: InputDecoration(
            hintText: '',
            hintStyle: Theme.of(context).textTheme.bodyLarge,
            contentPadding:
                const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 12),
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 0.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
