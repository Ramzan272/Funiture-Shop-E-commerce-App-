import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/user_side/view_models/chat_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../components/constants.dart';
import '../../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // This will hold the ChatViewModel instance
  late ChatViewModel _chatViewModel;

  @override
  void initState() {
    super.initState();
    _checkUserAndInitializeViewModel();
  }

  Future<void> _checkUserAndInitializeViewModel() async {
    final user = _auth.currentUser;
    if (user == null) {
      // If user is not logged in, show error and navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to chat')),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return;
    }
    // Initialize the ViewModel with the current user
    _chatViewModel = ChatViewModel(user);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // --- UI Utility Functions (remain in UI) ---
  Widget _buildMessageStatus(MessageStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
    }
    return Icon(icon, size: 16, color: color);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return 'Today ${DateFormat('HH:mm').format(time)}';
    } else if (messageDate == yesterday) {
      return 'Yesterday ${DateFormat('HH:mm').format(time)}';
    } else {
      return '${DateFormat('dd/MM/yyyy').format(time)} ${DateFormat('HH:mm').format(time)}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // The ViewModel also needs to be disposed if not managed by Provider automatically
    // Provider takes care of disposing if `create` method is used.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only proceed if _chatViewModel has been initialized.
    // This handles the initial null state while _checkUserAndInitializeViewModel runs.
    if (_auth.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: kPrimaryColor),
        ),
      );
    }

    return ChangeNotifierProvider<ChatViewModel>.value(
      value: _chatViewModel,
      child: Consumer<ChatViewModel>(
        builder: (context, chatViewModel, child) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Customer Support'),
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                actions: [
                  StreamBuilder<dynamic>( // Use dynamic as snapshot data type is generic
                    stream: chatViewModel.conversationStatusStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();

                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      final isAdminTyping = data?['isAdminTyping'] == true;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: isAdminTyping
                            ? const Chip(
                          label: Text('Admin is typing...', style: TextStyle(fontSize: 12)),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(color: kPrimaryColor),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )
                            : const SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
              body: chatViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : Column(
                children: [
                  // Messages List
                  Expanded(
                    child: chatViewModel.conversationId == null
                        ? const Center(child: Text('Please wait, initializing chat...'))
                        : StreamBuilder<dynamic>( // Use dynamic for QuerySnapshot
                      stream: chatViewModel.messagesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start the conversation by sending a message',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // Only scroll if near the bottom or it's the first load
                          if (_scrollController.hasClients &&
                              (_scrollController.position.maxScrollExtent - _scrollController.offset < 50 ||
                                  _scrollController.position.pixels == 0)) {
                            _scrollToBottom();
                          }
                        });

                        final messages = docs.map((doc) {
                          return ChatMessage.fromMap(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          );
                        }).toList();

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final previousMessage = index > 0 ? messages[index - 1] : null;
                            return _buildMessageItem(message, previousMessage, chatViewModel);
                          },
                        );
                      },
                    ),
                  ),

                  // Reply Preview
                  if (chatViewModel.replyingTo != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.grey[200],
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 40,
                            color: kPrimaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  chatViewModel.replyingTo!.isSentByUser ? 'You' : 'Admin',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  chatViewModel.replyingTo!.message.length > 50
                                      ? '${chatViewModel.replyingTo!.message.substring(0, 50)}...'
                                      : chatViewModel.replyingTo!.message,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: chatViewModel.cancelReply,
                            iconSize: 16,
                          ),
                        ],
                      ),
                    ),

                  // Message Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            onChanged: (_) => chatViewModel.onUserTyping(),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          onPressed: () {
                            chatViewModel.sendMessage(_messageController.text).then((_) {
                              _messageController.clear(); // Clear text field on success
                              _scrollToBottom();
                            }).catchError((e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error sending message: $e')),
                              );
                            });
                          },
                          backgroundColor: kPrimaryColor,
                          elevation: 0,
                          mini: true,
                          child: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, ChatMessage? previousMessage, ChatViewModel chatViewModel) {
    final isFirstInGroup = previousMessage == null ||
        previousMessage.isSentByUser != message.isSentByUser ||
        message.timestamp.difference(previousMessage.timestamp).inMinutes > 2;

    final showAvatar = !message.isSentByUser && isFirstInGroup;
    final showName = !message.isSentByUser && isFirstInGroup;

    return GestureDetector(
      onLongPress: () {
        chatViewModel.setReplyingTo(message);
        // Optional: Request focus to the text field when replying
        FocusScope.of(context).requestFocus(FocusNode());
        // For some reason, setting focus sometimes needs a small delay or a re-request
        Future.delayed(const Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(FocusNode());
        });
      },
      child: Padding(
        padding: EdgeInsets.only(
          top: isFirstInGroup ? 8.0 : 2.0,
          bottom: 2.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Column(
          crossAxisAlignment: message.isSentByUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (showName)
              Padding(
                padding: const EdgeInsets.only(left: 48.0, bottom: 4.0),
                child: Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: message.isSentByUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showAvatar)
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: kPrimaryColor,
                    child: const Icon(Icons.support_agent, color: Colors.white, size: 20),
                  )
                else if (!message.isSentByUser)
                  const SizedBox(width: 32),

                const SizedBox(width: 8),

                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: message.isSentByUser
                          ? Colors.lightBlue[100] // Light blue for user messages
                          : Colors.grey[200], // Grey for admin messages
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.replyToMessageId != null)
                          FutureBuilder<dynamic>( // Use dynamic for DocumentSnapshot
                            future: message.replyToMessageId != null && chatViewModel.conversationId != null
                                ? chatViewModel.messagesStream.firstWhere((snapshot) =>
                                snapshot.docs.any((doc) => doc.id == message.replyToMessageId)
                            ).then((snapshot) =>
                                snapshot.docs.firstWhere((doc) => doc.id == message.replyToMessageId)
                            )
                                : Future.value(null), // Provide a null Future if conditions are not met
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null) {
                                return const SizedBox.shrink();
                              }

                              final replyData = snapshot.data!.data() as Map<String, dynamic>?;
                              if (replyData == null) return const SizedBox.shrink();

                              final replyMessage = replyData['message'] as String? ?? '';
                              final isReplyFromUser = replyData['isSentByUser'] as bool? ?? false;

                              return Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isReplyFromUser ? 'You' : 'Admin',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      replyMessage.length > 50
                                          ? '${replyMessage.substring(0, 50)}...'
                                          : replyMessage,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        Text(message.message),
                      ],
                    ),
                  ),
                ),

                if (message.isSentByUser) ...[
                  const SizedBox(width: 4),
                  _buildMessageStatus(message.status),
                ],
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                left: message.isSentByUser ? 0 : 48,
                right: message.isSentByUser ? 8 : 0,
                top: 2,
              ),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}