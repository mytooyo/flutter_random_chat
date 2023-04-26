import 'package:app/bloc/messages/messages_bloc.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/activities/messages/message_detail_screen.dart';
import 'package:app/ui/screen/contents/message_item_card.dart';
import 'package:app/ui/utilities/app_list_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  final ScrollController scrollController;

  const MessagesScreen({
    super.key,
    required this.scrollController,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreen();
}

class _MessagesScreen extends State<MessagesScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late ListModel<Message> _list;
  late MessagesScreenBloc _bloc;

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
    _bloc = Provider.of<MessagesScreenBloc>(context);
    _bloc.load();

    // return Container();
    return RefreshIndicator(
      onRefresh: _refresh,
      child: StreamBuilder(
        stream: _bloc.stream,
        initialData: const [],
        builder: (_, snapshot) {
          if (snapshot.data is List<Message>) {
            for (var element in (snapshot.data as List<Message>)) {
              _insert(element);
            }
          }

          return AnimatedList(
              key: _listKey,
              controller: widget.scrollController,
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 24, top: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              initialItemCount: _list.length,
              itemBuilder: _buildItem);
        },
      ),
    );
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return MessageItemCard(
      context: context,
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
    return MessageItemCard(
      context: context,
      message: item,
      animation: animation,
    );
  }

  Future<void> _refresh() async {
    _bloc.load();
  }

  void _selectedItem(int index) {
    Navigator.of(context).pushNamed(
      RouteName.messageDetail,
      arguments: MessageDetailScreenArgument(
        message: _list[index],
        type: MessageDetailType.detail,
        callback: _sentReply,
      ),
    );
  }

  void _sentReply(Message message) {
    _remove(_list.indexOf(message));
  }

  // Insert the "next item" into the list model.
  void _insert(Message item, {int index = 0}) {
    if (_list.indexOf(item) >= 0) return;

    _list.insert(index, item);
  }

  // Remove the selected item from the list model.
  void _remove(int index) {
    _list.removeAt(index);
  }
}
