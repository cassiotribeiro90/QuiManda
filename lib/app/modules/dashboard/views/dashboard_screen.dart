import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/responsive/responsive_scaffold.dart';
import '../../home/views/home_view.dart';
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is DashboardLoaded) {
          return _buildDashboard(state);
        }

        if (state is DashboardError) {
          return Scaffold(
            body: Center(
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
            ),
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildDashboard(DashboardLoaded state) {
    final dados = state.data;

    final kpis = dados['kpis'] ?? {};
    final pedidosPorDia = dados['pedidos_por_dia'] ?? [];
    final faturamentoPorMes = dados['faturamento_por_mes'] ?? [];
    final pedidosPorStatus = dados['pedidos_por_status'] ?? [];
    final pedidosPorPagamento = dados['pedidos_por_pagamento'] ?? [];
    final topProdutos = dados['top_produtos'] ?? [];
    final topClientes = dados['top_clientes'] ?? [];
    final horariosPico = dados['horarios_pico'] ?? [];
    final satisfacao = dados['satisfacao'] ?? {};

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: MediaQuery.of(context).size.width < 900
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => HomeView.scaffoldKey.currentState?.openDrawer(),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardCubit>().loadDashboard();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... conteúdo que estava no Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.green.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Sua loja',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
      ),
    );
  }
}