import 'package:app/bloc/users/active_users_bloc.dart';
import 'package:app/bloc/users/unread_replys_bloc.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class HomeCardComponent {
  final BuildContext context;
  HomeCardComponent({required this.context});

  Widget activitiesCard() {
    final activeBloc = Provider.of<ActiveUsersBloc>(context);
    final unreadBloc = Provider.of<UnreadReplysBloc>(context);
    const double size = 72;

    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      child: Card(
        elevation: 2.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(size),
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                  width: size * 2 + 24,
                  height: size * 2 + 24,
                  child: ClipRect(
                      child: CustomPaint(painter: ActivitiesCardPainter()))),
            ),
            SizedBox(
              height: size * 2 + 48,
              child: InkWell(
                splashColor: Colors.white24,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(size),
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
                onTap: () {
                  Navigator.of(context).pushNamed(RouteName.activities);
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: size,
                                child: Stack(
                                  fit: StackFit.passthrough,
                                  children: <Widget>[
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Icon(
                                        FontAwesomeIcons.globeAsia,
                                        size: size,
                                        // color: AppTheme.primary.withOpacity(0.2),
                                        color: AppTheme.gray.withOpacity(0.25),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 32),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Material(
                                            color: Colors.transparent,
                                            child: Text(
                                              'Activities',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.merge(AppTheme.bold),
                                              textAlign: TextAlign.left,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: size * 0.3),
                              SizedBox(
                                // color: Colors.red,
                                height: size * 0.7,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                          child: StreamBuilder(
                                              stream: activeBloc.stream,
                                              initialData: 0,
                                              builder: (_, snapshot) {
                                                return _cardItem('Active Users',
                                                    snapshot.data as int);
                                              })),
                                      Container(
                                        width: 4,
                                        height: size,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.3)),
                                      ),
                                      Expanded(
                                        child: StreamBuilder(
                                          stream: unreadBloc.stream,
                                          initialData: 0,
                                          builder: (_, snapshot) {
                                            return _cardItem(
                                                'Unread', snapshot.data as int);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Center(
                            child: Icon(
                          FontAwesomeIcons.angleRight,
                          size: 28,
                          color: AppTheme.primaryDark,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardItem(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Material(
              color: Colors.transparent,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              )),
          Expanded(child: Container()),
          SizedBox(
            width: double.infinity,
            child: Material(
                color: Colors.transparent,
                child: Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.right,
                )),
          )
        ],
      ),
    );
  }

  Widget menuTiles() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      child: Row(
        children: <Widget>[
          _tile(FontAwesomeIcons.history, 'History', () {
            Navigator.of(context).pushNamed(
              RouteName.history,
            );
          }),
          _primaryTile(FontAwesomeIcons.solidPaperPlane, 'Post', () {
            Navigator.of(context).pushNamed(
              RouteName.post,
            );
          }),
          _tile(FontAwesomeIcons.cog, 'Settings', () {
            Navigator.of(context).pushNamed(
              RouteName.settings,
            );
          }),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, void Function() callback) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Card(
          elevation: 2.0,
          child: InkWell(
            splashColor: Colors.white24,
            onTap: callback,
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      icon,
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    Material(
                        color: Colors.transparent,
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.merge(AppTheme.bold),
                          textAlign: TextAlign.right,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryTile(IconData icon, String title, void Function() callback) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Card(
          elevation: 2.0,
          color: AppTheme.primary,
          child: InkWell(
            splashColor: Colors.white24,
            onTap: callback,
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      icon,
                      size: 36,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Material(
                        color: Colors.transparent,
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.merge(AppTheme.bold)
                              .merge(AppTheme.whiteStyle),
                          textAlign: TextAlign.right,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActivitiesCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = AppTheme.primary.withOpacity(0.25);
    // paint.color = Colors.blue.withOpacity(0.2);
    var path = Path();

    double lineWidth = 72;
    path.moveTo(0, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height - lineWidth);
    path.lineTo(lineWidth, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
