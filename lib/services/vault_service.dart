import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VaultService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'vault_key';
  static const _ivName = 'vault_iv';

  static Future<Directory> getVaultDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final vault = Directory('${dir.path}/vault');
    if (!await vault.exists()) await vault.create(recursive: true);
    return vault;
  }

  static Future<enc.Key> _getKey() async {
    String? keyStr = await _storage.read(key: _keyName);
    if (keyStr == null) {
      final key = enc.Key.fromSecureRandom(32);
      await _storage.write(key: _keyName, value: key.base64);
      return key;
    }
    return enc.Key.fromBase64(keyStr);
  }

  static Future<enc.IV> _getIV() async {
    String? ivStr = await _storage.read(key: _ivName);
    if (ivStr == null) {
      final iv = enc.IV.fromSecureRandom(16);
      await _storage.write(key: _ivName, value: iv.base64);
      return iv;
    }
    return enc.IV.fromBase64(ivStr);
  }

  static Future<void> encryptAndStore(File sourceFile) async {
    final key = await _getKey();
    final iv = await _getIV();
    final encrypter = enc.Encrypter(enc.AES(key));

    final bytes = await sourceFile.readAsBytes();
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);

    final vaultDir = await getVaultDir();
    final fileName = sourceFile.path.split('/').last;
    final destFile = File('${vaultDir.path}/$fileName.enc');
    await destFile.writeAsBytes(encrypted.bytes);
  }

  static Future<Uint8List> decryptFile(File encFile) async {
    final key = await _getKey();
    final iv = await _getIV();
    final encrypter = enc.Encrypter(enc.AES(key));

    final bytes = await encFile.readAsBytes();
    final encrypted = enc.Encrypted(bytes);
    final decrypted = encrypter.decryptBytes(encrypted, iv: iv);
    return Uint8List.fromList(decrypted);
  }
}
