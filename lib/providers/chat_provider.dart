import 'package:flutter/material.dart';
import 'dart:io';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final StorageService _storageService = StorageService();

  bool _isSending = false;
  String? _error;

  bool get isSending => _isSending;
  String? get error => _error;

  Stream<List<MessageModel>> getMessages(String matchId) {
    return _chatService.getMessages(matchId);
  }

  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String plainText,
  }) async {
    _isSending = true;
    notifyListeners();
    try {
      await _chatService.sendMessage(
        matchId: matchId,
        senderId: senderId,
        plainText: plainText,
      );
      _error = null;
    } catch (e) {
      _error = 'Failed to send message.';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> sendFile({
    required String matchId,
    required String senderId,
    required File file,
    required String fileName,
  }) async {
    _isSending = true;
    notifyListeners();
    try {
      final result = await _storageService.uploadChatFile(
        matchId: matchId,
        file: file,
        fileName: fileName,
      );
      await _chatService.sendFileMessage(
        matchId: matchId,
        senderId: senderId,
        fileUrl: result['url']!,
        fileName: result['name']!,
      );
      _error = null;
    } catch (e) {
      _error = 'Failed to send file.';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String matchId, String currentUserId) async {
    await _chatService.markAsRead(matchId, currentUserId);
  }
}