
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> saveFavorite(
    BuildContext context,
    Map<String, dynamic> post,
  ) async {
    final box = Hive.box('favoritesBox');
    final id = post['id'];

    if (box.containsKey(id)) {
      showMessage(context, 'This post is already in Favorites.');
      return;
    }

    await box.put(id, {
      'id': id,
      'title': post['title'],
      'body': post['body'],
      'note': '',
    });

    if (context.mounted) {
      showMessage(context, 'Post saved to Favorites!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF292B30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'POST #${post['id']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              post['title'].toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                height: 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              post['body'].toString(),
              style: const TextStyle(
                color: Color(0xFFD0D0D0),
                fontSize: 16,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => saveFavorite(context, post),
                icon: const Icon(Icons.favorite_border),
                label: const Text('Save to Favorites'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Posts'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF444444)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
