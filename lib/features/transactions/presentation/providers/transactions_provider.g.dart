// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionsRepository)
final transactionsRepositoryProvider = TransactionsRepositoryProvider._();

final class TransactionsRepositoryProvider extends $FunctionalProvider<
    TransactionsRepository,
    TransactionsRepository,
    TransactionsRepository> with $Provider<TransactionsRepository> {
  TransactionsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionsRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionsRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TransactionsRepository create(Ref ref) {
    return transactionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionsRepository>(value),
    );
  }
}

String _$transactionsRepositoryHash() =>
    r'88573d3ba4e8fda938cb04fe181973170a62f24a';

@ProviderFor(TransactionsNotifier)
final transactionsProvider = TransactionsNotifierProvider._();

final class TransactionsNotifierProvider
    extends $AsyncNotifierProvider<TransactionsNotifier, TransactionList> {
  TransactionsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionsNotifierHash();

  @$internal
  @override
  TransactionsNotifier create() => TransactionsNotifier();
}

String _$transactionsNotifierHash() =>
    r'0359cc0552eff08f1f858e3b2dd855045b6805d7';

abstract class _$TransactionsNotifier extends $AsyncNotifier<TransactionList> {
  FutureOr<TransactionList> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TransactionList>, TransactionList>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<TransactionList>, TransactionList>,
        AsyncValue<TransactionList>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
