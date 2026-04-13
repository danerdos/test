import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/book_page.dart';
import '../../models/chapter.dart';
import '../../models/chapter_audio.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/language_switch_button.dart';

class ChapterPage extends StatefulWidget {
  final Chapter chapter;

  const ChapterPage({super.key, required this.chapter});

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  static const List<String> _availableVoices = ['Rachel', 'Adam'];

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  late final Future<List<BookPage>> _pagesFuture;

  ChapterAudio? _chapterAudio;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;
  bool _isPreparingAudio = false;
  String _selectedVoice = _availableVoices.first;

  Chapter get chapter => widget.chapter;

  @override
  void initState() {
    super.initState();
    _pagesFuture = ApiService.getPages(chapter.id);
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) {
        return;
      }
      setState(() => _position = position);
    });
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) {
        return;
      }
      setState(() => _duration = duration);
    });
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      if (!mounted) {
        return;
      }
      setState(() => _playerState = state);
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('${l10n.chapter} ${chapter.chapterNumber}'),
        actions: const [LanguageSwitchButton()],
      ),
      body: FutureBuilder<List<BookPage>>(
        future: _pagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${l10n.failedToLoadChapterPages}\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          final pages = snapshot.data ?? const <BookPage>[];
          if (pages.isEmpty) {
            return Center(
              child: Text(
                l10n.noPagesForChapter,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildHeroCard(context, pages.length),
              const SizedBox(height: 16),
              _buildAudioCard(context),
              const SizedBox(height: 16),
              ...pages.map((page) => _buildParagraphCard(context, page)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, int paragraphCount) {
    final l10n = context.l10n;
    final isArabicTitle = _containsArabic(chapter.title);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.chapter} ${chapter.chapterNumber}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            chapter.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textDirection: isArabicTitle
                ? TextDirection.rtl
                : TextDirection.ltr,
            textAlign: isArabicTitle ? TextAlign.right : TextAlign.left,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoPill(
                icon: Icons.segment,
                label: '$paragraphCount ${l10n.paragraphs}',
              ),
              const SizedBox(width: 10),
              _InfoPill(
                icon: Icons.record_voice_over_outlined,
                label: l10n.listenToChapter,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCard(BuildContext context) {
    final l10n = context.l10n;
    final hasAudio = _chapterAudio != null;
    final isPlaying = _playerState == PlayerState.playing;
    final isPaused = _playerState == PlayerState.paused;
    final totalSeconds = _duration.inSeconds;
    final currentSeconds = _position.inSeconds.clamp(
      0,
      totalSeconds == 0 ? 0 : totalSeconds,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.readAloud,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isPreparingAudio
                ? l10n.preparingAudio
                : hasAudio
                ? (isPlaying ? l10n.nowPlaying : l10n.audioReady)
                : l10n.tapToListen,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                l10n.voice,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<String>(
                  segments: _availableVoices
                      .map(
                        (voice) => ButtonSegment<String>(
                          value: voice,
                          label: Text(voice),
                        ),
                      )
                      .toList(),
                  selected: {_selectedVoice},
                  onSelectionChanged: _isPreparingAudio
                      ? null
                      : (selection) => _selectVoice(selection.first),
                ),
              ),
            ],
          ),
          if (hasAudio) ...[
            const SizedBox(height: 10),
            Text(
              '${l10n.selectedVoice}: ${_chapterAudio!.voice}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: totalSeconds == 0 ? 0 : currentSeconds / totalSeconds,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: _isPreparingAudio
                    ? null
                    : (isPaused ? _resumeAudio : _prepareAndPlayAudio),
                icon: Icon(isPaused ? Icons.play_arrow : Icons.headphones),
                label: Text(isPaused ? l10n.resumeAudio : l10n.readAloud),
              ),
              OutlinedButton.icon(
                onPressed: isPlaying ? _pauseAudio : null,
                icon: const Icon(Icons.pause),
                label: Text(l10n.pauseAudio),
              ),
              OutlinedButton.icon(
                onPressed: (isPlaying || isPaused) ? _stopAudio : null,
                icon: const Icon(Icons.stop),
                label: Text(l10n.stopAudio),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParagraphCard(BuildContext context, BookPage page) {
    final l10n = context.l10n;
    final isArabicPage = _containsArabic(page.content);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.page} ${page.pageNumber}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            page.content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.7,
              fontSize: 15,
            ),
            textDirection: isArabicPage ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isArabicPage ? TextAlign.right : TextAlign.left,
          ),
        ],
      ),
    );
  }

  Future<void> _prepareAndPlayAudio() async {
    if (_isPreparingAudio) {
      return;
    }

    setState(() => _isPreparingAudio = true);

    try {
      ChapterAudio audio;
      if (_chapterAudio?.voice == _selectedVoice && _chapterAudio != null) {
        audio = _chapterAudio!;
      } else {
        audio = await ApiService.getChapterAudio(
          chapter.id,
          voice: _selectedVoice,
        );
      }
      _chapterAudio = audio;
      await _audioPlayer.play(UrlSource(audio.audioUrl));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.l10n.failedToLoadChapterAudio}\n$error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPreparingAudio = false);
      }
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _resumeAudio() async {
    await _audioPlayer.resume();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() => _position = Duration.zero);
    }
  }

  Future<void> _selectVoice(String voice) async {
    if (_selectedVoice == voice) {
      return;
    }

    await _audioPlayer.stop();
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedVoice = voice;
      _chapterAudio = null;
      _position = Duration.zero;
      _duration = Duration.zero;
      _playerState = PlayerState.stopped;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  bool _containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
