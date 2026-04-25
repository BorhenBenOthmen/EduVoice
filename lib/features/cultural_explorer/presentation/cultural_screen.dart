import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/culture_record.dart';
import 'state/culture_cubit.dart';
import 'state/culture_state.dart';
import 'cultural_player.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../core/audio/audio_session_manager.dart';
import '../../../../injection_container.dart';

class CultureScreen extends StatefulWidget {
  const CultureScreen({super.key});

  @override
  State<CultureScreen> createState() => _CultureScreenState();
}

class _CultureScreenState extends State<CultureScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CultureCubit>().loadCultureRecords();
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
      backgroundColor: Colors.black, // Strict Accessibility: High Contrast
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Semantics(
          header: true,
          child: Text(
            l.cultureTitle,
            style: const TextStyle(
              color: Colors.lightGreenAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.lightGreenAccent),
      ),
      body: Column(
        children: [
          _buildAccessibleSearchBar(l),
          Expanded(
            child: BlocConsumer<CultureCubit, CultureState>(
              listener: (context, state) async {
                final tts = locator<TtsService>();
                final audio = locator<AudioSessionManager>();
                if (state is CultureLoading) {
                  await audio.requestExclusiveFocus();
                  await tts.speak(l.cultureLoading);
                  await audio.releaseFocus();
                } else if (state is CultureLoaded) {
                  await audio.requestExclusiveFocus();
                  await tts.speak(l.cultureCountTts(state.records.length));
                  await audio.releaseFocus();
                } else if (state is CultureError) {
                  await audio.requestExclusiveFocus();
                  await tts.speak(l.cultureErrorTts);
                  await audio.releaseFocus();
                }
              },
              builder: (context, state) {
                if (state is CultureLoading || state is CultureInitial) {
                  return Center(
                    child: Semantics(
                      label: l.cultureLoading,
                      child: const CircularProgressIndicator(
                        color: Colors.lightGreenAccent,
                      ),
                    ),
                  );
                } else if (state is CultureError) {
                  return Center(
                    child: Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  );
                } else if (state is CultureLoaded) {
                  return _buildRecordList(state.records, l);
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
        label: l.cultureSearchLabel,
        hint: l.cultureSearchHint,
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
            fillColor: Colors.lightGreenAccent,
            hintText: l.cultureSearchPlaceholder,
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

  Widget _buildRecordList(List<CultureRecord> allRecords, AppLocalizations l) {
    final filteredRecords = allRecords.where((record) {
      return record.name.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredRecords.isEmpty) {
      return Center(
        child: Text(
          l.cultureEmpty,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return _buildRecordTile(record, l);
      },
    );
  }

  Widget _buildRecordTile(CultureRecord record, AppLocalizations l) {
    final isArabicName = RegExp(r'[\u0600-\u06FF]').hasMatch(record.name);
    final isArabicDesc = RegExp(r'[\u0600-\u06FF]').hasMatch(record.description);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CulturePlayerScreen(record: record),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.lightGreenAccent, // High contrast touch target
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.name,
                  locale: isArabicName ? const Locale('ar') : null,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  record.description,
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
