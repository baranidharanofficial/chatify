import 'package:chat/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String userEmail;
  final String userId;
  const ChatScreen({
    super.key,
    required this.userEmail,
    required this.userId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        scrollToBottom();
      });
    });
    super.initState();
  }

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.userId, messageController.text);
      scrollToBottom();
      messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter some message to send'),
        ),
      );
    }
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 24, 31, 35),
        title: Text(
          widget.userEmail,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: _buildMessageList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: messageController,
                    onTap: () {
                      scrollToBottom();
                    },
                    onTapOutside: (pointerEvent) {
                      scrollToBottom();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Message',
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: sendMessage,
                icon: const Icon(
                  Icons.send,
                  size: 24,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
          widget.userId,
          _firebaseAuth.currentUser!.uid,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }

          debugPrint("${snapshot.data!.docs.length}---------");

          return ListView(
              controller: _scrollController,
              children: snapshot.data!.docs
                  .map<Widget>((doc) => _buildMessageItem(doc))
                  .toList());
        });
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    var rowAlignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Container(
      alignment: alignment,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomRight:
                    (data['senderId'] == _firebaseAuth.currentUser!.uid)
                        ? const Radius.circular(0)
                        : const Radius.circular(15),
                bottomLeft: (data['senderId'] == _firebaseAuth.currentUser!.uid)
                    ? const Radius.circular(15)
                    : const Radius.circular(0),
              ),
              color: (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? Colors.blueGrey[900]
                  : Colors.brown[50],
            ),
            child: Column(
              crossAxisAlignment: rowAlignment,
              children: [
                Text(
                  data['senderEmail'],
                  style: TextStyle(
                    color: (data['senderId'] == _firebaseAuth.currentUser!.uid)
                        ? Colors.white
                        : Colors.black,
                    fontSize: 8,
                  ),
                ),
                Text(
                  data['message'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: (data['senderId'] == _firebaseAuth.currentUser!.uid)
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
