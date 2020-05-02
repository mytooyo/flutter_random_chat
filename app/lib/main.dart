import 'package:app/auth/app_auth.dart';
import 'package:app/firestore/users_firestore.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:app/ui/utilities/app_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:load/load.dart';
import 'package:flutter/material.dart';

AppAuth auth;
String token;
FirebaseUser user;
User self;

bool isDebug = false;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  assert(isDebug = true);
  
  auth = AppAuth();
  user = await auth.authUser();
  
  var initialize = false;
  if (user != null) {
    token = await auth.token();
    UsersFirestore().activate(true);
    self = await UsersFirestore().cache();
  }
  else {
    initialize = true;
  }

  runApp(
    LoadingProvider(
      child: MyApp(initialize)
    )
  );
}

class MyApp extends StatelessWidget {  

  final bool initialize;
  MyApp(this.initialize);

  @override
  Widget build(BuildContext context) {

    
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
        // statusBarColor: Colors.transparent,
        // statusBarIconBrightness: Brightness.light,
        // statusBarBrightness: Brightness.light,
        // systemNavigationBarColor: Colors.black,
        // systemNavigationBarDividerColor: Colors.grey,
        // systemNavigationBarIconBrightness: Brightness.dark,
    //   )
    // );
    return MaterialApp(
      title: "app",
      debugShowCheckedModeBanner: false,
      // localizationsDelegates: [
      //   const _MyLocalizationsDelegate(),
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      // ],
      // supportedLocales: [
      //   const Locale('en', 'US'), // English
      //   const Locale('ja', 'JA'), // Japan
      // ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: initialize ? RouteName.start : RouteName.home,
      onGenerateRoute: Router.onGenerateRoute,

    );
  }
}


void showAppLoadingWidget() {
  showCustomLoadingWidget(
    AppLoader(
      radius: 48,
      dotRadius: 16.0,
    ),
    tapDismiss: false
  );
}