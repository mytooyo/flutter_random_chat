import 'package:app/ui/theme/app_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoAvailableCard extends StatelessWidget {
  final void Function()? callback;

  const NoAvailableCard({
    super.key,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 60),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                const Icon(FontAwesomeIcons.exclamationCircle,
                    color: AppTheme.attension, size: 60),
                const SizedBox(height: 24),
                Text('Under regulation',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.merge(AppTheme.attensionStyle)
                        .merge(AppTheme.bold)),
                const SizedBox(height: 24),
                Text(
                  'We have suspended your account for a period of time because more than one person has reported your post.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please do not post inappropriate content in the future.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  'You can use it again\nafter the suspension period.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                ...(callback != null ? _closeButton(context) : []),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _closeButton(BuildContext context) {
    return [
      const SizedBox(height: 44),
      Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Container(
          height: 48,
          decoration: const BoxDecoration(
            color: AppTheme.attension,
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.white24,
              onTap: () {
                callback?.call();
              },
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                child: Center(
                  child: Text(
                    'CLOSE',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.merge(AppTheme.whiteStyle)
                        .merge(AppTheme.medium),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }
}
