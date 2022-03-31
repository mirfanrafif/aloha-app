import 'package:aloha/components/widgets/chat_item.dart';
import 'package:aloha/data/service/contact_provider.dart';
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

  @override
  void initState() {
    super.initState();
    chatListController.addListener(_loadMore);
  }

  void _loadMore() {
    if (chatListController.position.pixels ==
        chatListController.position.maxScrollExtent) {
      Provider.of<ContactProvider>(context, listen: false)
          .getPastMessages(customerId: widget.customer.id, loadMore: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    chatListController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, child) {
        var messages = provider.getMessageByCustomerId(widget.customer.id);
        if (messages.isNotEmpty) {
          return ListView.builder(
            controller: chatListController,
            itemBuilder: (context, index) {
              return ChatItem(message: messages[index]);
            },
            reverse: true,
            itemCount: messages.length,
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Image(
                  image: AssetImage(
                      'assets\\image\\undraw_Online_messaging_re_qft3.png'),
                  width: 300,
                ),
                Text("Pesan akan tampil disini")
              ],
            ),
          );
        }
      },
    );
  }
}
