import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'task.dart';  // タスク作成画面をインポート
import 'bumon.dart'; // 部門作成画面をインポート（ファイル名を変更）

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('イベント詳細'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('イベントが見つかりませんでした'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('イベント名: ${data['name'] ?? '名前なし'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('日程: ${data['date'] ?? '日程なし'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('場所: ${data['location'] ?? '場所なし'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('概要: ${data['description'] ?? '概要なし'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),

                // タスクを作成ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskCreationScreen(), 
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, 
                      ),
                    ),
                    child: const Text('タスクを作成'),
                  ),
                ),

                const SizedBox(height: 10), // ボタン間の余白

                // 部門を作成ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BumonCreationScreen(), // クラス名も変更
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, 
                      ),
                    ),
                    child: const Text('部門を作成'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}






