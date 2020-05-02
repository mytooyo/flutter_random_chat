
import 'package:app/ui/screen/contents/no_available_card.dart';
import 'package:flutter/material.dart';

class NoAvailableScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 80, left: 40, right: 40),
                  child: NoAvailableCard(
                    callback: () {
                      Navigator.of(context).pop();
                    }
                  )
                )
              ],
            ),
               
          )
        )
      )
    );
  }
}