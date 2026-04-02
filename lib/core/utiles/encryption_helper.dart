import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  // IMPORTANT: Store this key securely in flutter_secure_storage
  // Never hardcode in production — generate per-match and store encrypted
  static const String _defaultKey = 'PeerBuddy2024SecretKey32CharLong!'; // 32 chars for AES-256

  static String encrypt(String plainText, {String? customKey}) {
    final keyStr = customKey ?? _defaultKey;
    final key = Key.fromUtf8(keyStr.padRight(32).substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    // Prepend IV to encrypted data (needed for decryption)
    return '${iv.base64}:${encrypted.base64}';
  }

  static String decrypt(String encryptedText, {String? customKey}) {
    try {
      final parts = encryptedText.split(':');
      if (parts.length != 2) return '[Unable to decrypt]';
      final keyStr = customKey ?? _defaultKey;
      final key = Key.fromUtf8(keyStr.padRight(32).substring(0, 32));
      final iv = IV.fromBase64(parts[0]);
      final encrypter = Encrypter(AES(key));
      return encrypter.decrypt64(parts[1], iv: iv);
    } catch (e) {
      return '[Message unavailable]';
    }
  }
}