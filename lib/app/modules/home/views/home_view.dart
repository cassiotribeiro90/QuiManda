import 'package:flutter/material.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../pedidos/views/pedidos_list_view.dart';
import '../../produtos/views/produtos_list_view.dart';
import '../../loja/views/loja_edit_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DashboardView(),
    const PedidosListView(),
    const ProdutosListView(),
    const LojaEditView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dash'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Produtos'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Loja'),
        ],
      ),
    );
  }
}
