import 'package:equatable/equatable.dart';
import '../../auth/model/loja_model.dart';

abstract class StoreState extends Equatable {
  const StoreState();
  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {
  const StoreInitial();
}

class StoreLoading extends StoreState {
  const StoreLoading();
}

class StoreLoaded extends StoreState {
  final List<LojaModel> stores;
  final LojaModel selectedStore;
  final bool hasMultipleStores;

  const StoreLoaded({
    required this.stores,
    required this.selectedStore,
    required this.hasMultipleStores,
  });

  StoreLoaded copyWith({
    List<LojaModel>? stores,
    LojaModel? selectedStore,
    bool? hasMultipleStores,
  }) {
    return StoreLoaded(
      stores: stores ?? this.stores,
      selectedStore: selectedStore ?? this.selectedStore,
      hasMultipleStores: hasMultipleStores ?? this.hasMultipleStores,
    );
  }

  @override
  List<Object?> get props => [stores, selectedStore, hasMultipleStores];
}

class StoreEmpty extends StoreState {
  const StoreEmpty();
}

class StoreError extends StoreState {
  final String message;
  const StoreError(this.message);
  @override
  List<Object?> get props => [message];
}
