import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Box box = Hive.box('favoritesBox');

  void editNote(Map post) {
    final noteController = TextEditingController(text: post['note'] ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Personal note', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Add a note about this post', alignLabelWithHint: true), maxLines: 3, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              final updated = Map.from(post);
              updated['note'] = noteController.text.trim();
              box.put(post['id'], updated);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note updated.'), behavior: SnackBarBehavior.floating));
            },
            icon: const Icon(Icons.check, size: 18), label: const Text('Save note'),
          ),
        ],
      ),
    ).then((_) => noteController.dispose());
  }

  void deletePost(Map post) {
    box.delete(post['id']);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites.'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My favorites'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context))),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box currentBox, _) {
          final favorites = currentBox.values.toList();
          if (favorites.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(padding: const EdgeInsets.all(22), decoration: const BoxDecoration(color: Color(0xFFE9EEFF), shape: BoxShape.circle), child: const Icon(Icons.favorite_border_rounded, size: 42, color: Color(0xFF3659D9))),
              const SizedBox(height: 18),
              const Text('Your favorites live here', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF172554))),
              const SizedBox(height: 8),
              Text('Save posts you want to revisit. They will stay here even after you close the app.', textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey.shade600, height: 1.5)),
              const SizedBox(height: 18),
              ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.auto_stories_rounded), label: const Text('Explore posts')),
            ])));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = favorites[index] as Map;
              final String note = post['note'] ?? '';
              return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFFFEAF0), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.favorite_rounded, color: Color(0xFFD83F69), size: 21)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('POST #${post['id']}', style: const TextStyle(color: Color(0xFF3659D9), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text(post['title'], style: const TextStyle(fontSize: 15, height: 1.3, fontWeight: FontWeight.w800, color: Color(0xFF172554))),
                  ])),
                  PopupMenuButton<String>(
                    tooltip: 'Post options',
                    onSelected: (value) { if (value == 'edit') editNote(post); if (value == 'delete') deletePost(post); },
                    itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 19), SizedBox(width: 9), Text('Edit note')])), PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 19), SizedBox(width: 9), Text('Remove favorite')]))],
                  ),
                ],),
                const SizedBox(height: 13),
                Text(post['body'], maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.blueGrey.shade600, height: 1.5, fontSize: 13)),
                const SizedBox(height: 13),
                Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF5F7FC), borderRadius: BorderRadius.circular(12)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.sticky_note_2_outlined, size: 17, color: Color(0xFF3659D9)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(note.isEmpty ? 'No personal note yet.' : note, style: TextStyle(color: note.isEmpty ? Colors.blueGrey.shade400 : const Color(0xFF243B83), fontSize: 12, height: 1.4, fontStyle: note.isEmpty ? FontStyle.italic : FontStyle.normal))),
                  InkWell(onTap: () => editNote(post), child: const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.edit_rounded, size: 17, color: Color(0xFF3659D9)))),
                ])),
              ])));
            },
          );
        },
      ),
    );
  }
}
