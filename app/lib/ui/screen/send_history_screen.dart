import 'package:app/bloc/messages/histories_bloc.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/activities/messages/message_detail_screen.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:app/ui/utilities/app_background.dart';
import 'package:app/ui/utilities/app_list_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'contents/history_item_card.dart';

class SendHistoryScreen extends StatefulWidget {
  const SendHistoryScreen({super.key});

  @override
  State<SendHistoryScreen> createState() => _SendHistoryScreen();
}

class _SendHistoryScreen extends State<SendHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late ListModel<Message> _list;

  @override
  void initState() {
    List<Message> initial = [];
    _list = ListModel<Message>(
      listKey: _listKey,
      initialItems: initial,
      removedItemBuilder: _buildRemovedItem,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<HistoriesScreenBloc>(context);
    bloc.load();

    return Stack(
      children: <Widget>[
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        const AppBackgroundPattern(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.history,
                    size: 24,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: Text(
                      'Send History',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.merge(AppTheme.bold),
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            leading: null,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.close,
                ),
                color: AppTheme.primaryLight,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            iconTheme: IconThemeData(
              color: Theme.of(context).dividerColor,
            ),
            elevation: 0.0,
          ),
          body: SafeArea(
              child: RefreshIndicator(
            onRefresh: _refresh,
            child: StreamBuilder(
              stream: bloc.stream,
              initialData: const [],
              builder: (_, snapshot) {
                if (snapshot.data is List<Message>) {
                  for (var element in (snapshot.data as List<Message>)) {
                    _insert(element);
                  }
                }

                return AnimatedList(
                  key: _listKey,
                  controller: _scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 24, top: 16),
                  physics: const BouncingScrollPhysics(),
                  initialItemCount: _list.length,
                  itemBuilder: _buildItem,
                );
              },
            ),
          )),
        )
      ],
    );
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return HistoryItemCard(
      message: _list[index],
      animation: animation,
      onTap: () {
        _selectedItem(index);
      },
    );
  }

  // Used to build an item after it has been removed from the list. This
  // method is needed because a removed item remains visible until its
  // animation has completed (even though it's gone as far this ListModel is
  // concerned). The widget will be used by the
  // [AnimatedListState.removeItem] method's
  // [AnimatedListRemovedItemBuilder] parameter.
  Widget _buildRemovedItem(
      Message item, BuildContext context, Animation<double> animation) {
    return HistoryItemCard(
      message: item,
      animation: animation,
    );
  }

  Future<void> _refresh() {
    return Future.sync(() {});
  }

  void _selectedItem(int index) {
    Navigator.of(context).pushNamed(RouteName.messageDetail,
        arguments: MessageDetailScreenArgument(
            message: _list[index],
            type: MessageDetailType.history,
            callback: (_) {}));
  }

  // Insert the "next item" into the list model.
  void _insert(Message item) {
    if (_list.indexOf(item) >= 0) return;
    _list.insert(0, item);
  }
}
