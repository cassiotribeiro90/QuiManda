import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../core/services/storage_service.dart';
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
import '../modules/cardapio/repositories/cardapio_repository.dart';
import '../modules/cardapio/services/cardapio_service.dart';
import '../modules/cardapio/bloc/cardapio_cubit.dart';
import '../modules/home/cubit/home_cubit.dart';
import '../modules/onboarding/bloc/onboarding_cubit.dart';
import '../modules/configuracoes/services/loja_service.dart' as config_service;
import '../modules/configuracoes/bloc/configuracoes_cubit.dart';
import '../modules/chat/repositories/chat_repository.dart';
import '../modules/chat/bloc/chat_badge_cubit.dart';
import '../modules/all_pedidos/di/all_pedidos_di.dart';

// 🔥 NOVO: AVALIAÇÕES
import '../modules/avaliacoes/services/avaliacao_service.dart';
import '../modules/avaliacoes/bloc/avaliacoes_cubit.dart';

import '../core/storage/store_storage.dart';
import '../modules/store/bloc/store_cubit.dart';
import '../core/services/tts_config_service.dart';
import '../core/services/fcm_service.dart';
import '../core/services/device_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // 🔥 1. Cria o StoreStorage (async)
  final storeStorage = await StoreStorage.create();
  getIt.registerSingleton<StoreStorage>(storeStorage);

  // Services
  getIt.registerLazySingleton<StorageService>(() => StorageService(getIt<SharedPreferences>()));
  getIt.registerLazySingleton<TtsConfigService>(() => TtsConfigService(getIt<SharedPreferences>()));
  getIt.registerLazySingleton<DeviceService>(() => DeviceService(getIt<SharedPreferences>()));
  getIt.registerLazySingleton<TokenService>(() => TokenService(getIt<SharedPreferences>()));

  getIt.registerLazySingleton<StoreCubit>(() => StoreCubit(getIt<StoreStorage>()));

  getIt.registerLazySingleton<ApiClient>(() => ApiClient(
    getIt<TokenService>(),
    getIt<StoreStorage>(),
  ));

  getIt.registerLazySingleton<FcmService>(() {
    final fcm = FcmService();
    fcm.setDependencies(getIt<ApiClient>(), getIt<DeviceService>());
    return fcm;
  });

  // Home
  getIt.registerFactory<HomeCubit>(() => HomeCubit());

  // Auth
  getIt.registerLazySingleton<AuthService>(() => AuthService(
    getIt<TokenService>(),
    getIt<StoreStorage>(),
  ));
  getIt.registerFactory<AuthCubit>(() => AuthCubit(
    authService: getIt<AuthService>(),
    tokenService: getIt<TokenService>(),
    storageService: getIt<StorageService>(),
    fcmService: getIt<FcmService>(),
    deviceService: getIt<DeviceService>(),
    storeStorage: getIt<StoreStorage>(),
  ));

  // Dashboard
  getIt.registerLazySingleton<DashboardRepository>(() => DashboardRepository(getIt<ApiClient>()));
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

  // Cardapio
  getIt.registerLazySingleton<CardapioService>(() => CardapioService());
  getIt.registerLazySingleton<CardapioRepository>(() => CardapioRepository(getIt<CardapioService>()));
  getIt.registerFactory<CardapioCubit>(() => CardapioCubit(getIt<CardapioRepository>()));

  // Onboarding
  getIt.registerFactory<OnboardingCubit>(() => OnboardingCubit(getIt<StorageService>()));

  // Configuracoes
  getIt.registerLazySingleton<config_service.LojaService>(() => config_service.LojaService(getIt<ApiClient>()));
  getIt.registerFactory<ConfiguracoesCubit>(() => ConfiguracoesCubit(getIt<config_service.LojaService>()));

  // Chat
  getIt.registerLazySingleton<ChatRepository>(() => ChatRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton<ChatBadgeCubit>(() => ChatBadgeCubit(getIt<ChatRepository>()));

  // All Pedidos
  registerAllPedidosModule();

  // ============================================================
  // 🔥 AVALIAÇÕES
  // ============================================================
  getIt.registerLazySingleton<AvaliacaoService>(() => AvaliacaoService(getIt<ApiClient>()));
  getIt.registerFactory<AvaliacoesCubit>(() => AvaliacoesCubit(getIt<AvaliacaoService>()));
}