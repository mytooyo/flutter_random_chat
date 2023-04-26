import 'package:app/bloc/reply/conversation_bloc.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/activities/conversation/conversation_screen.dart';
import 'package:app/ui/screen/contents/conversation_item_card.dart';
import 'package:app/ui/utilities/app_list_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllConversationScreen extends StatefulWidget {
  const AllConversationScreen({super.key});

  @override
  State<AllConversationScreen> createState() => _AllConversationScreen();
}

class _AllConversationScreen extends State<AllConversationScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late ListModel<Conversation> _list;

  @override
  void initState() {
    List<Conversation> initial = [];
    _list = ListModel<Conversation>(
      listKey: _listKey,
      initialItems: initial,
      removedItemBuilder: _buildRemovedItem,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<ConversationScreenBloc>(context);
    bloc.load();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: StreamBuilder(
        stream: bloc.stream,
        initialData: const [],
        builder: (_, snapshot) {
          if (snapshot.data is List<Conversation>) {
            for (var element in (snapshot.data as List<Conversation>)) {
              // 既に存在している場合はデータの更新のみ行う
              // 存在していない場合はインサート
              var list = _list.where((_) => true).toList();
              if (list.isNotEmpty) {
                _list.update(_list.indexOf(list[0]), element);
              } else {
                _insert(element);
              }
            }
          }

          return AnimatedList(
              key: _listKey,
              controller: _scrollController,
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 24, top: 0),
              physics: const BouncingScrollPhysics(),
              initialItemCount: _list.length,
              itemBuilder: _buildItem);
        },
      ),
    );
  }

  Future<void> _refresh() {
    return Future.sync(() {});
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return ConversationItemCard(
      conv: _list[index],
      animation: animation,
      onTap: () {
        _selectedItem(index);
      },
    );
  }

  Widget _buildRemovedItem(
      Conversation item, BuildContext context, Animation<double> animation) {
    return ConversationItemCard(
      conv: item,
      animation: animation,
    );
  }

  void _insert(Conversation item) {
    if (_list.indexOf(item) >= 0) return;
    _list.insert(0, item);
  }

  void _selectedItem(int index) {
    Navigator.of(context).pushNamed(
      RouteName.conversation,
      arguments: ConversationScreenArgument(
        message: null,
        user: _list[index].to,
        conv: _list[index],
      ),
    );
  }
}
