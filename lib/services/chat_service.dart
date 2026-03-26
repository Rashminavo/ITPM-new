import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../core/utiles/encryption_helper.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Send a text message (encrypted)
  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String plainText,
  }) async {
    final messageId = _uuid.v4();
    final encrypted = EncryptionHelper.encrypt(plainText);

    final message = MessageModel(
      messageId: messageId,
      senderId: senderId,
      encryptedContent: encrypted,
      type: 'text',
      timestamp: DateTime.now(),
      isRead: false,
    );

    await _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    // Update lastMessageAt on match doc
    await _firestore.collection('matches').doc(matchId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  // Send a file message (image or document)
  Future<void> sendFileMessage({
    required String matchId,
    required String senderId,
    required String fileUrl,
    required String fileName,
  }) async {
    final messageId = _uuid.v4();

    // Determine type based on file extension
    final ext = fileName.split('.').last.toLowerCase();
    final type = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)
        ? 'image'
        : 'file';

    final message = MessageModel(
      messageId: messageId,
      senderId: senderId,
      encryptedContent: fileUrl, // file URLs are stored as-is (not encrypted)
      type: type,
      fileUrl: fileUrl,
      fileName: fileName,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    // Update lastMessageAt on match doc
    await _firestore.collection('matches').doc(matchId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream all messages for a chat in ascending order
  Stream<List<MessageModel>> getMessages(String matchId) {
    return _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MessageModel.fromMap(d.data())).toList());
  }

  // Get the last message of a chat (for preview in buddy list)
  Future<MessageModel?> getLastMessage(String matchId) async {
    final snap = await _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return MessageModel.fromMap(snap.docs.first.data());
  }

  // Mark all unread messages from the other user as read
  Future<void> markAsRead(String matchId, String currentUserId) async {
    final unread = await _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    if (unread.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Get unread message count for a specific chat
  Future<int> getUnreadCount(String matchId, String currentUserId) async {
    final snap = await _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();
    return snap.docs.length;
  }

  // Stream unread count (live badge update)
  Stream<int> getUnreadCountStream(String matchId, String currentUserId) {
    return _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // Delete a single message (soft delete — sets content to deleted)
  Future<void> deleteMessage(String matchId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .doc(messageId)
        .update({
      'encryptedContent': '[Message deleted]',
      'type': 'deleted',
      'fileUrl': '',
      'fileName': '',
    });
  }

  // Delete all messages in a chat (when match is ended)
  Future<void> deleteAllMessages(String matchId) async {
    final snap = await _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}