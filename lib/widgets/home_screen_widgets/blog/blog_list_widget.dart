import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_circuit/widgets/home_screen_widgets/blog/blog_card.dart';
import 'package:eco_circuit/widgets/home_screen_widgets/blog/blog_model.dart';
import 'package:flutter/material.dart';

class BlogListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // Adjust height for scroll
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No blogs available"));
          }

          List<Blog> blogs =
              snapshot.data!.docs.map((doc) {
                return Blog.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );
              }).toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              return BlogCard(blog: blogs[index]);
            },
          );
        },
      ),
    );
  }
}
