class MessageModel {
  final String messageId;
  final String senderId;
  final String encryptedContent;
  final String type; // "text", "file", "image"
  final String fileUrl;
  final String fileName;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.encryptedContent,
    required this.type,
    this.fileUrl = '',
    this.fileName = '',
    required this.timestamp,
    required this.isRead,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      encryptedContent: map['encryptedContent'] ?? '',
      type: map['type'] ?? 'text',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      timestamp: (map['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'encryptedContent': encryptedContent,
      'type': type,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}