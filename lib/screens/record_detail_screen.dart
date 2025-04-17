// lib/screens/record_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // 导入 just_audio

class RecordDetailScreen extends StatefulWidget {
  final String recordPath; // 接收记录文件夹的路径

  const RecordDetailScreen({super.key, required this.recordPath});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration? _duration;
  Duration? _position;

  String get signaturePath => '${widget.recordPath}/signature.png';
  String get audioPath => '${widget.recordPath}/recording.m4a';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();

    // 监听播放状态
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (mounted) { // 检查 widget 是否还在树中
        setState(() {
          _isPlaying = isPlaying;
        });
      }
      if (processingState == ProcessingState.completed && isPlaying) {
        // 播放完成后回到开头并暂停
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });

    // 监听音频时长
    _audioPlayer.durationStream.listen((duration) {
       if (mounted) {
         setState(() => _duration = duration);
       }
    });

    // 监听播放进度
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
  }

  Future<void> _initAudioPlayer() async {
    try {
      // 设置音频源
      await _audioPlayer.setFilePath(audioPath);
    } catch (e) {
      print("Error loading audio source: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载音频失败: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // 释放播放器资源
    super.dispose();
  }

  // 格式化时间 M:SS
  String _formatDuration(Duration? d) {
    if (d == null) return '--:--';
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }


  @override
  Widget build(BuildContext context) {
    final signatureFile = File(signaturePath);
    final audioFileExists = File(audioPath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('记录详情'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView( // 使用 SingleChildScrollView 防止内容溢出
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('签名:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // 显示签名图片，处理文件不存在的情况
            signatureFile.existsSync()
                ? Center( // 居中显示图片
                    child: Image.file(
                      signatureFile,
                      errorBuilder: (context, error, stackTrace) => const Text('无法加载签名图片'),
                     )
                   )
                : const Text('未找到签名文件。'),
            const SizedBox(height: 30),
            const Text('录音:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // 音频播放控件
            if (audioFileExists)
              Card( // 使用 Card 美化外观
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 播放/暂停按钮
                          IconButton(
                            icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                            iconSize: 50.0,
                            onPressed: () {
                              if (_isPlaying) {
                                _audioPlayer.pause();
                              } else {
                                _audioPlayer.play();
                              }
                            },
                          ),
                           // 停止按钮 (可选，回到开头并暂停)
                           IconButton(
                             icon: const Icon(Icons.stop_circle_outlined),
                             iconSize: 50.0,
                             onPressed: () {
                               _audioPlayer.stop(); // stop 会触发 completed 状态
                               _audioPlayer.seek(Duration.zero);
                             },
                           ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // 进度条和时间显示
                      Row(
                         children: [
                           Text(_formatDuration(_position)),
                           Expanded(
                             child: Slider(
                                value: (_position?.inMilliseconds ?? 0).toDouble().clamp(0.0, (_duration?.inMilliseconds ?? 1).toDouble()),
                                min: 0.0,
                                max: (_duration?.inMilliseconds ?? 1).toDouble(), // 防止 max 为 0
                                onChanged: (value) {
                                  _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                                },
                                activeColor: Theme.of(context).colorScheme.primary,
                              ),
                           ),
                           Text(_formatDuration(_duration)),
                         ],
                       ),
                    ],
                  ),
                ),
              )
            else
              const Text('未找到录音文件。'),
          ],
        ),
      ),
    );
  }
}
