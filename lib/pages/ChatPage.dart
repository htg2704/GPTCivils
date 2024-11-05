import 'package:civils_gpt/services/openAi.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/AppConstants.dart';
import '../providers/ConstantsProvider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  ScrollController listScrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    if (listScrollController.hasClients) {
      final position = listScrollController.position.maxScrollExtent;
      listScrollController.jumpTo(position);
    }
    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': question});
    });
    print(_messages);
    final response = await OpenAi().chat(_messages, question, context);
    print(response);
    setState(() {
        _messages.add({'role': 'assistant', 'content': response});
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (listScrollController.hasClients) {
        final position = listScrollController.position.maxScrollExtent;
        listScrollController.jumpTo(position);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColour,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(FontAwesomeIcons.arrowLeft, size: 24)),
          title: const Text(
            'Ask CivilsGPT',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: ListView.builder(
                  controller: listScrollController,
                  itemCount: _messages.length,
                  itemBuilder: (BuildContext listViewContext, int index) {
                    final message = _messages[index];
                    return ChatBubble(message: message);
                  })),
          Container(
            width: MediaQuery.of(context).size.width,
            color: AppConstants.surfaceContainerColor,
            constraints: const BoxConstraints(minHeight: 88),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: SearchBar(
                  keyboardType: TextInputType.multiline,
                  hintText: "Search for any service",
                  backgroundColor:
                      WidgetStatePropertyAll(AppConstants.inputFieldColour),
                  elevation: const WidgetStatePropertyAll(0),
                  controller: _controller,
                  trailing: [
                    IconButton(
                        onPressed: _sendMessage,
                        icon: Icon(
                          FontAwesomeIcons.arrowUp,
                          size: 20,
                          color: AppConstants.upIconColor,
                        ))
                  ]),
            ),
          )
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Map<String, String> message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message['role'] == 'user'
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Column(
          crossAxisAlignment: message['role'] != 'user'
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(message['role'] == 'user' ? 50 : 20,
                  6, message['role'] != 'user' ? 50 : 20, 12),
              child: Text(
                message['role']! == 'user' ? "You" : "CivilsGPT",
                style: TextStyle(color: AppConstants.upIconColor),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(message['role'] == 'user' ? 50 : 20,
                  6, message['role'] != 'user' ? 50 : 20, 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                    color: AppConstants.textBubbleColour,
                    borderRadius: message['role'] == 'user'
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(20))
                        : const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(8))),
                child: Text(
                  message['content']!,
                  style: TextStyle(color: AppConstants.upIconColor),
                ),
              ),
            )
          ]),
    );
  }
}
