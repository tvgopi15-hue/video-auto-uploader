import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VideoAutoUploaderApp()));
}

class VideoAutoUploaderApp extends StatelessWidget {
  const VideoAutoUploaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Auto Uploader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class VideoItem {
  final String path;
  final String name;
  final int size;
  bool isUploaded;
  double progress;

  VideoItem({
    required this.path,
    required this.name,
    required this.size,
    this.isUploaded = false,
    this.progress = 0.0,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<VideoItem> _videos = [];
  bool _isUploading = false;
  String _statusMessage = 'কোনো ভিডিও সিলেক্ট করা হয়নি';

  Future<void> _pickVideos() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        for (var file in result.files) {
          if (file.path != null) {
            _videos.add(VideoItem(
              path: file.path!,
              name: file.name,
              size: file.size,
            ));
          }
        }
        _statusMessage = '${_videos.length} টি ভিডিও রেডি আছে';
      });
    }
  }

  void _startUpload() async {
    if (_videos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে প্রথমে ভিডিও যোগ করুন')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = 'আপলোড প্রসেস চলছে...';
    });

    for (var video in _videos) {
      if (!video.isUploaded) {
        for (int i = 1; i <= 10; i++) {
          await Future.delayed(const Duration(milliseconds: 300));
          setState(() {
            video.progress = i / 10.0;
          });
        }
        setState(() {
          video.isUploaded = true;
        });
      }
    }

    setState(() {
      _isUploading = false;
      _statusMessage = 'সব ভিডিও সফলভাবে আপলোড সম্পন্ন!';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আপলোড সম্পন্ন হয়েছে!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Auto Uploader', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isUploading ? Icons.cloud_upload : Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _videos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('নিচের বাটনে ক্লিক করে ভিডিও সিলেক্ট করুন', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _videos.length,
                      itemBuilder: (context, index) {
                        final video = _videos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const Icon(Icons.video_file, color: Colors.blue),
                            title: Text(video.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${(video.size / (1024 * 1024)).toStringAsFixed(2)} MB'),
                                if (_isUploading && !video.isUploaded) ...[
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(value: video.progress),
                                ],
                              ],
                            ),
                            trailing: video.isUploaded
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploading ? null : _pickVideos,
                    icon: const Icon(Icons.add),
                    label: const Text('ভিডিও যোগ করুন'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isUploading ? null : _startUpload,
                    icon: const Icon(Icons.upload),
                    label: const Text('আপলোড শুরু'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
