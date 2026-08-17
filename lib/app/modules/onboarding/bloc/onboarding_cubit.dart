import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage_service.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final StorageService _storageService;

  OnboardingCubit(this._storageService) : super(OnboardingInitial());

  Future<void> checkOnboarding() async {
    final seen = await _storageService.isOnboardingShown();
    if (seen) {
      emit(OnboardingSeen());
    } else {
      emit(OnboardingNotSeen());
    }
  }

  Future<void> markOnboardingAsSeen() async {
    await _storageService.setOnboardingShown();
    emit(OnboardingSeen());
  }
}
