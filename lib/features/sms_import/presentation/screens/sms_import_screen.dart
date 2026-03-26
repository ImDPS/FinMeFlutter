import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:telephony/telephony.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_text_styles.dart';
import 'package:finme/core/widgets/glass_card.dart';
import 'package:finme/features/sms_import/data/sms_import_repository.dart' as repo;
import 'package:finme/features/sms_import/presentation/providers/sms_import_provider.dart';

class SmsImportScreen extends ConsumerStatefulWidget {
  const SmsImportScreen({super.key});

  @override
  ConsumerState<SmsImportScreen> createState() => _SmsImportScreenState();
}

class _SmsImportScreenState extends ConsumerState<SmsImportScreen> {
  final Telephony _telephony = Telephony.instance;
  bool _permissionGranted = false;
  bool _checkingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await _telephony.requestSmsPermissions ?? false;
    if (mounted) {
      setState(() {
        _permissionGranted = granted;
        _checkingPermission = false;
      });
    }
  }

  Future<void> _startImport() async {
    if (!_permissionGranted) {
      await _checkPermission();
      if (!_permissionGranted) return;
    }

    final smsList = await _telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    final messages = smsList.map((sms) => repo.SmsMessage(
      sender: sms.address ?? '',
      body: sms.body ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0),
    )).toList();

    await ref.read(smsImportProvider.notifier).importSms(messages);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smsImportProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Import from SMS', style: AppTextStyles.heading)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.messageSquare, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Import bank transactions from SMS',
                          style: AppTextStyles.body,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'FinMe reads your SMS locally on-device to detect bank transactions. '
                    'No data is sent to any server. Duplicates are automatically skipped.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_checkingPermission)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else if (!_permissionGranted)
              GlassCard(
                child: Column(
                  children: [
                    Text(
                      'SMS permission is required to import transactions.',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkPermission,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('Grant Permission', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: state.status == SmsImportStatus.importing ? null : _startImport,
                  icon: state.status == SmsImportStatus.importing
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.download, color: Colors.white),
                  label: Text(
                    state.status == SmsImportStatus.importing ? 'Importing...' : 'Scan & Import SMS',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            if (state.status == SmsImportStatus.done)
              GlassCard(
                child: Row(
                  children: [
                    const Icon(LucideIcons.checkCircle, color: AppColors.success),
                    const SizedBox(width: 12),
                    Text(
                      '${state.importedCount} new transaction${state.importedCount == 1 ? '' : 's'} imported',
                      style: AppTextStyles.body.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ),

            if (state.status == SmsImportStatus.error)
              GlassCard(
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle, color: AppColors.danger),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.error ?? 'Import failed',
                        style: AppTextStyles.body.copyWith(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
