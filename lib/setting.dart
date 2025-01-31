import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  // ユーザー登録処理
  Future<void> _registerUser(BuildContext context) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新規登録'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                if (email.isNotEmpty && password.isNotEmpty) {
                  try {
                    // Firebase Authenticationでユーザー登録
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('エラー: $e')),
                    );
                  }
                }
              },
              child: const Text('登録'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  // パスワード変更処理
  Future<void> _changePassword(BuildContext context) async {
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('パスワード変更'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: '新しいパスワード'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final newPassword = passwordController.text.trim();

                if (newPassword.isNotEmpty) {
                  try {
                    // Firebase Authenticationでパスワード変更
                    await FirebaseAuth.instance.currentUser!
                        .updatePassword(newPassword);
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('エラー: $e')),
                    );
                  }
                }
              },
              child: const Text('変更'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _registerUser(context),
              child: const Text('ユーザー登録'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _changePassword(context),
              child: const Text('パスワード変更'),
            ),
          ],
        ),
      ),
    );
  }
}









// // setting.dart
// import 'package:flutter/material.dart';

// class SettingScreen extends StatelessWidget {
//   const SettingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('設定'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text('ここに設定項目を追加できます。', style: TextStyle(fontSize: 18)),
//             // 他の設定項目をここに追加できます
//           ],
//         ),
//       ),
//     );
//   }
// }
