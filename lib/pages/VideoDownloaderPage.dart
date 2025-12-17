import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../services/downloader_service.dart';

class VideoDownloaderPage extends StatefulWidget {
  const VideoDownloaderPage({super.key});

  @override
  State<VideoDownloaderPage> createState() => _VideoDownloaderPageState();
}

class _VideoDownloaderPageState extends State<VideoDownloaderPage> {
  final urlCtrl = TextEditingController();
  final downloader = DownloaderService();

  double progress = 0.0;
  bool isDownloading = false;
  String? savedFilePath;

  VideoPlayerController? _player;
  Timer? _clipboardPoller;
  String _lastClipboard = '';

  @override
  void initState() {
    super.initState();
    _pollClipboardEveryFewSeconds();
  }

  @override
  void dispose() {
    _clipboardPoller?.cancel();
    _player?.dispose();
    urlCtrl.dispose();
    super.dispose();
  }

  void _pollClipboardEveryFewSeconds() {
    _clipboardPoller = Timer.periodic(const Duration(seconds: 4), (_) async {
      try {
        final data = await Clipboard.getData('text/plain');
        final text = data?.text?.trim() ?? '';
        if (text.isNotEmpty && text != _lastClipboard && downloader.looksLikeUrl(text)) {
          _lastClipboard = text;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link detected in clipboard')),
            );
            urlCtrl.text = text;
            setState(() {});
          }
        }
      } catch (_) {}
    });
  }

  Future<void> _download() async {
    FocusScope.of(context).unfocus();
    final url = urlCtrl.text.trim();

    if (!downloader.looksLikeUrl(url)) {
      _toast('Please enter a valid URL');
      return;
    }
    if (!downloader.isDirectMp4(url)) {
      _toast('For MVP, use a direct .mp4 link (e.g., a sample video).');
      return;
    }

    try {
      setState(() {
        isDownloading = true;
        progress = 0.0;
        savedFilePath = null;
      });

      final path = await downloader.downloadFile(
        url: url,
        onProgress: (received, total) {
          if (total > 0) {
            setState(() => progress = received / total);
          }
        },
      );

      setState(() => savedFilePath = path);
      _toast('Saved: ${path.split('/').last}');
      await _playFile(path);
    } catch (e) {
      _toast('Download failed: $e');
    } finally {
      setState(() {
        isDownloading = false;
        progress = 0.0;
      });
    }
  }

  Future<void> _playFile(String path) async {
    try {
      _player?.dispose();
      _player = VideoPlayerController.file(File(path));
      await _player!.initialize();
      setState(() {});
      await _player!.setLooping(true);
      await _player!.play();
    } catch (e) {
      _toast('Player error: $e');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final canDownload = !isDownloading && downloader.looksLikeUrl(urlCtrl.text.trim());

    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color(0xFF4A90A4),
      iconTheme: const IconThemeData(
        color: Colors.white, 
      ),
      elevation: 2,
      title: const Text(
        'Smart Video Downloader',
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    ),
      body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7FB3D3), // Light blue
            Color(0xFFB8E6B8), // Light green
          ],
        ),
      ),
      // color: Color(0xFF7FB3D3),
      // padding: const EdgeInsets.all(20),
      child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // URL Input Section
            _buildSection(
              title: 'Video URL',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paste a direct MP4 link (learning mode)',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: urlCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'https://example.com/sample.mp4',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste),
                        onPressed: () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data?.text != null) {
                            urlCtrl.text = data!.text!.trim();
                            setState(() {});
                          }
                        },
                        tooltip: 'Paste from clipboard',
                      ),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: canDownload ? _download : null,
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 173, 209, 211),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Progress Section
            if (isDownloading)
              _buildSection(
                title: 'Download Progress',
                content: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress == 0 ? null : progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 173, 209, 211),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progress == 0 ? 'Starting...' : '${(progress * 100).toStringAsFixed(0)}% completed',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Success Section
            if (savedFilePath != null)
              _buildSection(
                title: 'Download Complete',
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Saved: ${savedFilePath!.split('/').last}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Video Player Section
            if (_player != null && _player!.value.isInitialized)
              _buildSection(
                title: 'Video Player',
                content: AspectRatio(
                  aspectRatio: _player!.value.aspectRatio,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: VideoPlayer(_player!),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  final playing = _player!.value.isPlaying;
                                  setState(() {
                                    playing ? _player!.pause() : _player!.play();
                                  });
                                },
                                icon: Icon(
                                  _player!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  await _player!.pause();
                                  await _player!.seekTo(Duration.zero);
                                  await _player!.play();
                                },
                                icon: const Icon(
                                  Icons.replay,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 147, 177),
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
}
