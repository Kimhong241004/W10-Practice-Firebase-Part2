class Comment {
  final String id;
  final String text;

  Comment({
    required this.id,
    required this.text,
  });

  @override
  String toString() {
    return 'Comment(id: $id, text: $text)';
  }
}
