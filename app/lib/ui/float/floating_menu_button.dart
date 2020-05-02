import 'dart:math' as math;

import 'dart:ui';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FloatButtonBackground extends StatelessWidget {

  final Color color;
  final Function tapCallBack;

  FloatButtonBackground({this.color, this.tapCallBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        tapCallBack();
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: Container(
          color: color,
        ),
      )
    );
  }
}

class FoldFloatingButton extends StatelessWidget {

  final bool isExpanded;

  // ** メニュー表示時に表示されるFAB
  final Function floatOpenCallback;

  //** 折り畳まれれるFAB　**//
  final List<Widget> expandedWidget;
  
  final AnimationController controller;

  final Animation<double> fadeAnimation;

  FoldFloatingButton({
    @required this.isExpanded,
    @required this.floatOpenCallback,
    @required this.expandedWidget,
    @required this.controller,
    @required this.fadeAnimation,
  });

  Widget _fadeAnimationWidget({@required Widget child}) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Transform(
        transform: Matrix4.translationValues(0.0, 20 * (1.0 - fadeAnimation.value), 0.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: child
        )
      ),
    );
  }

  Widget _backgroundWidget() {
    return Positioned(
      top: 0,
      left: 0,
      right: -32,  //Scaffoldによるマージン
      bottom:  -32,
      child: _fadeAnimationWidget(
        child: FloatButtonBackground(
          color: Color.fromARGB(200, 255, 255, 255),
          tapCallBack: floatOpenCallback,
        )
      )
    );
  }

  Widget _floatingButtonWidget(double bottomPadding) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Column(
        children: <Widget>[
          isExpanded ? _fadeAnimationWidget(child: Column(children: expandedWidget)) : Container(),
          _floatingMainButtonWidget(),
        ],
      )
    );
    
  }

  Widget _floatingMainButtonWidget() {
    return Row(
      children: <Widget>[
        Container(width: 270),
        SizedBox(width: 12),
        Transform.rotate(
          angle: controller.value * 2.0 * math.pi,
          origin: Offset.zero,
          child: FloatingActionButton(
            onPressed: floatOpenCallback,
            backgroundColor: controller.value > 0.5 ? AppTheme.primary : Colors.white,
            child: controller.value > 0.5
              ? Center(
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: AppTheme.white,
                )
              )
              : Center(
                child: Icon(
                  FontAwesomeIcons.bars,
                  size: 24,
                  color: AppTheme.white,
                )
              ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = math.max(MediaQuery.of(context).padding.bottom - 9.0, 0.0);
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Stack(
          fit: StackFit.expand,
          overflow: Overflow.visible,
          children: <Widget>[
            // ***********************************************
            // * Background Widget
            // ***********************************************
            isExpanded ? _backgroundWidget() : Container(),
            // ***********************************************
            // * Floating Button 
            // ***********************************************
            _floatingButtonWidget(bottomPadding)
          ],
        );
      },
    );

    
  }
}