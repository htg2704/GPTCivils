import 'package:civils_gpt/services/openAi.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/AppConstants.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  ScrollController listScrollController = ScrollController();
  bool _isLoading = false;

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
      _isLoading = true;
    });

    final response = await OpenAi().chat(_messages, question, context);
    setState(() {
      _isLoading = false;
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
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (BuildContext listViewContext, int index) {
                    if (index == _messages.length) {
                      return const LoadingBubble();
                    }
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

class LoadingBubble extends StatefulWidget {
  const LoadingBubble({super.key});

  @override
  _LoadingBubbleState createState() => _LoadingBubbleState();
}

class _LoadingBubbleState extends State<LoadingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 50, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: AppConstants.textBubbleColour,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(8))),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Get current progress of the animation
              int activeIndex = (_controller.value * 3).floor() % 3;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  // Determine the opacity based on the active index
                  Color color = index == activeIndex
                      ? Colors.grey[800]!
                      : Colors.grey[400]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CircleAvatar(radius: 4, backgroundColor: color),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

