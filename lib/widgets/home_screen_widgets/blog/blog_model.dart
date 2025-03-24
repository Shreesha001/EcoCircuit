import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Blog {
  final String id;
  final String title;
  final String content;
  final String author;
  final String timestamp;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.timestamp,
  });

  factory Blog.fromFirestore(Map<String, dynamic> data, String id) {
    // ✅ Convert Firestore Timestamp to readable String
    String formattedTimestamp = '';
    if (data['timestamp'] != null) {
      Timestamp timestamp = data['timestamp'] as Timestamp;
      formattedTimestamp = DateFormat(
        'yyyy-MM-dd HH:mm',
      ).format(timestamp.toDate());
    }

    return Blog(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? 'unknown',
      timestamp: formattedTimestamp,
    );
  }
}
