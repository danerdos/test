class Book {
  final int id;
  final String title;
  final String author;
  final String description;
  final String coverImage;
  final String language;
  final bool isFeatured;
  final int sortOrder;
  final int chapterCount;
  final int pageCount;
  final bool isReadable;
  final String? createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImage,
    required this.language,
    required this.isFeatured,
    required this.sortOrder,
    required this.chapterCount,
    required this.pageCount,
    required this.isReadable,
    required this.createdAt,
  });

  bool get isArabic => language.toLowerCase() == 'ar';
  String get languageCodeLabel => isArabic ? 'AR' : 'EN';

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: _asInt(json['id']),
      title: (json['title'] ?? '') as String,
      author: (json['author'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      coverImage: (json['cover_image'] ?? '') as String,
      language: ((json['language'] ?? 'en') as String).toLowerCase(),
      isFeatured: _asBool(json['is_featured']),
      sortOrder: _asInt(json['sort_order']),
      chapterCount: _asInt(json['chapter_count']),
      pageCount: _asInt(json['page_count']),
      isReadable: _asBool(json['is_readable']),
      createdAt: json['created_at'] as String?,
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

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is int) {
      return value != 0;
    }
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }
}
