class Chapter {
  final int id;
  final int bookId;
  final int chapterNumber;
  final String title;

  Chapter({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.title,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as int,
      bookId: json['book_id'] as int,
      chapterNumber: json['chapter_number'] as int,
      title: (json['title'] ?? '') as String,
    );
  }
}
