import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/responsive/responsive_scaffold.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import 'widgets/dashboard_kpis.dart';
import 'widgets/dashboard_charts.dart';
import 'widgets/dashboard_lists.dart';
import '../../../widgets/custom_app_bar.dart';

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
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DashboardCubit>().loadDashboard(),
                    child: const Text('Tentar novamente', style: TextStyle(fontSize: 16)),
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

    final isMobile = MediaQuery.of(context).size.width < 600;

    return ResponsiveScaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardCubit>().loadDashboard();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Visão Geral',
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 10, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Sua loja',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              DashboardKpis(kpis: kpis, isMobile: isMobile),
              const SizedBox(height: 28),
              DashboardCharts(
                pedidosPorDia: pedidosPorDia,
                faturamentoPorMes: faturamentoPorMes,
                pedidosPorStatus: pedidosPorStatus,
                pedidosPorPagamento: pedidosPorPagamento,
                isMobile: isMobile,
              ),
              const SizedBox(height: 28),
              DashboardLists(
                topProdutos: topProdutos,
                topClientes: topClientes,
                horariosPico: horariosPico,
                satisfacao: satisfacao,
                isMobile: isMobile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}