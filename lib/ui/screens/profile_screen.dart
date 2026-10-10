import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/task_stats.dart';
import '../../state/auth_provider.dart';
import '../../state/task_provider.dart';
import '../widgets/analytics_widgets.dart';
import '../widgets/app_toast.dart';
import '../widgets/feedback_views.dart';
import '../widgets/shimmer.dart';

/// User profile: identity card, lifetime stats, preferences and
/// synchronisation status (offline queue).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  bool _pomodoroReminders = true;

  @override
  Widget build(BuildContext context) {
    final TaskProvider provider = context.watch<TaskProvider>();
    final AuthProvider auth = context.watch<AuthProvider>();
    final String displayName =
        (auth.user?.name.isNotEmpty ?? false) ? auth.user!.name : AppConfig.userName;
    final String displayEmail =
        (auth.user?.email.isNotEmpty ?? false) ? auth.user!.email : 'rifat@keepgrinding.app';
    final String displayFocus =
        (auth.user?.focus.isNotEmpty ?? false) ? auth.user!.focus : 'Proyek Tim';
    if (provider.isLoading) return const _ProfileSkeleton();
    if (provider.hasFatalError) {
      return ErrorStateView(
        message: provider.loadError ?? 'Tidak dapat memuat profil.',
        onRetry: provider.load,
      );
    }
    final TaskStats stats = provider.stats;
    final bool offline = provider.isOffline;

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: <Widget>[
            // --- Identity card ------------------------------------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          AppColors.primaryFixedDim,
                          AppColors.primaryFixed,
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      displayName.isEmpty
                          ? '?'
                          : displayName.characters.first.toUpperCase(),
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.onPrimaryFixed,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          displayName,
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayEmail,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            "$displayFocus \u2022 ${stats.streakDays} Hari Beruntun",
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.onPrimaryFixed,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                MetricCard(
                  label: 'Total Tugas',
                  value: '${stats.total}',
                  icon: Icons.assignment_rounded,
                  fill: AppColors.surfaceContainerHigh,
                  foreground: AppColors.primary,
                ),
                const SizedBox(width: 10),
                MetricCard(
                  label: 'Selesai',
                  value: '${stats.done}',
                  icon: Icons.task_alt_rounded,
                  fill: AppColors.primaryFixed,
                  foreground: AppColors.primary,
                ),
                const SizedBox(width: 10),
                MetricCard(
                  label: 'Poin',
                  value: '${stats.points}',
                  icon: Icons.bolt_rounded,
                  fill: AppColors.secondaryFixed,
                  foreground: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('SINKRONISASI'),
            const SizedBox(height: 8),
            _settingsCard(
              children: <Widget>[
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: offline
                          ? AppColors.tertiaryFixed
                          : AppColors.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      offline
                          ? Icons.cloud_off_rounded
                          : Icons.cloud_done_rounded,
                      size: 20,
                      color: offline
                          ? AppColors.tertiary
                          : AppColors.primary,
                    ),
                  ),
                  title: Text(
                    offline ? 'Mode Offline' : 'Semua Data Tersinkron',
                  ),
                  subtitle: Text(
                    offline
                        ? provider.notice ??
                            'Perubahan tersimpan lokal dan akan disinkronkan otomatis.'
                        : provider.pendingSyncCount > 0
                            ? '${provider.pendingSyncCount} perubahan menunggu sinkron.'
                            : 'Perubahanmu aman dan terbaru.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                  trailing: provider.isRefreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          tooltip: 'Sinkronkan sekarang',
                          onPressed: () async {
                            await provider.refresh();
                            if (!context.mounted) return;
                            if (provider.isOffline) {
                              AppSnack.show(
                                context,
                                'Masih offline — sinkronisasi akan dicoba otomatis.',
                                error: true,
                              );
                            } else {
                              AppToast.show(
                                context,
                                'Sinkronisasi selesai.',
                                icon: Icons.cloud_done_rounded,
                              );
                            }
                          },
                          icon: const Icon(Icons.sync_rounded),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('PREFERENSI'),
            const SizedBox(height: 8),
            _settingsCard(
              children: <Widget>[
                SwitchListTile.adaptive(
                  value: _notifications,
                  onChanged: (bool value) {
                    setState(() => _notifications = value);
                    AppSnack.show(
                      context,
                      value
                          ? 'Notifikasi tugas diaktifkan.'
                          : 'Notifikasi tugas dimatikan.',
                    );
                  },
                  title: const Text('Notifikasi Tugas'),
                  subtitle: Text(
                    'Pengingat jadwal dan tenggat hariannya.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                SwitchListTile.adaptive(
                  value: _pomodoroReminders,
                  onChanged: (bool value) {
                    setState(() => _pomodoroReminders = value);
                    AppSnack.show(
                      context,
                      value
                          ? 'Pengingat Pomodoro diaktifkan.'
                          : 'Pengingat Pomodoro dimatikan.',
                    );
                  },
                  title: const Text('Pengingat Pomodoro'),
                  subtitle: Text(
                    'Getaran saat sesi fokus 25 menit selesai.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('TENTANG'),
            const SizedBox(height: 8),
            _settingsCard(
              children: <Widget>[
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text('${AppConfig.appName} v1.0.0'),
                  subtitle: Text(
                    'Offline-first task & schedule management.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: AppColors.error,
                    ),
                  ),
                  title: const Text('Keluar'),
                  subtitle: Text(
                    displayEmail,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async { await context.read<AuthProvider>().logout(); if (!context.mounted) return; AppToast.show(context, 'Kamu sudah keluar. Sampai jumpa!'); },
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(text, style: AppTypography.eyebrow(AppColors.outline)),
      );

  Widget _settingsCard({required List<Widget> children}) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.soft,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Column(children: children),
        ),
      );
}

/// Skeleton shown while the first load runs.
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: const <Widget>[
            ShimmerBox(height: 104, radius: 20),
            SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(child: ShimmerBox(height: 118, radius: 16)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(height: 118, radius: 16)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(height: 118, radius: 16)),
              ],
            ),
            SizedBox(height: 20),
            ShimmerBox(width: 120, height: 12),
            SizedBox(height: 8),
            ShimmerBox(height: 64, radius: 16),
            SizedBox(height: 20),
            ShimmerBox(width: 120, height: 12),
            SizedBox(height: 8),
            ShimmerBox(height: 124, radius: 16),
          ],
        ),
      ),
    );
  }
}
