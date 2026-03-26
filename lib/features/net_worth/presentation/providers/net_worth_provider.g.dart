// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(netWorthRepository)
final netWorthRepositoryProvider = NetWorthRepositoryProvider._();

final class NetWorthRepositoryProvider extends $FunctionalProvider<
    NetWorthRepository,
    NetWorthRepository,
    NetWorthRepository> with $Provider<NetWorthRepository> {
  NetWorthRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'netWorthRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$netWorthRepositoryHash();

  @$internal
  @override
  $ProviderElement<NetWorthRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NetWorthRepository create(Ref ref) {
    return netWorthRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetWorthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetWorthRepository>(value),
    );
  }
}

String _$netWorthRepositoryHash() =>
    r'27ce67f62000b908ff31ffc47fe86a68189620bc';

@ProviderFor(NetWorthNotifier)
final netWorthProvider = NetWorthNotifierProvider._();

final class NetWorthNotifierProvider
    extends $NotifierProvider<NetWorthNotifier, NetWorthState> {
  NetWorthNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'netWorthProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$netWorthNotifierHash();

  @$internal
  @override
  NetWorthNotifier create() => NetWorthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetWorthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetWorthState>(value),
    );
  }
}

String _$netWorthNotifierHash() => r'bbb49021a1b16084892a00523a451e268ca37559';

abstract class _$NetWorthNotifier extends $Notifier<NetWorthState> {
  NetWorthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NetWorthState, NetWorthState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<NetWorthState, NetWorthState>,
        NetWorthState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
