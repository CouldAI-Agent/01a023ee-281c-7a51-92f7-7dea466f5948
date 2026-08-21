import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.insert(
        0,
        Message(
          id: DateTime.now().toString(),
          text: text,
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    // Simulate an auto-reply from a bot
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.insert(
            0,
            Message(
              id: DateTime.now().toString(),
              text: 'I am a friendly bot! You just said: "$text"',
              isMe: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true, // Newest messages at the bottom
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
            _buildTextComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final theme = Theme.of(context);
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 20),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type a message...',
              ),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded),
              color: theme.colorScheme.onPrimaryContainer,
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}
