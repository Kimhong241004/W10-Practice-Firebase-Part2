import 'package:flutter/material.dart';
import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../model/comment/comment.dart';
import '../../../../model/songs/song.dart';
import '../../../utils/async_value.dart';

class ArtistDetailViewModel extends ChangeNotifier {
  final ArtistRepository artistRepository;
  final String artistId;

  AsyncValue<List<Song>> songs = AsyncValue.loading();
  AsyncValue<List<Comment>> comments = AsyncValue.loading();

  ArtistDetailViewModel({
    required this.artistRepository,
    required this.artistId,
  }) {
    fetchData();
  }

  void fetchData() async {
    // 1- Loading state
    songs = AsyncValue.loading();
    comments = AsyncValue.loading();
    notifyListeners();

    try {
      // 2- Fetch songs
      List<Song> fetchedSongs = await artistRepository.fetchArtistSongs(artistId);
      songs = AsyncValue.success(fetchedSongs);
    } catch (e) {
      songs = AsyncValue.error(e);
    }
    notifyListeners();

    try {
      // 3- Fetch comments
      List<Comment> fetchedComments = await artistRepository.fetchArtistComments(artistId);
      comments = AsyncValue.success(fetchedComments);
    } catch (e) {
      comments = AsyncValue.error(e);
    }
    notifyListeners();
  }

  void addComment(String text) async {
    try {
      await artistRepository.postComment(artistId, text);

      // Update local state
      final currentComments = comments.data ?? [];
      final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
      );
      comments = AsyncValue.success([...currentComments, newComment]);
      notifyListeners();
    } catch (e) {
      comments = AsyncValue.error(e);
      notifyListeners();
    }
  }
}
