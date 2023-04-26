import 'package:app/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';

class AppBackgroundPattern extends StatelessWidget {
  final bool logo;
  const AppBackgroundPattern({
    super.key,
    this.logo = false,
  });

  @override
  Widget build(BuildContext context) {
    double half = MediaQuery.of(context).size.width;
    return Positioned(
        child: Stack(
      children: <Widget>[
        logo
            ? Center(
                child: Opacity(
                  opacity: 0.12,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            MediaQuery.platformBrightnessOf(context) ==
                                    Brightness.dark
                                ? 'assets/images/logo_dark.png'
                                : 'assets/images/logo_light.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
        Positioned(
            top: -(half / 2),
            right: -(half / 2),
            child: _circlePattern(context, half)),
        Positioned(top: 60, left: 44, child: _circlePattern(context, 100)),
        Positioned(top: 180, left: 16, child: _circlePattern(context, 60)),
        Positioned(top: 240, left: 80, child: _circlePattern(context, 80)),
        Positioned(
            bottom: -(half / 2),
            left: -(half / 2),
            child: _circlePattern(context, half)),
        Positioned(bottom: 200, right: 12, child: _circlePattern(context, 240)),
      ],
    ));
  }

  Widget _circlePattern(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size),
        color: MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? AppTheme.whiteGray.withOpacity(0.13)
            : AppTheme.lightGray.withOpacity(0.1),
      ),
    );
  }
}
