import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'setting.dart';
import 'eventDetail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _deleteEvent(String eventId) async {
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
  }

  Future<Map<String, String?>> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String? name = userDoc['name'];
      String? role = userDoc['role'];
      return {'name': name, 'role': role};
    }
    return {'name': null, 'role': null};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム画面'),
        actions: [
          FutureBuilder<Map<String, String?>>(
            future: _getUserInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data?['name'] == null || snapshot.data?['role'] == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '${snapshot.data?['name']} (${snapshot.data?['role']})',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<String?>(
              future: _getUserInfo().then((userInfo) => userInfo['role']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data != 'Admin') {
                  return const SizedBox.shrink();
                }
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/event');
                  },
                  child: const Text('イベント作成'),
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('events').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('イベントはまだありません'));
                  }
                  return FutureBuilder<String?>(
                    future: _getUserInfo().then((userInfo) => userInfo['role']),
                    builder: (context, roleSnapshot) {
                      if (roleSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      String? role = roleSnapshot.data;

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final eventId = doc.id;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.event),
                              title: Text(data['name'] ?? '名前なし'),
                              subtitle: Text('${data['date'] ?? '日程なし'}\n${data['location'] ?? '場所なし'}'),
                              trailing: role == 'Admin'
                                  ? IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await _deleteEvent(eventId);
                                      },
                                    )
                                  : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventDetailScreen(eventId: eventId),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


















// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'setting.dart';  // setting.dart をインポート
// import 'eventDetail.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   Future<void> _signOut(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   Future<void> _deleteEvent(String eventId) async {
//     await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
//   }

//   // 現在のユーザーの情報を取得（名前とロール）
//   Future<Map<String, String?>> _getUserInfo() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//       String? name = userDoc['name']; // ユーザー名
//       String? role = userDoc['role']; // ユーザーのロール
//       return {'name': name, 'role': role};
//     }
//     return {'name': null, 'role': null}; // ユーザーが認証されていない場合
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ホーム画面'),
//         actions: [
//           // 現在のユーザーの名前とロールを表示
//           FutureBuilder<Map<String, String?>>(
//             future: _getUserInfo(),  // _getUserInfo() を使用
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (!snapshot.hasData || snapshot.data?['name'] == null || snapshot.data?['role'] == null) {
//                 return const SizedBox.shrink(); // 空のボックスを表示
//               }
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Text(
//                   '${snapshot.data?['name']} (${snapshot.data?['role']})',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               );
//             },
//           ),
//           // 設定アイコン
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               // 設定画面へ遷移
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const SettingScreen(),
//                 ),
//               );
//             },
//           ),
//           // ログアウトアイコン
//           IconButton(
//             icon: const Icon(Icons.exit_to_app),
//             onPressed: () => _signOut(context),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ロールに応じて「イベント作成」ボタンを表示
//             FutureBuilder<String?>(
//               future: _getUserInfo().then((userInfo) => userInfo['role']), // ユーザー情報からロールを取得
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || snapshot.data != 'Admin') {
//                   // ロールが Admin でない場合はボタンを表示しない
//                   return const SizedBox.shrink(); // 空のボックスを表示
//                 }
//                 return ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.zero, // 四角形に設定
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/event');
//                   },
//                   child: const Text('イベント作成'),
//                 );
//               },
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance.collection('events').snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text('イベントはまだありません'));
//                   }
//                   return ListView(
//                     children: snapshot.data!.docs.map((doc) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       final eventId = doc.id;
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         child: ListTile(
//                           leading: const Icon(Icons.event),
//                           title: Text(data['name'] ?? '名前なし'),
//                           subtitle: Text('${data['date'] ?? '日程なし'}\n${data['location'] ?? '場所なし'}'),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () async {
//                               await _deleteEvent(eventId);
//                             },
//                           ),
//                           onTap: () {
//                             // イベント詳細画面へ遷移
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => EventDetailScreen(eventId: eventId),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





