import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/podcast.dart';
import 'state/podcast_cubit.dart';
import 'state/podcast_state.dart';
import 'smart_podcast_player.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../injection_container.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<PodcastCubit>().loadPodcasts();
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Semantics(
          header: true,
          child: Text(
            l.podcastTitle,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
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
                        color: Colors.cyanAccent,
                      ),
                    ),
                  );
                } else if (state is PodcastError) {
                  return Center(
                    child: Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
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
          style: const TextStyle(color: Colors.black, fontSize: 22),
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.cyanAccent,
            hintText: l.podcastSearchPlaceholder,
            hintStyle: const TextStyle(color: Colors.black54),
            prefixIcon: const Icon(Icons.search, color: Colors.black, size: 32),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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
          style: const TextStyle(color: Colors.white, fontSize: 24),
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
              color: Colors.cyanAccent,
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
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  podcast.description,
                  locale: isArabicDesc ? const Locale('ar') : null,
                  style: const TextStyle(color: Colors.black87, fontSize: 20),
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
