import 'package:flutter/material.dart';

/// Um Scaffold que centraliza o conteúdo em uma coluna com largura máxima.
///
/// Perfeito para apps multiplataforma onde em telas grandes (desktop/tablet)
/// o conteúdo não deve se esticar por toda a largura.
class ResponsiveScaffold extends StatelessWidget {
  /// Conteúdo principal que será centralizado
  final Widget body;

  /// Largura máxima da coluna central (padrão: 1000)
  final double maxWidth;

  /// AppBar opcional
  final PreferredSizeWidget? appBar;

  /// Botão de voltar automático (true = mostra seta se houver rota anterior)
  final bool automaticallyImplyLeading;

  /// Widget flutuante (FAB)
  final Widget? floatingActionButton;

  /// Drawer (menu lateral)
  final Widget? drawer;

  /// BottomNavigationBar
  final Widget? bottomNavigationBar;

  /// Cor de fundo do Scaffold
  final Color? backgroundColor;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.maxWidth = 1000,
    this.appBar,
    this.automaticallyImplyLeading = true,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: body,
        ),
      ),
    );
  }
}
