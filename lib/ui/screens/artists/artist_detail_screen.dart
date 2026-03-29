import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/artist/artist_repository.dart';
import '../../../model/artist/artist.dart';
import '../../../model/songs/song.dart';
import '../../../model/comment/comment.dart';
import '../../utils/async_value.dart';
import '../../widgets/song/comment_tile.dart';
import 'view_model/artist_detail_view_model.dart';

class ArtistDetailScreen extends StatelessWidget {
  const ArtistDetailScreen({super.key, required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArtistDetailViewModel(
        artistRepository: context.read<ArtistRepository>(),
        artistId: artist.id,
      ),
      child: _ArtistDetailContent(artist: artist),
    );
  }
}

class _ArtistDetailContent extends StatelessWidget {
  const _ArtistDetailContent({required this.artist});

  final Artist artist;

  void _showCommentBottomSheet(BuildContext context, ArtistDetailViewModel vm) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add a Comment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  vm.addComment(text);
                  controller.clear();
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ArtistDetailViewModel vm = context.watch<ArtistDetailViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(artist.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artist image
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(artist.imageUrl.toString()),
              ),
            ),
            SizedBox(height: 10),
            Center(child: Text(artist.genre, style: TextStyle(color: Colors.grey))),
            SizedBox(height: 20),

            // Songs section
            Text('Songs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildSongsSection(vm),

            SizedBox(height: 20),

            // Comments section
            Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildCommentsSection(vm),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCommentBottomSheet(context, vm),
        child: Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildSongsSection(ArtistDetailViewModel vm) {
    switch (vm.songs.state) {
      case AsyncValueState.loading:
        return Center(child: CircularProgressIndicator());
      case AsyncValueState.error:
        return Text('Error: ${vm.songs.error}', style: TextStyle(color: Colors.red));
      case AsyncValueState.success:
        List<Song> songs = vm.songs.data!;
        if (songs.isEmpty) {
          return Text('No songs yet.');
        }
        return Column(
          children: songs
              .map((song) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(song.imageUrl.toString()),
                    ),
                    title: Text(song.title),
                    subtitle: Text('${song.duration.inMinutes} mins'),
                  ))
              .toList(),
        );
    }
  }

  Widget _buildCommentsSection(ArtistDetailViewModel vm) {
    switch (vm.comments.state) {
      case AsyncValueState.loading:
        return Center(child: CircularProgressIndicator());
      case AsyncValueState.error:
        return Text('Error: ${vm.comments.error}', style: TextStyle(color: Colors.red));
      case AsyncValueState.success:
        List<Comment> comments = vm.comments.data!;
        if (comments.isEmpty) {
          return Text('No comments yet.');
        }
        return Column(
          children: comments.map((c) => CommentTile(comment: c)).toList(),
        );
    }
  }
}
