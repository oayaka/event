//伊藤　admin
//123@gmail.com
//123456

//田中　manager
//tanaka@gmail.com
//123456

//大橋  member
// abcdef@gmail.com
// 123456

//斎藤　admin
//saito@gmail.com
// 123456



import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TourokuScreen extends StatefulWidget {
  const TourokuScreen({super.key});

  @override
  State<TourokuScreen> createState() => _TourokuScreenState();
}

class _TourokuScreenState extends State<TourokuScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // 名前入力用のコントローラーを追加
  String _selectedRole = 'Member'; // デフォルトは Member

  // ユーザーを登録するメソッド
  Future<void> _registerUser() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final User? user = userCredential.user;
      if (user != null) {
        // Firestoreにユーザー情報とロール、名前を追加
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': _nameController.text, // 名前を保存
          'role': _selectedRole, // 選択したロールを保存
        });

        Navigator.pop(context); // 登録後、前の画面に戻る
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新規登録')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 名前入力欄
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名前',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
            const SizedBox(height: 16),
            // メールアドレス入力欄
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
            const SizedBox(height: 16),
            // パスワード入力欄
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'パスワード',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
            const SizedBox(height: 16),
            // ロール選択欄
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'ロール',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
              items: <String>['Admin', 'Manager', 'Member']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // 登録ボタン
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('登録'),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class TourokuScreen extends StatefulWidget {
//   const TourokuScreen({super.key});

//   @override
//   State<TourokuScreen> createState() => _TourokuScreenState();
// }

// class _TourokuScreenState extends State<TourokuScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController(); // 名前入力用のコントローラーを追加
//   String _selectedRole = 'Member'; // デフォルトは Member

//   // ユーザーを登録するメソッド
//   Future<void> _registerUser() async {
//     try {
//       final UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );
//       final User? user = userCredential.user;
//       if (user != null) {
//         // Firestoreにユーザー情報とロール、名前を追加
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'email': user.email,
//           'name': _nameController.text, // 名前を保存
//           'role': _selectedRole, // 選択したロールを保存
//         });

//         Navigator.pop(context); // 登録後、前の画面に戻る
//       }
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('エラー: ${e.message}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('新規登録')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController, // 名前入力欄
//               decoration: const InputDecoration(labelText: '名前'),
//             ),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'メールアドレス'),
//             ),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: 'パスワード'),
//             ),
//             // ロール選択用のDropdownButtonを追加
//             DropdownButton<String>(
//               value: _selectedRole,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedRole = newValue!;
//                 });
//               },
//               items: <String>['Admin', 'Manager', 'Member']
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//             ElevatedButton(
//               onPressed: _registerUser,
//               child: const Text('登録'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class TourokuScreen extends StatefulWidget {
//   const TourokuScreen({super.key});

//   @override
//   State<TourokuScreen> createState() => _TourokuScreenState();
// }

// class _TourokuScreenState extends State<TourokuScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController(); // 名前入力用のコントローラーを追加

//   Future<void> _registerUser() async {
//     try {
//       final UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );
//       final User? user = userCredential.user;
//       if (user != null) {
//         // Firestoreにユーザー情報とロール、名前を追加
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'email': user.email,
//           'name': _nameController.text, // 名前を保存
//           'role': 'Member', // 最初は Member として設定
//         });

//         Navigator.pop(context); // 登録後、前の画面に戻る
//       }
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('エラー: ${e.message}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('新規登録')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController, // 名前入力欄
//               decoration: const InputDecoration(labelText: '名前'),
//             ),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'メールアドレス'),
//             ),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: 'パスワード'),
//             ),
//             ElevatedButton(
//               onPressed: _registerUser,
//               child: const Text('登録'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }










// // touroku.dart新規ユーザー登録画面
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class TourokuScreen extends StatefulWidget {
//   const TourokuScreen({super.key});

//   @override
//   State<TourokuScreen> createState() => _TourokuScreenState();
// }

// class _TourokuScreenState extends State<TourokuScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   Future<void> _signUp() async {
//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );
//       // 新規作成後、ログイン画面に戻る
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('ユーザー登録が完了しました！')),
//       );
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('エラー: ${e.message}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('新規ユーザー登録')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'メールアドレス'),
//             ),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: 'パスワード'),
//             ),
//             ElevatedButton(
//               onPressed: _signUp,
//               child: const Text('完了'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
