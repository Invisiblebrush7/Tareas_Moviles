class Song {
  final String author;
  final String title;
  final String imageUrl;
  final String songLink;

  @override
  String toString() {
    return "(${this.title}:${this.author}:${this.songLink})";
  }

  Song(
      {required this.author,
      required this.title,
      required this.imageUrl,
      required this.songLink});
}
