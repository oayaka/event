import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskCreationScreen extends StatefulWidget {
  const TaskCreationScreen({Key? key}) : super(key: key);

  @override
  State<TaskCreationScreen> createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  String? _assignedUser;
  String _status = '未着手';
  List<String> _users = [];
  List<String> _events = [];
  String? _selectedEvent;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchEvents();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _users = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      _events = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _deadlineController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('tasks').add({
          'name': _taskNameController.text,
          'deadline': _deadlineController.text,
          'assignedTo': _assignedUser,
          'status': _status,
          'createdBy': FirebaseAuth.instance.currentUser?.uid,
          'eventId': _selectedEvent,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('タスクを保存しました！')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _assignedUser = null;
          _status = '未着手';
          _selectedEvent = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タスクを削除しました！')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('タスク作成画面'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _taskNameController,
                decoration: const InputDecoration(labelText: 'タスク名'),
                validator: (value) => value!.isEmpty ? 'タスク名を入力してください' : null,
              ),
              TextFormField(
                controller: _deadlineController,
                decoration: InputDecoration(
                  labelText: '締切 (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) => value!.isEmpty ? '締切を入力してください' : null,
              ),
              DropdownButtonFormField<String>(
                value: _assignedUser,
                items: _users
                    .map((user) => DropdownMenuItem(
                          value: user,
                          child: Text(user),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _assignedUser = value;
                  });
                },
                decoration: const InputDecoration(labelText: '担当者'),
                validator: (value) => value == null ? '担当者を選択してください' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedEvent,
                items: _events
                    .map((event) => DropdownMenuItem(
                          value: event,
                          child: Text(event),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEvent = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'イベント'),
                validator: (value) => value == null ? 'イベントを選択してください' : null,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['未着手', '進行中', '完了']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'ステータス'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('タスクを保存'),
              ),
              const SizedBox(height: 20),
              const Text(
                '作成済みのタスク一覧:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('eventId', isEqualTo: _selectedEvent)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('タスクはまだありません');
                  }
                  return ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name'] ?? '名前なし'),
                        subtitle: Text(
                            '締切: ${data['deadline'] ?? '未設定'}\n担当: ${data['assignedTo'] ?? '未設定'}\nステータス: ${data['status'] ?? '不明'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(doc.id),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}









