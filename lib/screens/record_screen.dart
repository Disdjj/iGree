import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:signature/signature.dart'; 
import 'package:intl/intl.dart'; 
import 'package:record/record.dart'; 
import 'package:permission_handler/permission_handler.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'dart:convert'; // 用于 JSON 编码


class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3, 
    penColor: Colors.black, 
    exportBackgroundColor: Colors.white, 
  );

  late AudioRecorder _audioRecorder; 
  bool _isRecording = false;
  String? _audioPath; 
  String _recordingStatus = "未开始录音";
  String _currentTime = ""; 

  @override
  void initState() {
    super.initState();
    _updateTime();
    _signatureController.addListener(() => print('签名更新'));
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    _currentTime = DateFormat('yyyy年 MM月 dd日 HH:mm', 'zh_CN').format(now); 
    if (mounted) {
      setState(() {});
    }
  }

  void _clearSignature() {
    _signatureController.clear();
  }

  Future<void> _toggleRecording() async {
    final hasPermission = await _requestMicPermission();
    if (!hasPermission) {
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未授予麦克风权限！')), 
      );
      return;
    }

    bool isCurrentlyRecording = false;
    try {
      isCurrentlyRecording = await _audioRecorder.isRecording();
    } catch (e) {
      print("检查录音状态时出错: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('检查录音状态失败: $e')), 
      );
      setState(() {
        _isRecording = false;
        _recordingStatus = "录音检查失败";
      });
      return;
    }

    if (isCurrentlyRecording) {
      try {
        final path = await _audioRecorder.stop(); 
        if (path != null) {
          setState(() {
            _isRecording = false;
            _recordingStatus = "录音结束";
            _audioPath = path; 
            print('录音文件保存在: $_audioPath');
          });
        } else {
          setState(() {
            _isRecording = false;
            _recordingStatus = "停止录音失败";
          });
        }
      } catch (e) {
        print("停止录音时出错: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('停止录音失败: $e')), 
        );
        setState(() {
          _isRecording = false;
          _recordingStatus = "停止录音失败";
        });
      }
    } else {
      try {
        final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
        final String filePath = '${appDocumentsDir.path}/igreen_record_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig(encoder: AudioEncoder.aacLc);

        await _audioRecorder.start(config, path: filePath);

        setState(() {
          _isRecording = true;
          _recordingStatus = "正在录音...";
          _audioPath = null; 
          print('开始录音...');
        });
      } catch (e) {
        print('录音失败: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('录音启动失败: $e')), 
        );
        setState(() {
          _isRecording = false;
          _recordingStatus = "录音失败";
        });
      }
    }
  }

  Future<bool> _requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  Future<void> _saveRecord() async { 
    // 1. 检查签名和录音
    if (_signatureController.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先签名！')), 
      );
      return;
    }
    if (_audioPath == null || _audioPath!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先完成录音！')), 
      );
      return;
    }

    // 2. 导出签名
    final signatureData = await _signatureController.toPngBytes();
    if (signatureData == null) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('无法导出签名！')), 
       );
       return;
    }

    // 3. 显示加载指示器 (可选)
    if (mounted) {
       showDialog(
         context: context,
         barrierDismissible: false, // 防止用户点击外部关闭
         builder: (BuildContext context) {
           return const Dialog(
             child: Padding(
               padding: EdgeInsets.all(20.0),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   CircularProgressIndicator(),
                   SizedBox(width: 20),
                   Text("正在保存记录..."),
                 ],
               ), 
             ),
           );
         },
       );
    }


    try {
      // 4. 获取存储路径
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final String recordsBasePath = '${appDocumentsDir.path}/igreen_records';
      final String recordFolderName = DateTime.now().millisecondsSinceEpoch.toString(); // 使用时间戳作为文件夹名
      final String recordPath = '$recordsBasePath/$recordFolderName';

      // 创建记录文件夹 (如果不存在)
      final Directory recordDir = Directory(recordPath);
      if (!await recordDir.exists()) {
        await recordDir.create(recursive: true); // recursive: true 会创建父目录
      }

      // 5. 定义文件路径
      final String signatureFilePath = '$recordPath/signature.png';
      final String audioFilePath = '$recordPath/recording.m4a';
      final String metadataFilePath = '$recordPath/metadata.json';

      // 6. 保存签名文件
      final File signatureFile = File(signatureFilePath);
      await signatureFile.writeAsBytes(signatureData);
      print('签名已保存至: $signatureFilePath');

      // 7. 复制录音文件
      final File audioOriginFile = File(_audioPath!); 
      await audioOriginFile.copy(audioFilePath);
      print('录音已复制至: $audioFilePath');
      // (可选) 复制后可以删除原始临时录音文件
      // await audioOriginFile.delete();

      // 8. 创建并保存元数据文件
      final Map<String, dynamic> metadata = {
        'recordTime': _currentTime, // 保存格式化后的时间字符串
        'timestamp': DateTime.now().toIso8601String(), // 保存 ISO 格式时间戳
        'signatureFile': 'signature.png',
        'audioFile': 'recording.m4a',
        // 可以添加其他需要记录的信息，例如设备信息等
      };
      final String metadataJson = jsonEncode(metadata); // 编码为 JSON 字符串
      final File metadataFile = File(metadataFilePath);
      await metadataFile.writeAsString(metadataJson);
      print('元数据已保存至: $metadataFilePath');

      // 9. 关闭加载指示器并显示成功消息
      if (mounted) Navigator.pop(context); // 关闭 Dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('记录已成功保存至: $recordFolderName')), 
        );
      }

      // 10. (可选) 清理当前界面状态并返回
       _clearSignature();
       setState(() {
         _audioPath = null;
         _recordingStatus = "未开始录音";
         _isRecording = false;
         _updateTime(); // 更新时间以便下次记录
       });
       if (mounted) Navigator.pop(context); // 返回 HomeScreen


    } catch (e) {
      print('保存记录时出错: $e');
       // 关闭加载指示器并显示错误消息
      if (mounted) Navigator.pop(context); // 关闭 Dialog
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('保存失败: $e')), 
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建同意记录'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: '保存记录',
            onPressed: _isRecording ? null : _saveRecord, 
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '请口述：“我同意进行本次性行为，时间是 $_currentTime”',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? '停止录音' : '开始录音'),
                  onPressed: _toggleRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.redAccent : Theme.of(context).colorScheme.primary, 
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Text(_recordingStatus), 
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('请在此处签名:', style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('清除'),
                  onPressed: _isRecording ? null : _clearSignature, 
                ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.grey[200],
              ),
              child: IgnorePointer( 
                ignoring: _isRecording,
                child: Signature(
                  controller: _signatureController,
                  height: 250, 
                  backgroundColor: Colors.grey[200]!, 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
