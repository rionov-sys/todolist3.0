import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/category_visuals.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/task.dart';
import '../../state/task_provider.dart';
import '../widgets/app_toast.dart';

/// Opens the add/edit form. Returns the [ActionResult] of the save, or null
/// when the user dismisses the sheet.
Future<ActionResult?> showAddTaskSheet(
  BuildContext context, {
  Task? task,
}) {
  return showModalBottomSheet<ActionResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext sheetContext) =>
        AddTaskSheet(editing: task, sheetContext: sheetContext),
  );
}

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({
    super.key,
    required this.sheetContext,
    this.editing,
  });

  /// Context of the bottom-sheet route (used to pop with a result).
  final BuildContext sheetContext;
  final Task? editing;

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController =
      TextEditingController(text: widget.editing?.title);
  late final TextEditingController _descController =
      TextEditingController(text: widget.editing?.description);

  late TaskCategory _category =
      widget.editing?.category ?? TaskCategory.wireframe;
  late final TaskStatus _status = widget.editing?.status ?? TaskStatus.todo;
  late DateTime _date = widget.editing?.date ?? DateTime.now();
  late String _time = widget.editing?.time ?? '09:00';
  late int _estimate = widget.editing?.estimateMinutes ?? 45;
  late bool _priority = widget.editing?.highPriority ?? false;
  bool _saving = false;

  static const List<int> _estimateOptions = <int>[15, 30, 45, 60, 90, 120];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_time.split(':').first),
        minute: int.parse(_time.split(':').last),
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _time = '${picked.hour.toString().padLeft(2, '0')}:'
            '${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final TaskProvider provider = context.read<TaskProvider>();
    final ActionResult result;
    if (widget.editing != null) {
      result = await provider.updateTask(
        widget.editing!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          category: _category,
          status: _status,
          date: _date,
          time: _time,
          estimateMinutes: _estimate,
          highPriority: _priority,
        ),
      );
    } else {
      result = await provider.addTask(
        title: _titleController.text,
        description: _descController.text,
        category: _category,
        status: _status,
        date: _date,
        time: _time,
        estimateMinutes: _estimate,
        highPriority: _priority,
      );
    }

    if (!mounted) return;
    if (result.isFailure) {
      setState(() => _saving = false);
      AppSnack.show(
        context,
        result.message ?? 'Gagal menyimpan tugas.',
        error: true,
      );
      return;
    }
    if (widget.sheetContext.mounted) {
      Navigator.of(widget.sheetContext).pop(result);
    }
  }

  String get _dateLabel => Formatters.relativeDay(_date);

  String get _timeLabel => Formatters.time(_time);

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.editing != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Form(
          key: _formKey,
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
              Row(
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_rounded : Icons.add_task_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEdit ? 'Ubah Tugas' : 'Tambah Tugas Baru',
                      style: AppTypography.headlineSm,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(widget.sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.bodyLg,
                cursorColor: AppColors.primary,
                decoration: const InputDecoration(
                  labelText: 'Judul tugas',
                  hintText: 'Mis. Wireframing Halaman Checkout',
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tugas wajib diisi.';
                  }
                  if (value.trim().length < 3) {
                    return 'Judul minimal 3 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                minLines: 2,
                style: AppTypography.bodyMd,
                cursorColor: AppColors.primary,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Jelaskan singkat apa yang harus dikerjakan…',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'KATEGORI',
                style: AppTypography.eyebrow(AppColors.outline),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TaskCategory.values.map((TaskCategory category) {
                  final CategoryVisuals visuals =
                      CategoryVisualsRegistry.of(category.visualsKey);
                  final bool active = category == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? visuals.fixed
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: active ? visuals.strong : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(visuals.emoji,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            visuals.shortLabel,
                            style: AppTypography.labelMd.copyWith(
                              color: active
                                  ? visuals.strong
                                  : AppColors.onSurfaceVariant,
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SheetIconButton(
                      icon: Icons.calendar_today_rounded,
                      label: _dateLabel,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SheetIconButton(
                      icon: Icons.schedule_rounded,
                      label: _timeLabel,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'ESTIMASI WAKTU',
                style: AppTypography.eyebrow(AppColors.outline),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _estimateOptions.map((int minutes) {
                  final bool active = minutes == _estimate;
                  return GestureDetector(
                    onTap: () => setState(() => _estimate = minutes),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        Formatters.estimate(minutes)
                            .replaceFirst('Estimasi ', ''),
                        style: AppTypography.labelMd.copyWith(
                          color: active
                              ? AppColors.onPrimary
                              : AppColors.onSurfaceVariant,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                value: _priority,
                onChanged: (bool value) =>
                    setState(() => _priority = value),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Prioritas tinggi',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Tampil sebagai kartu sorotan di timeline.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Icon(
                          isEdit ? Icons.save_rounded : Icons.add_rounded,
                          size: 20,
                        ),
                  label: Text(
                    _saving
                        ? 'Menyimpan…'
                        : (isEdit ? 'Simpan Perubahan' : 'Tambah Tugas'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetIconButton extends StatelessWidget {
  const _SheetIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}