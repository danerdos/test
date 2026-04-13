class ChapterAudio {
  final int chapterId;
  final int chapterNumber;
  final String title;
  final String audioUrl;
  final bool cached;
  final String voice;
  final String provider;

  ChapterAudio({
    required this.chapterId,
    required this.chapterNumber,
    required this.title,
    required this.audioUrl,
    required this.cached,
    required this.voice,
    required this.provider,
  });

  factory ChapterAudio.fromJson(Map<String, dynamic> json) {
    return ChapterAudio(
      chapterId: json['chapter_id'] as int,
      chapterNumber: json['chapter_number'] as int,
      title: (json['title'] ?? '') as String,
      audioUrl: (json['audio_url'] ?? '') as String,
      cached: (json['cached'] ?? false) as bool,
      voice: (json['voice'] ?? '') as String,
      provider: (json['provider'] ?? '') as String,
    );
  }
}
