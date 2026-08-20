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
  final bool storeChanged; // 🔥 NOVO: indica se a loja acabou de mudar

  const StoreLoaded({
    required this.stores,
    required this.selectedStore,
    required this.hasMultipleStores,
    this.storeChanged = false,
  });

  StoreLoaded copyWith({
    List<LojaModel>? stores,
    LojaModel? selectedStore,
    bool? hasMultipleStores,
    bool? storeChanged,
  }) {
    return StoreLoaded(
      stores: stores ?? this.stores,
      selectedStore: selectedStore ?? this.selectedStore,
      hasMultipleStores: hasMultipleStores ?? this.hasMultipleStores,
      storeChanged: storeChanged ?? this.storeChanged,
    );
  }

  @override
  List<Object?> get props => [stores, selectedStore, hasMultipleStores, storeChanged];
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
