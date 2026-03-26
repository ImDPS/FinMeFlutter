// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_import_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(smsImportRepository)
final smsImportRepositoryProvider = SmsImportRepositoryProvider._();

final class SmsImportRepositoryProvider extends $FunctionalProvider<
    SmsImportRepository,
    SmsImportRepository,
    SmsImportRepository> with $Provider<SmsImportRepository> {
  SmsImportRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'smsImportRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$smsImportRepositoryHash();

  @$internal
  @override
  $ProviderElement<SmsImportRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SmsImportRepository create(Ref ref) {
    return smsImportRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmsImportRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmsImportRepository>(value),
    );
  }
}

String _$smsImportRepositoryHash() =>
    r'24843bf133b22012a9d5b2da2879923c712c8071';

@ProviderFor(SmsImportNotifier)
final smsImportProvider = SmsImportNotifierProvider._();

final class SmsImportNotifierProvider
    extends $NotifierProvider<SmsImportNotifier, SmsImportState> {
  SmsImportNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'smsImportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$smsImportNotifierHash();

  @$internal
  @override
  SmsImportNotifier create() => SmsImportNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmsImportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmsImportState>(value),
    );
  }
}

String _$smsImportNotifierHash() => r'53a20774bc3d776c6d40da8f94c701a2f74fc3ab';

abstract class _$SmsImportNotifier extends $Notifier<SmsImportState> {
  SmsImportState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SmsImportState, SmsImportState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SmsImportState, SmsImportState>,
        SmsImportState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
