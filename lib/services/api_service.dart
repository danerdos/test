import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/book_page.dart';
import '../models/catalog_summary.dart';
import '../models/chapter.dart';
import '../models/chapter_audio.dart';

class ApiService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'BOOK_API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceAll(RegExp(r'/$'), '');
    }

    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  static Future<List<dynamic>> _getList(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'));

    if (response.statusCode != 200) {
      throw Exception('Request failed for $path (${response.statusCode})');
    }

    return json.decode(response.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> _getMap(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'));

    if (response.statusCode != 200) {
      throw Exception('Request failed for $path (${response.statusCode})');
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  static Future<List<Book>> getBooks() async {
    final data = await _getList('/books');
    return data
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<CatalogSummary> getCatalogSummary() async {
    final data = await _getMap('/books/summary');
    return CatalogSummary.fromJson(data);
  }

  static Future<List<Chapter>> getChapters(int bookId) async {
    final data = await _getList('/books/$bookId/chapters');
    return data
        .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<BookPage>> getPages(int chapterId) async {
    final data = await _getList('/chapters/$chapterId/pages');
    return data
        .map((item) => BookPage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<ChapterAudio> getChapterAudio(
    int chapterId, {
    String? voice,
  }) async {
    final uri = Uri.parse('$baseUrl/chapters/$chapterId/audio').replace(
      queryParameters: voice == null || voice.isEmpty ? null : {'voice': voice},
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Request failed for ${uri.path} (${response.statusCode})',
      );
    }

    return ChapterAudio.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<Map<Chapter, List<BookPage>>> getBookContent(int bookId) async {
    final chapters = await getChapters(bookId);
    final pagesByChapter = await Future.wait(
      chapters.map(
        (chapter) async => MapEntry(chapter, await getPages(chapter.id)),
      ),
    );

    return Map<Chapter, List<BookPage>>.fromEntries(pagesByChapter);
  }
}
