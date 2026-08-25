import 'package:equatable/equatable.dart';

/// Estados de navegação
class NavigationState extends Equatable {
  final String? location;
  final Object? extra;
  final NavigationType type;

  const NavigationState({
    this.location,
    this.extra,
    this.type = NavigationType.none,
  });

  factory NavigationState.initial() => const NavigationState();

  factory NavigationState.push(String location, {Object? extra}) {
    return NavigationState(
      location: location,
      extra: extra,
      type: NavigationType.push,
    );
  }

  factory NavigationState.go(String location, {Object? extra}) {
    return NavigationState(
      location: location,
      extra: extra,
      type: NavigationType.go,
    );
  }

  factory NavigationState.pop() {
    return NavigationState(type: NavigationType.pop);
  }

  @override
  List<Object?> get props => [location, extra, type];
}

enum NavigationType { none, push, go, pop }
