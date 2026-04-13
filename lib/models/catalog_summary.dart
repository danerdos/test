class CatalogSummary {
  final int totalBooks;
  final int readableBooks;
  final int englishBooks;
  final int arabicBooks;

  const CatalogSummary({
    required this.totalBooks,
    required this.readableBooks,
    required this.englishBooks,
    required this.arabicBooks,
  });

  factory CatalogSummary.fromJson(Map<String, dynamic> json) {
    return CatalogSummary(
      totalBooks: _asInt(json['total_books']),
      readableBooks: _asInt(json['readable_books']),
      englishBooks: _asInt(json['english_books']),
      arabicBooks: _asInt(json['arabic_books']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
