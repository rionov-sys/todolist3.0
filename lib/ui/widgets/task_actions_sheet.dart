import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/task.dart';
import '../../state/task_provider.dart';
import 'app_toast.dart';

/// Bottom sheet with the quick actions mocked behind the `more_horiz` button:
/// toggle completion, edit, or delete (with confirmation).
Future<void> showTaskActionsSheet(
  BuildContext context,
  Task task, {
  required TaskProvider provider,
  required VoidCallback onEdit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineSm.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                task.tag ?? 'Tugas',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: task.isDone
                    ? Icons.undo_rounded
                    : Icons.check_circle_rounded,
                label: task.isDone ? 'Buka kembali' : 'Tandai selesai',
                color: AppColors.primary,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final ActionResult result =
                      await provider.toggleDone(task);
                  if (!context.mounted) return;
                  _feedback(
                    context,
                    result,
                    success: task.isDone
                        ? 'Tugas dibuka kembali.'
                        : 'Tugas selesai! +${task.points} Poin Produktif 🔥',
                  );
                },
              ),
              _ActionTile(
                icon: Icons.edit_rounded,
                label: 'Ubah tugas',
                color: AppColors.secondary,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onEdit();
                },
              ),
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                label: 'Hapus tugas',
                color: AppColors.error,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _confirmDelete(context, task, provider);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _feedback(
  BuildContext context,
  ActionResult result, {
  required String success,
}) {
  if (result.isFailure) {
    AppSnack.show(context, result.message ?? 'Gagal memperbarui tugas.',
        error: true);
  } else if (result.outcome == MutationOutcome.successOffline) {
    AppSnack.show(context, 'Tersimpan offline — akan disinkronkan otomatis.');
  } else {
    AppToast.show(context, success);
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  Task task,
  TaskProvider provider,
) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Hapus tugas?'),
      content: Text(
        '"${task.title}" akan dihapus permanen.',
        style: AppTypography.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.onError,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final ActionResult result = await provider.deleteTask(task);
  if (!context.mounted) return;
  if (result.isFailure) {
    AppSnack.show(context, result.message ?? 'Gagal menghapus tugas.',
        error: true);
  } else {
    AppSnack.show(context, 'Tugas dihapus.');
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 21, color: color),
      ),
      title: Text(
        label,
        style: AppTypography.labelLg.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.outline,
      ),
    );
  }
}