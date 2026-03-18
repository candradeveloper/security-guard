import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/vault_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  List<FileSystemEntity> _vaultFiles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _loading = true);
    final dir = await VaultService.getVaultDir();
    final files = dir.listSync().whereType<File>().toList();
    setState(() {
      _vaultFiles = files;
      _loading = false;
    });
  }

  Future<void> _importFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await VaultService.encryptAndStore(file);
      _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ File berhasil dienkripsi dan disimpan!')),
        );
      }
    }
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    await file.delete();
    _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault Terenkripsi'),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: const Color(0xFF7C4DFF),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _importFile,
            tooltip: 'Import file',
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0D0D1A),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF)))
          : _vaultFiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'Vault kosong\nTambah file dengan tombol +',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.3)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vaultFiles.length,
                  itemBuilder: (context, index) {
                    final file = _vaultFiles[index] as File;
                    final name = file.path.split('/').last;
                    final size = file.lengthSync();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161626),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF7C4DFF).withOpacity(0.2),
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C4DFF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.lock, color: Color(0xFF7C4DFF)),
                        ),
                        title: Text(
                          name.replaceAll('.enc', ''),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${(size / 1024).toStringAsFixed(1)} KB • Terenkripsi',
                          style: TextStyle(color: Colors.white.withOpacity(0.4)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Color(0xFFFF3D71)),
                          onPressed: () => _deleteFile(file),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importFile,
        backgroundColor: const Color(0xFF7C4DFF),
        icon: const Icon(Icons.upload_file),
        label: const Text('Import File'),
      ),
    );
  }
}
