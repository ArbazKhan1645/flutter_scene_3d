// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ViewerNotifier)
final viewerProvider = ViewerNotifierProvider._();

final class ViewerNotifierProvider
    extends $NotifierProvider<ViewerNotifier, ViewerState> {
  ViewerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewerNotifierHash();

  @$internal
  @override
  ViewerNotifier create() => ViewerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViewerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViewerState>(value),
    );
  }
}

String _$viewerNotifierHash() => r'8ccc71e29aafcf406cb72d077aeb9905f621cc34';

abstract class _$ViewerNotifier extends $Notifier<ViewerState> {
  ViewerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ViewerState, ViewerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ViewerState, ViewerState>,
              ViewerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
