import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BumonCreationScreen extends StatefulWidget {
  const BumonCreationScreen({super.key});

  @override
  _BumonCreationScreenState createState() => _BumonCreationScreenState();
}

class _BumonCreationScreenState extends State<BumonCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedManager;
  List<String> _managers = [];
  List<String> _tasks = [];
  List<String> _availableTasks = [];  // Firestoreから取得したタスクを保存

  @override
  void initState() {
    super.initState();
    _fetchManagers();
    _fetchTasks();
  }

  // Firestoreから責任者一覧を取得
  Future<void> _fetchManagers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Manager')
          .get();
      setState(() {
        _managers = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print("責任者の取得エラー: $e");
    }
  }

  // Firestoreからタスク一覧を取得
  Future<void> _fetchTasks() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('tasks').get(); // タスクコレクションからデータを取得
      if (snapshot.docs.isEmpty) {
        print("タスクがありません");
      }
      setState(() {
        _availableTasks = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print("タスクの取得エラー: $e");
    }
  }

  // Firestoreに部門を保存
  Future<void> _createDepartment() async {
    if (_nameController.text.isEmpty || _selectedManager == null || _tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('部門名、責任者、関連タスクを設定してください')));
      return;
    }

    await FirebaseFirestore.instance.collection('departments').add({
      'name': _nameController.text,
      'manager': _selectedManager,
      'tasks': _tasks, // タスクをリストとして保存
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('部門を作成しました')));
    Navigator.pop(context);
  }

  // 部門を削除
  Future<void> _deleteDepartment(String departmentId) async {
    try {
      await FirebaseFirestore.instance.collection('departments').doc(departmentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('部門を削除しました')));
    } catch (e) {
      print("部門の削除エラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('部門を作成')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('部門名', style: TextStyle(fontSize: 16)),
            TextField(controller: _nameController, decoration: const InputDecoration(hintText: '例: 管理部')),
            const SizedBox(height: 16),

            const Text('責任者', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedManager,
              hint: const Text('責任者を選択'),
              items: _managers.map((manager) {
                return DropdownMenuItem(value: manager, child: Text(manager));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedManager = value;
                });
              },
            ),
            const SizedBox(height: 16),

            const Text('関連タスク', style: TextStyle(fontSize: 16)),
            // Firestoreから取得したタスクを表示するチェックボックスリスト
            _availableTasks.isEmpty
                ? const Center(child: CircularProgressIndicator()) // タスクがロードされるまで待機
                : Column(
                    children: _availableTasks.map((task) {
                      return CheckboxListTile(
                        title: Text(task),
                        value: _tasks.contains(task),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _tasks.add(task);
                            } else {
                              _tasks.remove(task);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createDepartment,
                child: const Text('部門を作成'),
              ),
            ),

            const SizedBox(height: 20),

            // 部門一覧を表示するStreamBuilder
            const Text('作成済みの部門一覧:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('departments').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('部門がまだありません'));
                }

                return Expanded(
                  child: ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final departmentId = doc.id;  // 部門IDを取得
                      return ListTile(
                        title: Text(data['name'] ?? '名前なし'),
                        subtitle: Text('責任者: ${data['manager'] ?? '未設定'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteDepartment(departmentId),  // 削除ボタンを押した時に削除
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}





