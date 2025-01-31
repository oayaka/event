//ohashi-a2303@school.ac.jp
//abc123

// login.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'touroku.dart'; // 新規登録画面をインポート

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // ログイン成功したらホーム画面に遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'パスワード'),
            ),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('ログイン'),
            ),
            // 新規作成ボタンを追加
            TextButton(
              onPressed: () {
                // 新規登録画面へ遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TourokuScreen()),
                );
              },
              child: const Text('新規作成'),
            ),
          ],
        ),
      ),
    );
  }
}








