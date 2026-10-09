import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/category_visuals.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/task.dart';
import '../../state/task_provider.dart';
import '../screens/add_task_sheet.dart';
import '../widgets/app_toast.dart';
import '../widgets/featured_task_card.dart';
import '../widgets/feedback_views.dart';
import '../widgets/micro_animations.dart';
import '../widgets/search_field.dart';
import '../widgets/shimmer.dart';
import '../widgets/status_node.dart';
import '../widgets/task_row.dart';

/// Tasks home: greeting, search, status nodes, featured carousel,
/// pomodoro banner and the priority activity list.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTimeline});

  final VoidCallback onOpenTimeline;

  Future<void> _openAddSheet(BuildContext context, {Task? task}) async {
    final ActionResult? result = await showAddTaskSheet(context, task: task);
    if (result == null || !context.mounted) return;
    if (result.outcome == MutationOutcome.successOffline) {
      AppSnack.show(context, 'Tersimpan offline — akan disinkronkan otomatis.');
    } else {
      AppToast.show(
        context,
        task != null ? 'Perubahan tersimpan.' : 'Tugas ditambahkan! 🎉',
        icon: Icons.check_circle_rounded,
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
        'Tugas selesai! +${task.points} Poin Produktif 🔥',
        icon: Icons.celebration_rounded,
      );
    } else {
      AppToast.show(context, 'Tugas dibuka kembali.',
          icon: Icons.undo_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TaskProvider provider = context.watch<TaskProvider>();

    if (provider.isLoading) return const _HomeSkeleton();
    if (provider.hasFatalError) {
      return ErrorStateView(
        message: provider.loadError ?? 'Tidak dapat memuat data tugas.',
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
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
            children: <Widget>[
              _GreetingSection(provider: provider),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: SearchField(
                  onChanged: provider.setSearchQuery,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatusNodes(provider: provider),
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Tugas Hari Ini',
                count: provider.todayTasks.length,
                actionLabel: 'Lihat Semua',
                onAction: onOpenTimeline,
              ),
              _FeaturedCarousel(
                provider: provider,
                onToggle: (Task task) => _toggle(context, provider, task),
                onOpen: (Task task) => _openAddSheet(context, task: task),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _PomodoroBanner(),
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Aktivitas Prioritas',
                caption: 'HARI INI',
              ),
              _PriorityList(
                provider: provider,
                context: context,
                onToggle: (Task task) => _toggle(context, provider, task),
                onOpen: (Task task) => _openAddSheet(context, task: task),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FilledButton.icon(
                  onPressed: () => _openAddSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text('Tambah Tugas Baru'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Ringkasan Harian" eyebrow, pulsing Aktif badge and greeting headline.
class _GreetingSection extends StatelessWidget {
  const _GreetingSection({required this.provider});

  final TaskProvider provider;

  @override
  Widget build(BuildContext context) {
    final int monthCount = provider.monthTaskCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'RINGKASAN HARIAN',
                style: AppTypography.eyebrow(AppColors.outline),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: AppShadows.soft,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const PulsingDot(color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Aktif',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onPrimaryFixed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${Formatters.greeting(DateTime.now())}, ${AppConfig.userName}!',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          Text.rich(
            TextSpan(
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
              children: <InlineSpan>[
                const TextSpan(text: 'Kamu memiliki '),
                TextSpan(
                  text: '$monthCount tugas',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryFixed,
                    decorationThickness: 3,
                    fontSize: 19,
                  ),
                ),
                const TextSpan(text: ' bulan ini 👍'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Row of the three status filter nodes.
class _StatusNodes extends StatelessWidget {
  const _StatusNodes({required this.provider});

  final TaskProvider provider;

  @override
  Widget build(BuildContext context) {
    final Map<TaskStatus, int> counts = provider.statusCounts;

    return Row(
      children: <Widget>[
        StatusNode(
          visuals: StatusVisualsRegistry.todo,
          count: counts[TaskStatus.todo] ?? 0,
          selected: provider.homeStatusFilter == TaskStatus.todo,
          onTap: () => provider.toggleHomeStatusFilter(TaskStatus.todo),
        ),
        const SizedBox(width: 10),
        StatusNode(
          visuals: StatusVisualsRegistry.inProgress,
          count: counts[TaskStatus.inProgress] ?? 0,
          selected: provider.homeStatusFilter == TaskStatus.inProgress,
          onTap: () => provider.toggleHomeStatusFilter(TaskStatus.inProgress),
        ),
        const SizedBox(width: 10),
        StatusNode(
          visuals: StatusVisualsRegistry.done,
          count: counts[TaskStatus.done] ?? 0,
          selected: provider.homeStatusFilter == TaskStatus.done,
          onTap: () => provider.toggleHomeStatusFilter(TaskStatus.done),
        ),
      ],
    );
  }
}

/// Section title with optional count badge and trailing action.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.count,
    this.caption,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final int? count;
  final String? caption;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(21, 0, 20, 10),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface),
          ),
          if (count != null) ...<Widget>[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (caption != null)
            Text(
              caption!,
              style: AppTypography.labelSm.copyWith(
                color: AppColors.outline,
                letterSpacing: 1.2,
              ),
            )
          else if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    actionLabel!,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Horizontal carousel of today's highlighted tasks.
class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel({
    required this.provider,
    required this.onToggle,
    required this.onOpen,
  });

  final TaskProvider provider;
  final void Function(Task) onToggle;
  final void Function(Task) onOpen;

  @override
  Widget build(BuildContext context) {
    final List<Task> featured = provider.featuredTasks;
    if (featured.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: EmptyStateView(
          compact: true,
          icon: Icons.event_available_rounded,
          title: 'Belum ada tugas hari ini',
          message: 'Tambahkan tugas pertamamu untuk mulai bergrinding!',
        ),
      );
    }

    return SizedBox(
      height: 244,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: featured.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (BuildContext context, int index) {
          final Task task = featured[index];
          return FeaturedTaskCard(
            task: task,
            onToggle: () => onToggle(task),
            onOpen: () => onOpen(task),
          );
        },
      ),
    );
  }
}

/// "Fokus Cepat (Pomodoro)" quick action banner.
class _PomodoroBanner extends StatelessWidget {
  const _PomodoroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt_rounded,
              size: 20,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Fokus Cepat (Pomodoro)',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Sesi 25 menit berikutnya',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {
              AppToast.show(
                context,
                'Sesi Pomodoro 25 menit dimulai — tetap fokus! 💪',
                icon: Icons.timer_rounded,
              );
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: const Text('Mulai'),
          ),
        ],
      ),
    );
  }
}

/// "Aktivitas Prioritas" rows honouring the search + status filters.
class _PriorityList extends StatelessWidget {
  const _PriorityList({
    required this.provider,
    required this.context,
    required this.onToggle,
    required this.onOpen,
  });

  final TaskProvider provider;
  final BuildContext context;
  final void Function(Task) onToggle;
  final void Function(Task) onOpen;

  @override
  Widget build(BuildContext builderContext) {
    final List<Task> tasks = provider.homePriorityTasks;

    if (tasks.isEmpty) {
      if (provider.hasActiveHomeFilter) {
        return EmptyStateView(
          compact: true,
          icon: Icons.search_off_rounded,
          title: 'Tidak ada tugas yang cocok',
          message: 'Coba ubah kata kunci atau reset filter statusmu.',
          actionLabel: 'Reset Filter',
          onAction: provider.clearHomeFilter,
        );
      }
      return const EmptyStateView(
        compact: true,
        icon: Icons.assignment_turned_in_outlined,
        title: 'Belum ada aktivitas hari ini',
        message: 'Santai dulu atau tambah tugas baru untuk hari ini.',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < tasks.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 12),
            TaskRow(
              task: tasks[i],
              index: i,
              onToggle: () => onToggle(tasks[i]),
              onTap: () => onOpen(tasks[i]),
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton shown while the first load runs.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: const <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ShimmerBox(width: 130, height: 12),
                ShimmerBox(width: 60, height: 22, radius: 11),
              ],
            ),
            SizedBox(height: 14),
            ShimmerBox(width: 210, height: 24),
            SizedBox(height: 8),
            ShimmerBox(width: 260, height: 18),
            SizedBox(height: 18),
            ShimmerBox(height: 50, radius: 25),
            SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(child: ShimmerBox(height: 118, radius: 16)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(height: 118, radius: 16)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(height: 118, radius: 16)),
              ],
            ),
            SizedBox(height: 24),
            ShimmerBox(width: 150, height: 18),
            SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(child: ShimmerBox(height: 240, radius: 24)),
                SizedBox(width: 14),
                Expanded(child: ShimmerBox(height: 240, radius: 24)),
              ],
            ),
            SizedBox(height: 24),
            ShimmerTaskRow(),
            SizedBox(height: 12),
            ShimmerTaskRow(),
            SizedBox(height: 12),
            ShimmerTaskRow(),
          ],
        ),
      ),
    );
  }
}