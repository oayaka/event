// invite_user.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InviteUserScreen extends StatefulWidget {
  const InviteUserScreen({super.key});

  @override
  State<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _role = 'Member';

  Future<void> _inviteUser() async {
    try {
      final email = _emailController.text;
      // メールアドレスからユーザーを招待（ここでは新規登録処理）
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: 'tempPassword123', // 一時的なパスワード
      );
      final User? user = userCredential.user;
      if (user != null) {
        // Firestoreに新しいユーザーのロールを設定
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'role': _role, // 招待されたユーザーのロールを設定
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ユーザーを招待しました')),
        );
        Navigator.pop(context); // 招待後に戻る
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ユーザー招待')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            DropdownButton<String>(
              value: _role,
              onChanged: (String? newValue) {
                setState(() {
                  _role = newValue!;
                });
              },
              items: <String>['Member', 'Manager']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _inviteUser,
              child: const Text('招待'),
            ),
          ],
        ),
      ),
    );
  }
}
