// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budgets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetsRepository)
final budgetsRepositoryProvider = BudgetsRepositoryProvider._();

final class BudgetsRepositoryProvider extends $FunctionalProvider<
    BudgetsRepository,
    BudgetsRepository,
    BudgetsRepository> with $Provider<BudgetsRepository> {
  BudgetsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'budgetsRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$budgetsRepositoryHash();

  @$internal
  @override
  $ProviderElement<BudgetsRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetsRepository create(Ref ref) {
    return budgetsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetsRepository>(value),
    );
  }
}

String _$budgetsRepositoryHash() => r'95a5082388dfc45d5cba65c94b0930f6adad9662';

@ProviderFor(BudgetsNotifier)
final budgetsProvider = BudgetsNotifierProvider._();

final class BudgetsNotifierProvider
    extends $AsyncNotifierProvider<BudgetsNotifier, BudgetList> {
  BudgetsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'budgetsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$budgetsNotifierHash();

  @$internal
  @override
  BudgetsNotifier create() => BudgetsNotifier();
}

String _$budgetsNotifierHash() => r'6a2db0aa35e1ce673d55b025f810b3a9647cac5f';

abstract class _$BudgetsNotifier extends $AsyncNotifier<BudgetList> {
  FutureOr<BudgetList> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BudgetList>, BudgetList>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<BudgetList>, BudgetList>,
        AsyncValue<BudgetList>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
