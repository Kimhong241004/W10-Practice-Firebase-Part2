import 'dart:convert';

import 'package:http/http.dart' as http;
 
import '../../../model/artist/artist.dart';
import '../../../model/comment/comment.dart';
import '../../../model/songs/song.dart';
import '../../dtos/artist_dto.dart';
import '../../dtos/comment_dto.dart';
import '../../dtos/song_dto.dart';
import 'artist_repository.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  final Uri artistsUri = Uri.https(
    'w10-p2-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists.json',
  );

  List<Artist>? _cachedArtists;

  @override
  Future<List<Artist>> fetchArtists({bool forceFetch = false}) async {
    // 1. Return cache if available
    if (!forceFetch && _cachedArtists != null) {
      return _cachedArtists!;
    }

    // 2. Otherwise fetch from API
    final http.Response response = await http.get(artistsUri);

    if (response.statusCode == 200) {
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Artist> result = [];
      for (final entry in songJson.entries) {
        result.add(ArtistDto.fromJson(entry.key, entry.value));
      }

      // 3. Store in memory
      _cachedArtists = result;

      return _cachedArtists!;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {
    return null;
  }

  @override
  Future<List<Song>> fetchArtistSongs(String artistId) async {
    final Uri uri = Uri.https(
      'w10-p2-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/songs.json',
    );

    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> songsJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songsJson.entries) {
        Song song = SongDto.fromJson(entry.key, entry.value);
        if (song.artistId == artistId) {
          result.add(song);
        }
      }
      return result;
    } else {
      throw Exception('Failed to load songs');
    }
  }

  @override
  Future<List<Comment>> fetchArtistComments(String artistId) async {
    final Uri uri = Uri.https(
      'w10-p2-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/artists/$artistId/comments.json',
    );

    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      if (response.body == 'null') return [];

      Map<String, dynamic> commentsJson = json.decode(response.body);

      List<Comment> result = [];
      for (final entry in commentsJson.entries) {
        result.add(CommentDto.fromJson(entry.key, entry.value));
      }
      return result;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  Future<void> postComment(String artistId, String text) async {
    final Uri uri = Uri.https(
      'w10-p2-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/artists/$artistId/comments.json',
    );

    final http.Response response = await http.post(
      uri,
      body: json.encode(CommentDto.toJson(text)),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to post comment');
    }
  }
}
