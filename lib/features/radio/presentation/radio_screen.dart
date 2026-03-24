import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/radio_emission.dart';
import 'state/radio_cubit.dart';
import 'state/radio_state.dart';
import 'smart_radio_player.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../core/audio/audio_session_manager.dart';
import '../../../../injection_container.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<RadioCubit>().loadEmissions();
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
            l.radioTitle,
            style: const TextStyle(color: Colors.amberAccent, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.amberAccent),
      ),
      body: Column(
        children: [
          _buildAccessibleSearchBar(l),
          Expanded(
            child: BlocConsumer<RadioCubit, RadioState>(
              listener: (context, state) async {
                final tts = locator<TtsService>();
                final audio = locator<AudioSessionManager>();
                if (state is RadioLoading) {
                  await audio.requestExclusiveFocus();
                  await tts.speak(l.radioLoading);
                  await audio.releaseFocus();
                } else if (state is RadioLoaded) {
                  await audio.requestExclusiveFocus();
                  await tts.speak(l.radioCountTts(state.emissions.length));
                  await audio.releaseFocus();
                } else if (state is RadioError) {
                  await audio.requestExclusiveFocus();
                  await tts.speak(l.radioErrorTts);
                  await audio.releaseFocus();
                }
              },
              builder: (context, state) {
                if (state is RadioLoading || state is RadioInitial) {
                  return Center(
                    child: Semantics(
                      label: l.radioLoading,
                      child: const CircularProgressIndicator(color: Colors.amberAccent),
                    ),
                  );
                } else if (state is RadioError) {
                  return Center(
                    child: Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  );
                } else if (state is RadioLoaded) {
                  return _buildEmissionList(state.emissions, l);
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
        label: l.radioSearchLabel,
        hint: l.radioSearchHint,
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
            fillColor: Colors.amberAccent,
            hintText: l.radioSearchPlaceholder,
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

  Widget _buildEmissionList(List<RadioEmission> allEmissions, AppLocalizations l) {
    final filteredEmissions = allEmissions.where((emission) {
      return emission.title.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredEmissions.isEmpty) {
      return Center(
        child: Text(
          l.radioEmpty,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: filteredEmissions.length,
      itemBuilder: (context, index) {
        final emission = filteredEmissions[index];
        return _buildEmissionTile(emission, l);
      },
    );
  }

  Widget _buildEmissionTile(RadioEmission emission, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Semantics(
        button: true,
        label: l.radioTileSemantics(emission.title, emission.description),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SmartRadioPlayer(emission: emission),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emission.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  emission.description,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                  ),
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
