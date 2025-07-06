// lib/user_side/admin/chat/admin_chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/admin/chats/view_models/admin_chat_list_viewmodel.dart';
import 'package:get/get.dart';
import '../../components/constants.dart';
import 'admin_chat_screen.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminChatListViewModel viewModel = Get.put(AdminChatListViewModel());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Conversations'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage.isNotEmpty) {
          return Center(child: Text(viewModel.errorMessage.value));
        }

        if (viewModel.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: viewModel.conversations.length,
          itemBuilder: (context, index) {
            final conversation = viewModel.conversations[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: conversation.hasUnreadMessages ? kPrimaryColor : Colors.grey,
                child: conversation.userPhotoUrl != null && conversation.userPhotoUrl!.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    conversation.userPhotoUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image fails to load (e.g., corrupted URL)
                      // Ensure userName is not empty before accessing [0]
                      return Text(
                        conversation.userName.isNotEmpty
                            ? conversation.userName[0].toUpperCase()
                            : '?', // Use a fallback like '?' or 'U' if userName is empty
                      );
                    },
                  ),
                )
                    : Text(
                  // Fallback for no photo: Ensure userName is not empty before accessing [0]
                  conversation.userName.isNotEmpty
                      ? conversation.userName[0].toUpperCase()
                      : '?', // Use a fallback like '?' or 'U' if userName is empty
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      conversation.userName,
                      style: TextStyle(
                        fontWeight: conversation.hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    viewModel.formatTime(conversation.lastMessageTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      conversation.lastMessage.isEmpty
                          ? 'No messages yet'
                          : conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: conversation.hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (conversation.hasUnreadMessages)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        conversation.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                Get.to(() => AdminChatScreen(
                  conversationId: conversation.id,
                  userName: conversation.userName,
                ));
              },
            );
          },
        );
      }),
    );
  }
}