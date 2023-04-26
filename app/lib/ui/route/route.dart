import 'package:app/bloc/messages/histories_bloc.dart';
import 'package:app/bloc/messages/messages_bloc.dart';
import 'package:app/bloc/reply/conversation_bloc.dart';
import 'package:app/bloc/reply/replys_bloc.dart';
import 'package:app/bloc/self_user_available_bloc.dart';
import 'package:app/bloc/users/active_users_bloc.dart';
import 'package:app/bloc/users/unread_replys_bloc.dart';
import 'package:app/main.dart';
import 'package:app/ui/route/fade_route.dart';
import 'package:app/ui/route/standard_route.dart';
import 'package:app/ui/screen/abouts/no_available_screen.dart';
import 'package:app/ui/screen/abouts/settings_screen.dart';
import 'package:app/ui/screen/activities/activities_screen.dart';
import 'package:app/ui/screen/activities/conversation/conversation_screen.dart';
import 'package:app/ui/screen/activities/messages/message_detail_screen.dart';
import 'package:app/ui/screen/activities/messages/message_image_screen.dart';
import 'package:app/ui/screen/home_screen.dart';
import 'package:app/ui/screen/post_message_screen.dart';
import 'package:app/ui/screen/send_history_screen.dart';
import 'package:app/ui/screen/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteName {
  static const start = '/start';
  static const home = '/home';
  static const history = '/history';
  static const messageDetail = '/message_detail';
  static const showImage = '/show_image';
  static const userProfile = '/user_profile';
  static const initProfile = '/user_profile/initial';
  static const conversation = '/conversation';
  static const post = '/post';
  static const settings = '/settings';
  static const activities = '/activities';
}

class CustomRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // NoAvailableの場合は基本的にモーダルのみの表示とする
    if (self != null &&
        !self!.available &&
        ![RouteName.start, RouteName.home].contains(settings.name)) {
      return PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => NoAvailableScreen(),
        fullscreenDialog: true,
      );
    }

    switch (settings.name) {
      case RouteName.start:
        return StandardPageRoute(
          builder: (_) => const UserProfileScreen(
            user: null,
            editable: true,
            initial: true,
          ),
        );

      case RouteName.activities:
        return StandardPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              Provider<MessagesScreenBloc>(
                create: (context) => MessagesScreenBloc(),
                dispose: (_, bloc) => bloc.dispose(),
              ),
              Provider<ConversationScreenBloc>(
                create: (context) => ConversationScreenBloc(),
                dispose: (_, bloc) => bloc.dispose(),
              ),
              Provider<UnreadReplysCounterBloc>(
                create: (context) => UnreadReplysCounterBloc(),
                dispose: (_, bloc) => bloc.dispose(),
              ),
            ],
            child: const ActivitiesScreen(),
          ),
        );

      case RouteName.history:
        return MaterialPageRoute(
            builder: (_) => MultiProvider(
                  providers: [
                    Provider<HistoriesScreenBloc>(
                      create: (context) => HistoriesScreenBloc(),
                      dispose: (_, bloc) => bloc.dispose(),
                    ),
                  ],
                  child: const SendHistoryScreen(),
                ),
            fullscreenDialog: true);
      // case RouteName.start:
      //   final TaskDetailScreenArgs args = settings.arguments;
      // return PageRouteBuilder(
      //   opaque: false,
      //   pageBuilder: (BuildContext context, _, __) {
      //     return TaskDetailScreen(args: args);
      //   }
      //   );
      case RouteName.messageDetail:
        final args = settings.arguments as MessageDetailScreenArgument;
        return FadeAnimationRoute<void>(
          builder: (_) => MessageDetailScreen(
            message: args.message,
            type: args.type,
            callback: args.callback,
          ),
          fullscreenDialog: true,
        );

      case RouteName.showImage:
        final args = settings.arguments as MessageImageScreenArgument;
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => MessageImageScreen(
            img: args.img,
            file: args.file,
          ),
          fullscreenDialog: true,
        );

      case RouteName.userProfile:
        final args = settings.arguments as UserProfileScreenArgumanet;
        return FadeAnimationRoute<void>(
          builder: (_) => UserProfileScreen(
            user: args.user,
            editable: args.editable,
          ),
          fullscreenDialog: true,
        );

      case RouteName.initProfile:
        return StandardPageRoute(
          builder: (_) => const UserProfileScreen(
            user: null,
            editable: true,
            initial: true,
          ),
        );

      case RouteName.conversation:
        final args = settings.arguments as ConversationScreenArgument;
        return StandardPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              Provider<ReplyScreenBloc>(
                create: (context) => ReplyScreenBloc(conv: args.conv!),
                dispose: (_, bloc) => bloc.dispose(),
              ),
            ],
            child: ConversationScreen(
              message: args.message,
              user: args.user,
              conv: args.conv,
              callback: args.callback,
            ),
          ),
        );

      case RouteName.post:
        return StandardPageRoute(
          builder: (_) => const PostMessageScreen(),
          fullscreenDialog: true,
        );

      case RouteName.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          fullscreenDialog: true,
        );

      default:
        return FadeAnimationRoute<void>(
            builder: (_) => MultiProvider(
                  providers: [
                    Provider<ActiveUsersBloc>(
                      create: (context) => ActiveUsersBloc(),
                      dispose: (_, bloc) => bloc.dispose(),
                    ),
                    Provider<UnreadReplysBloc>(
                      create: (context) => UnreadReplysBloc(),
                      dispose: (_, bloc) => bloc.dispose(),
                    ),
                    Provider<SelfUserBloc>(
                      create: (context) => SelfUserBloc(),
                      dispose: (_, bloc) => bloc.dispose(),
                    ),
                  ],
                  child: const HomeScreen(),
                ),
            fullscreenDialog: true);
    }
  }
}
