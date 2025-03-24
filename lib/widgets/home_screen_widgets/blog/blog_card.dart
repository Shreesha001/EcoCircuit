import 'package:flutter/material.dart';
import 'package:eco_circuit/widgets/home_screen_widgets/blog/blog_model.dart';
import 'package:eco_circuit/widgets/home_screen_widgets/blog/blog_detail_screen.dart';

class BlogCard extends StatelessWidget {
  final Blog blog;

  const BlogCard({Key? key, required this.blog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /// Navigate to Blog Detail Screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BlogDetailScreen(blog: blog)),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 **Blog Title**
              Text(
                blog.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              /// 🔹 **Blog Excerpt**
              Text(
                blog.content,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              /// 🔹 **Author & Timestamp**
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "By: ${blog.author}",
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  Text(
                    blog.timestamp,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
