
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoAvailableCard extends StatelessWidget {

  final Function callback;

  NoAvailableCard({Key key, this.callback}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 60),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.exclamationCircle,
                  color: AppTheme.attension,
                  size: 60
                ),
                SizedBox(height: 24),
                Text(
                  'Under regulation',
                  style: Theme.of(context).textTheme.headline5
                    .merge(AppTheme.attensionStyle)
                    .merge(AppTheme.bold)
                ),
                SizedBox(height: 24),
                Text(
                  'We have suspended your account for a period of time because more than one person has reported your post.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: 8),
                Text(
                  'Please do not post inappropriate content in the future.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: 24),
                Text(
                  'You can use it again\nafter the suspension period.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ] + (callback != null ? _closeButton(context) : []),
            )
          )
        )
      )
    );
  }

  List<Widget> _closeButton(BuildContext context) {
    return [
      SizedBox(height: 44),
      Padding(
        padding: EdgeInsets.only(left: 24, right: 24),
        child: Container(
          height: 48,
          decoration: new BoxDecoration(
            color: AppTheme.attension,
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.white24,
              onTap: () {
                callback();
              },
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                child: Center(
                  child: Text(
                    'CLOSE',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1.merge(AppTheme.whiteStyle).merge(AppTheme.medium),
                  ),
                )
              ),
            ),
          )
        )
      )
    ];
  }

}