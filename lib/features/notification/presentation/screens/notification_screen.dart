import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/audio/tts_service.dart';
import '../../../../injection_container.dart';
import '../state/notification_list_cubit.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationListCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tts = locator<TtsService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.notificationTitle),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: AppTheme.darkTeal, height: 2.0),
        ),
      ),
      body: BlocBuilder<NotificationListCubit, NotificationListState>(
        builder: (context, state) {
          if (state is NotificationListLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.darkTeal));
          } else if (state is NotificationListLoaded) {
            final notifications = state.notifications;
            
            if (notifications.isEmpty) {
              return Center(
                child: Text(
                  l.notificationEmpty,
                  style: const TextStyle(color: AppTheme.darkTeal, fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Semantics(
                  button: true,
                  onTapHint: l.notificationDeleteSemantics,
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppTheme.darkTeal, width: 1),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.notifications, color: AppTheme.navy, size: 32),
                      title: Text(
                        notif.note,
                        style: const TextStyle(color: AppTheme.navy, fontSize: 18),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          context.read<NotificationListCubit>().deleteNotification(notif.id);
                        },
                        tooltip: l.notificationDeleteSemantics,
                      ),
                      onTap: () {
                        // Just read the notification again when tapped
                        tts.speak(notif.note);
                      },
                    ),
                  ),
                );
              },
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
