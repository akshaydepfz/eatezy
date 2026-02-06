import 'package:eatezy/view/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatViewScreen extends StatefulWidget {
  final String chatId;
  final String vendorId;
  final String orderId;
  final String vendorToken;
  final String customerName;
  final String customerImage;
  const ChatViewScreen(
      {super.key,
      required this.chatId,
      required this.vendorId,
      required this.orderId,
      required this.vendorToken,
      required this.customerName,
      required this.customerImage});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  /// Resolved chat ID - set when we create a new chat (chatId was '')
  String? _resolvedChatId;

  String get _effectiveChatId => _resolvedChatId ?? widget.chatId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await checkChatExist();
    await initializeChat();
  }

  Future<void> checkChatExist() async {
    if (widget.chatId == '') {
      String doc =
          "${FirebaseAuth.instance.currentUser!.uid}${widget.vendorId}";
      final chatRef = FirebaseFirestore.instance.collection('chats').doc(doc);
      final chatSnap = await chatRef.get();

      if (!chatSnap.exists) {
        final timestamp = FieldValue.serverTimestamp();
        await chatRef.set({
          'lastMessage': '',
          'lastMessageTime': timestamp,
          'customer_name': widget.customerName,
          'customer_image': widget.customerImage,
          'participants': [
            widget.vendorId,
            FirebaseAuth.instance.currentUser!.uid,
          ]
        });

        if (widget.orderId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('cart')
              .doc(widget.orderId)
              .update({"chat_id": doc});
        }
      }

      setState(() => _resolvedChatId = doc);
    }
  }

  Future<void> initializeChat() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final chatId = _resolvedChatId ?? widget.chatId;
    if (chatId.isNotEmpty) {
      await chatProvider.markMessagesAsRead(chatId);
    }
    setState(() => isLoading = false);
  }

  void handleSendMessage(ChatProvider provider) async {
    final chatId = _effectiveChatId;
    if (chatId.isEmpty) return;
    await provider.sendMessage(chatId, _controller.text, widget.vendorToken);
    _controller.clear();
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getMessagesStream(
                  _effectiveChatId, widget.vendorId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                // Scroll to bottom when messages are loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderToken'] ==
                        FirebaseAuth.instance.currentUser!.uid;
                    final time = msg['timestamp'] != null
                        ? DateFormat('hh:mm a')
                            .format(msg['timestamp'].toDate())
                        : "";

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.teal.shade300
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['text'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => handleSendMessage(chatProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
