// lib/screens/history_screen.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// 用于存储单个记录信息的简单类
class RecordInfo {
  final String id; // 文件夹名 (时间戳)
  final String recordTime; // 从 metadata.json 读取的时间
  final String directoryPath; // 记录文件夹的完整路径

  RecordInfo({required this.id, required this.recordTime, required this.directoryPath});
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RecordInfo> _records = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // 重置错误信息
    });
    try {
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final String recordsBasePath = '${appDocumentsDir.path}/igreen_records';
      final Directory recordsDir = Directory(recordsBasePath);

      if (!await recordsDir.exists()) {
        // 如果记录目录不存在，说明没有记录
        setState(() {
          _records = [];
          _isLoading = false;
        });
        return;
      }

      final List<FileSystemEntity> entities = recordsDir.listSync();
      final List<RecordInfo> loadedRecords = [];

      for (var entity in entities) {
        // 确保是目录，并且目录名是纯数字 (时间戳)
        if (entity is Directory && int.tryParse(entity.path.split(Platform.pathSeparator).last) != null) {
          final metadataPath = '${entity.path}/metadata.json';
          final metadataFile = File(metadataPath);

          if (await metadataFile.exists()) {
            try {
              final String content = await metadataFile.readAsString();
              final Map<String, dynamic> metadata = jsonDecode(content);
              final String recordId = entity.path.split(Platform.pathSeparator).last;

              // 确保 'recordTime' 存在于元数据中
              if (metadata.containsKey('recordTime')) {
                 loadedRecords.add(RecordInfo(
                   id: recordId,
                   recordTime: metadata['recordTime'] as String, // 从元数据获取时间
                   directoryPath: entity.path, // 保存目录路径供后续使用
                 ));
              } else {
                 print("警告: ${entity.path} 中的 metadata.json 缺少 'recordTime' 字段");
              }
            } catch (e) {
              // 处理单个文件读取或 JSON 解析错误
              print("无法加载记录 ${entity.path}: $e");
              // 可以选择跳过这个记录或显示错误
            }
          } else {
             print("警告: ${entity.path} 中缺少 metadata.json 文件");
          }
        }
      }

       // 按时间戳（文件夹名）降序排序，最新的在前面
       loadedRecords.sort((a, b) => b.id.compareTo(a.id));


      setState(() {
        _records = loadedRecords;
        _isLoading = false;
      });
    } catch (e) {
      // 处理读取目录列表等一般性错误
      print("加载记录失败: $e");
      setState(() {
        _errorMessage = "加载记录失败: $e";
        _isLoading = false;
      });
    }
  }

  // TODO: 添加查看记录详情的功能
  void _viewRecordDetail(RecordInfo record) {
     // 在这里可以导航到新的详情页面，传入 record.directoryPath
     print("查看记录详情: ${record.directoryPath}");
     // 例如: Navigator.push(context, MaterialPageRoute(builder: (context) => RecordDetailScreen(recordPath: record.directoryPath)));
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('将在后续实现查看 ${record.recordTime} 的详情')),
     );
  }


  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('错误: $_errorMessage', style: const TextStyle(color: Colors.red)),
        ),
      );
    } else if (_records.isEmpty) {
      bodyContent = const Center(child: Text('没有找到任何历史记录。'));
    } else {
      bodyContent = ListView.builder(
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return ListTile(
            leading: const Icon(Icons.history), // 使用历史图标
            title: Text('记录时间: ${record.recordTime}'),
            subtitle: Text('ID: ${record.id}'), // 显示文件夹名作为 ID
            trailing: const Icon(Icons.chevron_right), // 右侧箭头
            onTap: () => _viewRecordDetail(record), // 点击查看详情
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: bodyContent,
      // 可以添加一个刷新按钮
      floatingActionButton: FloatingActionButton(
         onPressed: _loadRecords, // 重新加载记录
         tooltip: '刷新',
         child: const Icon(Icons.refresh),
       ),
    );
  }
}
