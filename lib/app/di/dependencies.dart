import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../services/token_service.dart';
import '../modules/auth/service/auth_service.dart';
import '../modules/auth/cubit/auth_cubit.dart';
import '../modules/dashboard/repository/dashboard_repository.dart';
import '../modules/dashboard/service/dashboard_service.dart';
import '../modules/dashboard/cubit/dashboard_cubit.dart';
import '../modules/pedidos/repository/pedidos_repository.dart';
import '../modules/pedidos/service/pedidos_service.dart';
import '../modules/pedidos/cubit/pedidos_cubit.dart';
import '../modules/produtos/repository/produtos_repository.dart';
import '../modules/produtos/service/produtos_service.dart';
import '../modules/produtos/cubit/produtos_cubit.dart';
import '../modules/loja/repository/loja_repository.dart';
import '../modules/loja/service/loja_service.dart';
import '../modules/loja/cubit/loja_cubit.dart';
import '../modules/home/cubit/home_cubit.dart';
import '../modules/onboarding/bloc/onboarding_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Services
  getIt.registerLazySingleton<TokenService>(() => TokenService(getIt<SharedPreferences>()));
  
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<TokenService>()));

  // Home
  getIt.registerFactory<HomeCubit>(() => HomeCubit());

  // Auth
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt<ApiClient>()));
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthService>(), getIt<TokenService>()));

  // Dashboard
  getIt.registerLazySingleton<DashboardRepository>(() => DashboardRepository());
  getIt.registerLazySingleton<DashboardService>(() => DashboardService(getIt<DashboardRepository>()));
  getIt.registerFactory<DashboardCubit>(() => DashboardCubit(getIt<DashboardService>()));

  // Pedidos
  getIt.registerLazySingleton<PedidosService>(() => PedidosService(getIt<ApiClient>()));
  getIt.registerLazySingleton<PedidoRepository>(() => PedidoRepository(getIt<PedidosService>()));
  getIt.registerFactory<PedidosCubit>(() => PedidosCubit(getIt<PedidoRepository>()));

  // Produtos
  getIt.registerLazySingleton<ProdutosRepository>(() => ProdutosRepository());
  getIt.registerLazySingleton<ProdutosService>(() => ProdutosService(getIt<ProdutosRepository>()));
  getIt.registerFactory<ProdutosCubit>(() => ProdutosCubit(getIt<ProdutosService>()));

  // Loja
  getIt.registerLazySingleton<LojaRepository>(() => LojaRepository());
  getIt.registerLazySingleton<LojaService>(() => LojaService(getIt<LojaRepository>()));
  getIt.registerFactory<LojaCubit>(() => LojaCubit(getIt<LojaService>()));

  // Onboarding
  getIt.registerFactory<OnboardingCubit>(() => OnboardingCubit(getIt<SharedPreferences>()));
}
