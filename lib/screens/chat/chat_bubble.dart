import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/message_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utiles/date_helper.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final String decryptedText;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.decryptedText,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? AppColors.chatBubbleSent : AppColors.chatBubbleReceived,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == 'file') _buildFileBubble() else _buildTextBubble(),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateHelper.formatChatTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : AppColors.grey500,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: message.isRead ? Colors.lightBlueAccent : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBubble() {
    return Text(
      decryptedText,
      style: TextStyle(
        color: isMe ? Colors.white : AppColors.grey900,
        fontSize: 14,
        height: 1.4,
      ),
    );
  }

  Widget _buildFileBubble() {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(message.fileUrl);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file, size: 18, color: isMe ? Colors.white : AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message.fileName,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.primary,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}