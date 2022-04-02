import 'package:aloha/components/widgets/chat_item.dart';
import 'package:aloha/data/providers/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/response/Contact.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key, required this.customer}) : super(key: key);
  final Customer customer;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  var chatListController = ScrollController();
  late MessageProvider provider;

  @override
  void initState() {
    super.initState();
    chatListController.addListener(_loadMore);
    provider = Provider.of<MessageProvider>(context, listen: false);
    if (provider.getIsFirstLoad(widget.customer.id)) {
      print("first load");
      provider.setFirstLoadDone(widget.customer.id);
      provider.getPastMessages(customerId: widget.customer.id);
    }
  }

  void _loadMore() {
    if (chatListController.position.pixels ==
        chatListController.position.maxScrollExtent) {
      provider.getPastMessages(customerId: widget.customer.id, loadMore: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    chatListController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, provider, child) {
        var messages = provider.getMessageByCustomerId(widget.customer.id);
        if (messages.isNotEmpty) {
          return Column(
            children: [
              if (provider.loading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: chatListController,
                  itemBuilder: (context, index) {
                    return ChatItem(message: messages[index]);
                  },
                  reverse: true,
                  itemCount: messages.length,
                ),
              ),
            ],
          );
        } else {
          return const EmptyChat();
        }
      },
    );
  }
}

class EmptyChat extends StatelessWidget {
  const EmptyChat({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Image(
            image: AssetImage('assets\\image\\empty_message_bg.png'),
            width: 300,
          ),
          Text("Pesan akan tampil disini")
        ],
      ),
    );
  }
}
