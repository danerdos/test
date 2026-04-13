class BookPage {
  final int id;
  final int chapterId;
  final int pageNumber;
  final String content;

  BookPage({
    required this.id,
    required this.chapterId,
    required this.pageNumber,
    required this.content,
  });

  factory BookPage.fromJson(Map<String, dynamic> json) {
    return BookPage(
      id: json['id'] as int,
      chapterId: json['chapter_id'] as int,
      pageNumber: json['page_number'] as int,
      content: (json['content'] ?? '') as String,
    );
  }
}
