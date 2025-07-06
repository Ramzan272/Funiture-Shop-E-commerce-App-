// lib/user_side/admin/chat/admin_chat_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/admin/chats/view_models/admin_chat_viewmodel.dart';
import 'package:get/get.dart';
import '../../components/constants.dart';
import '../../../models/chat_message.dart';

class AdminChatScreen extends StatelessWidget {
  final String conversationId;
  final String userName;

  const AdminChatScreen({
    Key? key,
    required this.conversationId,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    final ScrollController scrollController = ScrollController();

    final AdminChatViewModel viewModel = Get.put(
      AdminChatViewModel(
        conversationId: conversationId,
        userName: userName,
        messageInputController: messageController,
        chatScrollController: scrollController,
      ),
    );

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

    Widget _buildMessageItem(ChatMessage message, ChatMessage? previousMessage) {
      final isFirstInGroup = previousMessage == null ||
          previousMessage.isSentByUser != message.isSentByUser ||
          message.timestamp.difference(previousMessage.timestamp).inMinutes > 2;

      final showAvatar = message.isSentByUser && isFirstInGroup;
      final showName = message.isSentByUser && isFirstInGroup;

      return GestureDetector(
        onLongPress: () => viewModel.replyToMessage(message),
        child: Padding(
          padding: EdgeInsets.only(
            top: isFirstInGroup ? 8.0 : 2.0,
            bottom: 2.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Column(
            crossAxisAlignment: message.isSentByUser
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              if (showName)
                Padding(
                  padding: const EdgeInsets.only(left: 48.0, bottom: 4.0),
                  child: Text(
                    userName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: message.isSentByUser
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showAvatar)
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        // FIX APPLIED HERE: Check if userName is not empty
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    )
                  else if (message.isSentByUser)
                    const SizedBox(width: 32),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: message.isSentByUser
                            ? Colors.grey[200]
                            : kPrimaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.replyToMessageId != null)
                            FutureBuilder<ChatMessage?>(
                              future: viewModel.fetchRepliedMessage(message.replyToMessageId!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox.shrink();
                                }
                                if (!snapshot.hasData || snapshot.data == null) {
                                  return const SizedBox.shrink();
                                }

                                final replyMessage = snapshot.data!;
                                final isReplyFromUser = replyMessage.isSentByUser;

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
                                        isReplyFromUser ? userName : 'You',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        replyMessage.message.length > 50
                                            ? '${replyMessage.message.substring(0, 50)}...'
                                            : replyMessage.message,
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
                  if (!message.isSentByUser) ...[
                    const SizedBox(width: 4),
                    _buildMessageStatus(message.status),
                  ],
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: message.isSentByUser ? 48 : 0,
                  right: message.isSentByUser ? 0 : 8,
                  top: 2,
                ),
                child: Text(
                  viewModel.formatTime(message.timestamp),
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

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
                () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName),
                Text(
                  viewModel.isUserTyping.value ? 'typing...' : 'Customer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Obx(
                  () => Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: kPrimaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Customer Email: ${viewModel.customerEmail.value}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Obx(() {
                if (viewModel.isLoading.value && viewModel.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage.isNotEmpty) {
                  return Center(child: Text(viewModel.errorMessage.value));
                }

                if (viewModel.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation by sending a message',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    final message = viewModel.messages[index];
                    final previousMessage = index > 0 ? viewModel.messages[index - 1] : null;
                    return _buildMessageItem(message, previousMessage);
                  },
                );
              }),
            ),

            Obx(
                  () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: viewModel.replyingTo.value != null
                    ? Container(
                  key: const ValueKey('replyPreview'),
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
                              viewModel.replyingTo.value!.isSentByUser ? userName : 'You',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              viewModel.replyingTo.value!.message.length > 50
                                  ? '${viewModel.replyingTo.value!.message.substring(0, 50)}...'
                                  : viewModel.replyingTo.value!.message,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: viewModel.cancelReply,
                        iconSize: 16,
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink(key: ValueKey('noReplyPreview')),
              ),
            ),

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
                      controller: messageController,
                      onChanged: (_) => viewModel.onMessageInputChanged(),
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
                    onPressed: viewModel.sendMessage,
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
  }
}