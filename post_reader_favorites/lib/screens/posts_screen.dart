
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final String apiUrl = 'https://jsonplaceholder.typicode.com/posts';
  final TextEditingController searchController = TextEditingController();

  List posts = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          posts = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load posts. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Connection failed. Please check your internet.';
        isLoading = false;
      });
    }
  }

  Future<void> createPost(String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'userId': 1,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);

        final newPost = {
          'id': result['id'] ?? -(posts.length + 1),
          'title': title,
          'body': body,
          'userId': 1,
        };

        setState(() {
          posts.insert(0, newPost);
        });

        showMessage('Post created successfully!');
      } else {
        showMessage(
          'Failed to create post. Status: ${response.statusCode}',
        );
      }
    } catch (_) {
      if (!mounted) return;
      showMessage('Connection failed. Please try again.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showAddPostDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String error = '';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create a post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Post title',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Post body',
                    alignLabelWithHint: true,
                  ),
                ),
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    error,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();

                if (title.isEmpty || body.isEmpty) {
                  setDialogState(() {
                    error = 'Both fields are required.';
                  });
                  return;
                }

                Navigator.pop(dialogContext);
                createPost(title, body);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    ).then((_) {
      titleController.dispose();
      bodyController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = posts.where((post) {
      final query = searchText.toLowerCase();
      return post['title'].toString().toLowerCase().contains(query) ||
          post['body'].toString().toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Reader',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover a new perspective.',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Explore posts and save the ones you like.',
                  style: TextStyle(color: Color(0xFFA3A6AB)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() => searchText = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search posts',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchText.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() => searchText = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: fetchPosts,
                                child: const Text('Try again'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filteredPosts.isEmpty
                        ? const Center(child: Text('No posts found.'))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 100,
                            ),
                            itemCount: filteredPosts.length,
                            itemBuilder: (context, index) {
                              final post = filteredPosts[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF303238),
                                    foregroundColor: Colors.white,
                                    child: Text('${post['id']}'),
                                  ),
                                  title: Text(
                                    post['title'].toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      post['body'].toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFA3A6AB),
                                      ),
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/details',
                                      arguments: {
                                        'id': post['id'],
                                        'title': post['title'],
                                        'body': post['body'],
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddPostDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create post'),
      ),
    );
  }
}
