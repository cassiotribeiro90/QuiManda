import 'package:get_it/get_it.dart';
import '../bloc/all_pedidos_cubit.dart';
import '../../../services/all_pedidos_api_service.dart';
import '../../../core/api_client.dart';

void registerAllPedidosModule() {
  final apiClient = GetIt.I.get<ApiClient>();
  final apiService = AllPedidosApiService(apiClient);
  
  GetIt.I.registerFactory<AllPedidosCubit>(
    () => AllPedidosCubit(apiService),
  );
}
