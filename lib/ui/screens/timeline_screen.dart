import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/task.dart';
import '../../state/task_provider.dart';
import '../screens/add_task_sheet.dart';
import '../widgets/app_toast.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/feedback_views.dart';
import '../widgets/segmented_status_filter.dart';
import '../widgets/shimmer.dart';
import '../widgets/task_actions_sheet.dart';
import '../widgets/timeline_tile.dart';
import '../widgets/week_strip.dart';

/// Schedule timeline: week strip, status/category filters and the connected
/// timeline feed with status-tinted cards.
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  Future<void> _openAddSheet(BuildContext context, {Task? task}) async {
    final ActionResult? result = await showAddTaskSheet(context, task: task);
    if (result == null || !context.mounted) return;
    if (result.outcome == MutationOutcome.successOffline) {
      AppSnack.show(context, 'Tersimpan offline — akan disinkronkan otomatis.');
    } else {
      AppToast.show(
        context,
        task != null
            ? 'Perubahan tersimpan.'
            : 'Jadwal tugas siap diselaraskan!',
        icon: Icons.task_alt_rounded,
      );
    }
  }

  static Future<void> _toggle(
    BuildContext context,
    TaskProvider provider,
    Task task,
  ) async {
    final ActionResult result = await provider.toggleDone(task);
    if (!context.mounted) return;
    if (result.isFailure) {
      AppSnack.show(
        context,
        result.message ?? 'Gagal memperbarui tugas.',
        error: true,
      );
      return;
    }
    if (!task.isDone) {
      AppToast.show(
        context,
        'Tugas timeline selesai! +${task.points} Poin Produktif 🔥',
        icon: Icons.celebration_rounded,
      );
    } else {
      AppToast.show(context, 'Tugas dibuka kembali.', icon: Icons.undo_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TaskProvider provider = context.watch<TaskProvider>();

    if (provider.isLoading) return const _TimelineSkeleton();
    if (provider.hasFatalError) {
      return ErrorStateView(
        message: provider.loadError ?? 'Tidak dapat memuat jadwal.',
        onRetry: provider.load,
      );
    }

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
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: <Widget>[
              _TopActionRow(provider: provider, onBack: onBack, onAdd: () => _openAddSheet(context)),
              const SizedBox(height: 14),
              WeekStrip(
                selected: provider.selectedDate,
                onSelected: provider.selectDate,
                onWeekShift: provider.shiftWeek,
              ),
              const SizedBox(height: 14),
              SegmentedStatusFilter(
                counts: provider.timelineStatusCounts,
                value: provider.timelineStatusFilter,
                onChanged: provider.setTimelineStatusFilter,
              ),
              const SizedBox(height: 12),
              CategoryFilterBar(
                counts: provider.timelineCategoryCounts,
                selected: provider.timelineCategoryFilter,
                onSelected: provider.setTimelineCategoryFilter,
              ),
              const SizedBox(height: 16),
              _TimelineFeed(
                provider: provider,
                onToggle: (Task task) => _toggle(context, provider, task),
                onMore: (Task task) =>
                    _openTaskActions(context, provider, task),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTaskActions(
    BuildContext context,
    TaskProvider provider,
    Task task,
  ) {
    return showTaskActionsSheet(
      context,
      task,
      provider: provider,
      onEdit: () => _openAddSheet(context, task: task),
    );
  }
}

/// Back button, month pill and "Tambah" pill button.
class _TopActionRow extends StatelessWidget {
  const _TopActionRow({
    required this.provider,
    required this.onBack,
    required this.onAdd,
  });

  final TaskProvider provider;
  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _RoundIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                Formatters.monthYear(provider.selectedDate),
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        FilledButton(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.add_rounded, size: 19),
              SizedBox(width: 5),
              Text('Tambah'),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppShadows.soft,
          ),
          child: Icon(icon, size: 21, color: AppColors.onSurface),
        ),
      ),
    );
  }
}

/// Connected timeline feed (or the filtered-empty state from the mocks).
class _TimelineFeed extends StatelessWidget {
  const _TimelineFeed({
    required this.provider,
    required this.onToggle,
    required this.onMore,
  });

  final TaskProvider provider;
  final void Function(Task) onToggle;
  final void Function(Task) onMore;

  @override
  Widget build(BuildContext context) {
    final List<Task> tasks = provider.timelineTasks;

    if (tasks.isEmpty) {
      if (provider.hasActiveTimelineFilter) {
        return _EmptyFilterState(onReset: provider.resetTimelineFilters);
      }
      return const EmptyStateView(
        compact: true,
        icon: Icons.timeline_rounded,
        title: 'Belum ada jadwal',
        message:
            'Tidak ada tugas terjadwal di tanggal ini. Tambah tugas baru agar timelinemu terisi.',
      );
    }

    return Stack(
      children: <Widget>[
        Positioned(
          left: 12,
          top: 16,
          bottom: 16,
          width: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Column(
          children: <Widget>[
            for (int i = 0; i < tasks.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: 18),
              TimelineTile(
                task: tasks[i],
                index: i,
                onToggle: () => onToggle(tasks[i]),
                onMore: () => onMore(tasks[i]),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Notice shown when filters hide every task (mocked dashed empty state).
class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.7),
          width: 1.4,
        ),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.task_alt_rounded,
            size: 38,
            color: AppColors.outline,
          ),
          const SizedBox(height: 10),
          Text(
            'Tidak ada tugas',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Belum ada jadwal yang sesuai dengan filter yang dipilih.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.filter_alt_off_rounded, size: 17),
            label: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the timeline while the first load runs.
class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

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
            Row(
              children: <Widget>[
                ShimmerBox(width: 44, height: 44, radius: 22),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 36, radius: 18)),
                SizedBox(width: 12),
                ShimmerBox(width: 110, height: 44, radius: 22),
              ],
            ),
            SizedBox(height: 16),
            ShimmerBox(height: 84, radius: 16),
            SizedBox(height: 14),
            ShimmerBox(height: 46, radius: 23),
            SizedBox(height: 12),
            ShimmerBox(height: 38, radius: 19),
            SizedBox(height: 18),
            _SkeletonTimelineRow(),
            SizedBox(height: 18),
            _SkeletonTimelineRow(),
            SizedBox(height: 18),
            _SkeletonTimelineRow(),
          ],
        ),
      ),
    );
  }
}

class _SkeletonTimelineRow extends StatelessWidget {
  const _SkeletonTimelineRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ShimmerBox(width: 26, height: 26, radius: 13),
        SizedBox(width: 12),
        Expanded(
          child: ShimmerBox(height: 130, radius: 18),
        ),
      ],
    );
  }
}