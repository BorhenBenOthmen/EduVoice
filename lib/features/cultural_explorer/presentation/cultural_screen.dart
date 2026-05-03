import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/culture_record.dart';
import 'state/culture_cubit.dart';
import 'state/culture_state.dart';
import 'cultural_player.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../injection_container.dart';
import '../../../../core/theme/app_theme.dart';

class CultureScreen extends StatefulWidget {
  /// Optional pre-filtered data from the AI voice command.
  final dynamic initialPayload;

  const CultureScreen({super.key, this.initialPayload});

  @override
  State<CultureScreen> createState() => _CultureScreenState();
}

class _CultureScreenState extends State<CultureScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CultureCubit>();
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
      cubit.loadCultureRecords();
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
            l.cultureTitle,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.cream),
      ),
      body: Column(
        children: [
          _buildAccessibleSearchBar(l),
          Expanded(
            child: BlocConsumer<CultureCubit, CultureState>(
              listener: (context, state) async {
                final tts = locator<TtsService>();
                if (state is CultureLoading) {
                  await tts.speak(l.cultureLoading);
                } else if (state is CultureLoaded) {
                  await tts.speak(l.cultureCountTts(state.records.length));
                } else if (state is CultureError) {
                  await tts.speak(l.cultureErrorTts);
                }
              },
              builder: (context, state) {
                if (state is CultureLoading || state is CultureInitial) {
                  return Center(
                    child: Semantics(
                      label: l.cultureLoading,
                      child: const CircularProgressIndicator(
                        color: AppTheme.darkTeal,
                      ),
                    ),
                  );
                } else if (state is CultureError) {
                  return Center(
                    child: Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: AppTheme.navy, fontSize: 20),
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
            hintText: l.cultureSearchPlaceholder,
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

  Widget _buildRecordList(List<CultureRecord> allRecords, AppLocalizations l) {
    final filteredRecords = allRecords.where((record) {
      return record.name.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredRecords.isEmpty) {
      return Center(
        child: Text(
          l.cultureEmpty,
          style: const TextStyle(color: AppTheme.navy, fontSize: 24),
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
    final isArabicDesc = RegExp(
      r'[\u0600-\u06FF]',
    ).hasMatch(record.description);

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
              color: AppTheme.cream, // High contrast touch target
              border: Border.all(color: AppTheme.darkTeal, width: 2),
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
                    color: AppTheme.navy,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  record.description,
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
