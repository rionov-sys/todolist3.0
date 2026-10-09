import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/task_stats.dart';
import '../../state/task_provider.dart';
import '../widgets/analytics_widgets.dart';
import '../widgets/app_toast.dart';
import '../widgets/donut_chart.dart';
import '../widgets/feedback_views.dart';
import '../widgets/shimmer.dart';
import '../widgets/weekly_bar_chart.dart';

/// Statistics dashboard: weekly hero with donut, metric triad, bar chart,
/// category breakdown and motivation banner.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskProvider provider = context.watch<TaskProvider>();

    if (provider.isLoading) return const _AnalyticsSkeleton();
    if (provider.hasFatalError) {
      return ErrorStateView(
        message: provider.loadError ?? 'Tidak dapat memuat statistik.',
        onRetry: provider.load,
      );
    }

    final TaskStats stats = provider.stats;

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Statistik & Progres',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Progres Mingguan',
                          style: AppTypography.headlineLg.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreakBadge(days: stats.streakDays),
                ],
              ),
              const SizedBox(height: 16),
              _HeroCard(stats: stats),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  MetricCard(
                    label: 'Selesai',
                    value: '${stats.done}',
                    icon: Icons.task_alt_rounded,
                    fill: AppColors.primaryFixed,
                    foreground: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  MetricCard(
                    label: 'Berjalan',
                    value: '${stats.inProgress}',
                    icon: Icons.timelapse_rounded,
                    fill: AppColors.secondaryFixed,
                    foreground: AppColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  MetricCard(
                    label: 'Tertunda',
                    value: '${stats.overdue}',
                    icon: Icons.pending_actions_rounded,
                    fill: AppColors.tertiaryFixed,
                    foreground: AppColors.tertiary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _WeeklyCard(stats: stats),
              const SizedBox(height: 20),
              _CategorySection(stats: stats),
              const SizedBox(height: 16),
              _MotivationBanner(percent: _overallPercent(stats)),
            ],
          ),
        ),
      ),
    );
  }

  static int _overallPercent(TaskStats stats) =>
      stats.total == 0 ? 0 : (stats.done * 100 / stats.total).round();
}

/// Weekly completion hero card with donut chart and legend.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.stats});

  final TaskStats stats;

  @override
  Widget build(BuildContext context) {
    final double total = stats.total == 0 ? 1 : stats.total.toDouble();
    final double doneFraction = stats.done / total;
    final double progressFraction = stats.inProgress / total;
    final int percent = (doneFraction * 100).round();
    final bool hasBaseline = stats.lastWeekPercent > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.trending_up_rounded,
                            size: 14,
                            color: AppColors.onPrimaryFixedVariant,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            hasBaseline
                                ? '${stats.trend >= 0 ? '+' : ''}${stats.trend}% dr minggu lalu'
                                : 'Baru minggu ini',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.onPrimaryFixed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$percent% Selesai',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stats.weekTotal == 0
                          ? 'Belum ada target minggu ini. Ayo mulai kerjakan tugasmu!'
                          : 'Luar biasa! ${stats.weekDone} dari ${stats.weekTotal} '
                              'target mingguanmu berhasil tercapai tepat waktu.',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    DonutChart(
                      doneFraction: doneFraction,
                      progressFraction: progressFraction,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '$percent',
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          '%',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                _LegendDot(
                  color: AppColors.primaryContainer,
                  label: 'Selesai (${stats.done})',
                ),
                const SizedBox(width: 16),
                _LegendDot(
                  color: AppColors.secondaryContainer,
                  label: 'Progres (${stats.inProgress})',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// "Target Mingguan" card with the seven-day bar chart.
class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.stats});

  final TaskStats stats;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final int todayIndex = (now.weekday - 1) % 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Target Mingguan',
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 16.5,
                ),
              ),
              const Spacer(),
              Text(
                'TUGAS SELESAI / HARI',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.outline,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          WeeklyBarChart(
            values: stats.weekSeries,
            todayIndex: todayIndex,
          ),
        ],
      ),
    );
  }
}

/// "Kategori Paling Produktif" header + rows (or an empty note).
class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.stats});

  final TaskStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Kategori Paling Produktif',
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => AppSnack.show(
                context,
                'Halaman rincian akan segera hadir.',
              ),
              child: Text(
                'Rincian',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (stats.categoryStats.isEmpty)
          const EmptyStateView(
            compact: true,
            icon: Icons.pie_chart_outline_rounded,
            title: 'Belum ada data kategori',
            message: 'Selesaikan tugas untuk melihat rincian kategori.',
          )
        else
          Column(
            children: <Widget>[
              for (int i = 0; i < stats.categoryStats.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: 10),
                CategoryProgressRow(
                  category: stats.categoryStats[i].category,
                  doneCount: stats.categoryStats[i].doneCount,
                  share: stats.categoryStats[i].share,
                ),
              ],
            ],
          ),
      ],
    );
  }
}

/// High-energy gradient banner closing the analytics screen.
class _MotivationBanner extends StatelessWidget {
  const _MotivationBanner({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final String title = percent >= 70
        ? 'Ritme Kerja Solid!'
        : percent >= 40
            ? 'Terus Naik Level!'
            : 'Mulai dari Satu Tugas';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            AppColors.primaryContainer,
            AppColors.primary,
            AppColors.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withValues(alpha: 0.24),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('💪', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Kamu sudah menyelesaikan $percent% target. '
                  'Terus pertahankan ritmemu, Keep Grinding!',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onPrimaryContainer,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the analytics screen during the first load.
class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: const <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ShimmerBox(width: 110, height: 12),
                      SizedBox(height: 8),
                      ShimmerBox(width: 190, height: 24),
                    ],
                  ),
                ),
                ShimmerBox(width: 110, height: 30, radius: 15),
              ],
            ),
            SizedBox(height: 16),
            ShimmerBox(height: 170, radius: 20),
            SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(child: ShimmerBox(height: 130, radius: 16)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(height: 130, radius: 16)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(height: 130, radius: 16)),
              ],
            ),
            SizedBox(height: 14),
            ShimmerBox(height: 170, radius: 20),
            SizedBox(height: 20),
            ShimmerBox(width: 220, height: 20),
            SizedBox(height: 12),
            ShimmerBox(height: 68, radius: 16),
            SizedBox(height: 10),
            ShimmerBox(height: 68, radius: 16),
            SizedBox(height: 16),
            ShimmerBox(height: 92, radius: 20),
          ],
        ),
      ),
    );
  }
}