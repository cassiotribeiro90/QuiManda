import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SharedPreferences _sharedPreferences;
  static const String _onboardingKey = 'onboarding_seen';

  OnboardingCubit(this._sharedPreferences) : super(OnboardingInitial());

  void checkOnboarding() {
    final seen = _sharedPreferences.getBool(_onboardingKey) ?? false;
    if (seen) {
      emit(OnboardingSeen());
    } else {
      emit(OnboardingNotSeen());
    }
  }

  Future<void> markOnboardingAsSeen() async {
    await _sharedPreferences.setBool(_onboardingKey, true);
    emit(OnboardingSeen());
  }
}
