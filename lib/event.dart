import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // デフォルトで今日の日付をセット
    _eventDateController.text = DateTime.now().toLocal().toString().split(' ')[0]; // YYYY-MM-DD形式
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('events').add({
          'name': _eventNameController.text,
          'date': _eventDateController.text,
          'description': _eventDescriptionController.text,
          'location': _eventLocationController.text,
          'createdBy': FirebaseAuth.instance.currentUser?.uid,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('イベントを保存しました！')),
        );
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  // カレンダーを表示する関数
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _eventDateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('イベント作成画面'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(labelText: 'イベント名'),
                validator: (value) => value!.isEmpty ? 'イベント名を入力してください' : null,
              ),
              TextFormField(
                controller: _eventDateController,
                decoration: InputDecoration(
                  labelText: '日程 (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) => value!.isEmpty ? '日程を入力してください' : null,
              ),
              TextFormField(
                controller: _eventDescriptionController,
                decoration: const InputDecoration(labelText: '概要'),
                validator: (value) => value!.isEmpty ? '概要を入力してください' : null,
              ),
              TextFormField(
                controller: _eventLocationController,
                decoration: const InputDecoration(labelText: '場所'),
                validator: (value) => value!.isEmpty ? '場所を入力してください' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEvent,
                child: const Text('イベントを保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}









