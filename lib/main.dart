// main.dart

//import 'package:event1220/task.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'home.dart';
import 'event.dart'; // イベント作成画面を追加

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Authentication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/login': (context) => const LoginScreen(),
        '/event': (context) => const EventCreationScreen(), // イベント作成画面へのルートを追加
        //'/task':(context) => const TaskCreationScreen(), // タスク作成画面へのルートを追加
      },
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            // ユーザーがログインしている場合
            return const HomeScreen();
          } else {
            // ユーザーが未ログインの場合
            return const LoginScreen();
          }
        }
        // 読み込み中のスピナー
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}













// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'firebase_options.dart';
// import 'login.dart';
// import 'home.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Firebase Authentication',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const AuthScreen(),
//         '/login': (context) => const LoginScreen(),
//       },
//     );
//   }
// }

// class AuthScreen extends StatelessWidget {
//   const AuthScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.active) {
//           if (snapshot.hasData) {
//             // ユーザーがログインしている場合
//             return const HomeScreen();
//           } else {
//             // ユーザーが未ログインの場合
//             return const LoginScreen();
//           }
//         }
//         // 読み込み中のスピナー
//         return const CircularProgressIndicator();
//       },
//     );
//   }
// }
