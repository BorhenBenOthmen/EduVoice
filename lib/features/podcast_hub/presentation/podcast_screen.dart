import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/podcast.dart';
import 'state/podcast_cubit.dart';
import 'state/podcast_state.dart';
import 'smart_podcast_player.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../injection_container.dart';
import '../../../../core/theme/app_theme.dart';

class PodcastScreen extends StatefulWidget {
  /// Optional pre-filtered data from the AI voice command.
  final dynamic initialPayload;

  const PodcastScreen({super.key, this.initialPayload});

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final cubit = context.read<PodcastCubit>();
    final payload = widget.initialPayload;
    List<dynamic>? targetList;

    if (payload != null) {
      if (payload is List) {
        targetList = payload;
      } else if (payload is Map<String, dynamic>) {
        if (payload.containsKey('results') && payload['results'] is List) {
          targetList = payload['results'];
        } else if (payload.containsKey('data') && payload['data'] is List) {
          targetList = payload['data'];
        }
      }
    }

    if (targetList != null && targetList.isNotEmpty) {
      cubit.loadFromPayload(targetList);
    } else {
      cubit.loadPodcasts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: Text(
            l.podcastTitle,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.cream),
      ),
      body: Column(
        children: [
          _buildAccessibleSearchBar(l),
          Expanded(
            child: BlocConsumer<PodcastCubit, PodcastState>(
              listener: (context, state) async {
                final tts = locator<TtsService>();
                if (state is PodcastLoading) {
                  await tts.speak(l.podcastLoading);
                } else if (state is PodcastLoaded) {
                  await tts.speak(l.podcastCountTts(state.podcasts.length));
                } else if (state is PodcastError) {
                  await tts.speak(l.podcastErrorTts);
                }
              },
              builder: (context, state) {
                if (state is PodcastLoading || state is PodcastInitial) {
                  return Center(
                    child: Semantics(
                      label: l.podcastLoading,
                      child: const CircularProgressIndicator(
                        color: AppTheme.darkTeal,
                      ),
                    ),
                  );
                } else if (state is PodcastError) {
                  return Center(
                    child: Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: AppTheme.navy, fontSize: 20),
                    ),
                  );
                } else if (state is PodcastLoaded) {
                  return _buildPodcastList(state.podcasts, l);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibleSearchBar(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Semantics(
        label: l.podcastSearchLabel,
        hint: l.podcastSearchHint,
        textField: true,
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppTheme.navy, fontSize: 22),
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cream,
            hintText: l.podcastSearchPlaceholder,
            hintStyle: const TextStyle(color: AppTheme.darkTeal),
            prefixIcon: const Icon(Icons.search, color: AppTheme.darkTeal, size: 32),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.darkTeal, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.darkTeal, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.navy, width: 3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodcastList(List<Podcast> allPodcasts, AppLocalizations l) {
    final filteredPodcasts = allPodcasts.where((podcast) {
      return podcast.name.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredPodcasts.isEmpty) {
      return Center(
        child: Text(
          l.podcastEmpty,
          style: const TextStyle(color: AppTheme.navy, fontSize: 24),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: filteredPodcasts.length,
      itemBuilder: (context, index) {
        final podcast = filteredPodcasts[index];
        return _buildPodcastTile(podcast, l);
      },
    );
  }

  Widget _buildPodcastTile(Podcast podcast, AppLocalizations l) {
    final isArabicName = RegExp(r'[\u0600-\u06FF]').hasMatch(podcast.name);
    final isArabicDesc = RegExp(r'[\u0600-\u06FF]').hasMatch(podcast.description);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SmartPodcastPlayer(podcast: podcast),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cream,
              border: Border.all(color: AppTheme.darkTeal, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  podcast.name,
                  locale: isArabicName ? const Locale('ar') : null,
                  style: const TextStyle(
                    color: AppTheme.navy,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  podcast.description,
                  locale: isArabicDesc ? const Locale('ar') : null,
                  style: const TextStyle(color: AppTheme.darkTeal, fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
