
import 'package:app/bloc/reply/conversation_bloc.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/contents/conversation_item_card.dart';
import 'package:app/ui/screen/activities/conversation/conversation_screen.dart';
import 'package:app/ui/utilities/app_list_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllConversationScreen extends StatefulWidget {

  @override
  _AllConversationScreen createState() => _AllConversationScreen();

}

class _AllConversationScreen extends State<AllConversationScreen> {

  ScrollController _scrollController = ScrollController();

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  ListModel<Conversation> _list;
  
  @override
  void initState() {

    List<Conversation> _initial = [];
    _list = ListModel<Conversation>(
      listKey: _listKey,
      initialItems: _initial,
      removedItemBuilder: _buildRemovedItem,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final _bloc = Provider.of<ConversationScreenBloc>(context);
    _bloc.load();
    
    return RefreshIndicator(
      onRefresh: _refresh,
      child: StreamBuilder(
        stream: _bloc.stream,
        initialData: [],
        builder: (_, snapshot) {
          
          if (snapshot.data is List<Conversation>) {
            (snapshot.data as List<Conversation>).forEach((element) {
              // 既に存在している場合はデータの更新のみ行う
              // 存在していない場合はインサート
              var list = _list.where((item){ return (item as Conversation).id == element.id; }).toList();
              if (list.length > 0) {
                _list.update(_list.indexOf(list[0]), element);
              }
              else {
                _insert(element); 
              }
              
            });
          }

          return AnimatedList(
            key: _listKey,
            controller: _scrollController,
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 24, top: 0),
            physics: BouncingScrollPhysics(),
            initialItemCount: _list.length,
            itemBuilder: _buildItem
          );
        },
      )
    );
  }

  Future<void> _refresh() {
    return Future.sync(() {
      
    });
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {

    return ConversationItemCard(
      context: context,
      conv: _list[index],
      animation: animation,
      onTap: () {
        _selectedItem(index);
      },
    );
  }

  Widget _buildRemovedItem(Conversation item, BuildContext context, Animation<double> animation) {
    return ConversationItemCard(
      context: context,
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
      arguments: ConversationScreenArgument(message: null, user: _list[index].to, conv: _list[index])
    );
  }

}