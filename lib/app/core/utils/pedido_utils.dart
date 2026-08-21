import '../../modules/pedidos/model/pedido_model.dart';

class PedidoUtils {
  /// Converte número para texto por extenso
  static String _numeroPorExtenso(int numero) {
    const numeros = [
      'zero', 'uma', 'duas', 'três', 'quatro', 'cinco',
      'seis', 'sete', 'oito', 'nove', 'dez',
      'onze', 'doze', 'treze', 'quatorze', 'quinze',
      'dezesseis', 'dezessete', 'dezoito', 'dezenove', 'vinte'
    ];
    if (numero >= 0 && numero < numeros.length) {
      return numeros[numero];
    }
    return '$numero';
  }

  /// Converte quantidade para texto com unidade
  static String _quantidadeTexto(int quantidade, String nomeProduto) {
    if (quantidade == 1) {
      return 'uma unidade de $nomeProduto';
    } else if (quantidade <= 20) {
      return '${_numeroPorExtenso(quantidade)} unidades de $nomeProduto';
    } else {
      return '$quantidade unidades de $nomeProduto';
    }
  }

  /// Formata o alerta de novo pedido de forma natural e legível
  static String formatarAlertaPedido(PedidoModel pedido) {
    final cliente = pedido.clienteNome ?? 'cliente';

    // Constrói lista de itens com texto natural
    final List<String> itensFormatados = [];
    for (var item in pedido.itens) {
      final qtd = item.quantidade;
      final nome = item.nome.toLowerCase().trim();
      itensFormatados.add(_quantidadeTexto(qtd, nome));
    }

    // Junta com "e" no último item para soar natural
    String itensTexto;
    if (itensFormatados.isEmpty) {
      itensTexto = 'pedido vazio';
    } else if (itensFormatados.length == 1) {
      itensTexto = itensFormatados.first;
    } else if (itensFormatados.length == 2) {
      itensTexto = itensFormatados.join(' e ');
    } else {
      final ultimo = itensFormatados.removeLast();
      itensTexto = '${itensFormatados.join(', ')} e $ultimo';
    }

    return 'Novo pedido de $cliente: $itensTexto';
  }

  /// Versão resumida para alertas rápidos
  static String formatarAlertaResumido(PedidoModel pedido) {
    final cliente = pedido.clienteNome ?? 'cliente';
    final totalItens = pedido.itens.fold(0, (sum, item) => sum + item.quantidade);
    return 'Novo pedido de $cliente com $totalItens itens';
  }
}
