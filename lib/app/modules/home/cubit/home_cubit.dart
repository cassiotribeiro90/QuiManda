import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeModuleChanged extends HomeState {
  final int index;
  final String title;

  const HomeModuleChanged(this.index, this.title);

  @override
  List<Object?> get props => [index, title];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeModuleChanged(1, 'Pedidos'));

  void changeModule(int index, String title) {
    emit(HomeModuleChanged(index, title));
  }
}
