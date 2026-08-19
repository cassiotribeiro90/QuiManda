import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import 'widgets/dashboard_kpis.dart';
import 'widgets/dashboard_charts.dart';
import 'widgets/dashboard_lists.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardCubit>().loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardLoaded) {
          // Usando os dados existentes do state antigo para manter compatibilidade
          final data = {
            'kpis': {
              'pedidos_hoje': state.totalPedidos,
              'faturamento_mes': state.faturamento,
              'pedidos_semana': 0,
              'faturamento_hoje': 0,
              'ticket_medio': 0,
              'avaliacao_media': 0,
              'clientes_unicos': 0,
            },
            'pedidos_por_dia': [],
            'faturamento_por_mes': [],
            'pedidos_por_status': [],
            'pedidos_por_pagamento': [],
            'top_produtos': [],
            'top_clientes': [],
            'horarios_pico': [],
            'satisfacao': {'percentual_positivo': 0, 'total': 0},
          };
          return _buildDashboard(data);
        }

        if (state is DashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                const SizedBox(height: 12),
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<DashboardCubit>().loadDashboard(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildDashboard(Map<String, dynamic> dados) {
    // Fallback para evitar erros se os dados não estiverem mapeados perfeitamente ainda
    final kpis = dados['kpis'] ?? {};
    final pedidosPorDia = dados['pedidos_por_dia'] ?? [];
    final faturamentoPorMes = dados['faturamento_por_mes'] ?? [];
    final pedidosPorStatus = dados['pedidos_por_status'] ?? [];
    final pedidosPorPagamento = dados['pedidos_por_pagamento'] ?? [];
    final topProdutos = dados['top_produtos'] ?? [];
    final topClientes = dados['top_clientes'] ?? [];
    final horariosPico = dados['horarios_pico'] ?? [];
    final satisfacao = dados['satisfacao'] ?? {};

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardCubit>().loadDashboard();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DashboardKpis(kpis: kpis),
            const SizedBox(height: 24),
            DashboardCharts(
              pedidosPorDia: pedidosPorDia,
              faturamentoPorMes: faturamentoPorMes,
              pedidosPorStatus: pedidosPorStatus,
              pedidosPorPagamento: pedidosPorPagamento,
            ),
            const SizedBox(height: 24),
            DashboardLists(
              topProdutos: topProdutos,
              topClientes: topClientes,
              horariosPico: horariosPico,
              satisfacao: satisfacao,
            ),
          ],
        ),
      ),
    );
  }
}
