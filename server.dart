import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_staticHandler);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    8000,
  );

  print('✅ Servidor SPA rodando em: http://localhost:8000');
  print('📋 Todas as rotas redirecionam para index.html');
  print('📋 Pressione Ctrl+C para parar');
}

Response _staticHandler(Request request) {
  var path = request.url.path;
  if (path.isEmpty) path = 'index.html';

  final file = File(path);
  if (file.existsSync()) {
    return Response.ok(
      file.readAsBytesSync(),
      headers: {'Content-Type': _getContentType(path)},
    );
  }

  // SPA: redireciona para index.html
  final indexFile = File('index.html');
  if (indexFile.existsSync()) {
    return Response.ok(
      indexFile.readAsBytesSync(),
      headers: {'Content-Type': 'text/html'},
    );
  }

  return Response.notFound('Arquivo não encontrado');
}

String _getContentType(String path) {
  if (path.endsWith('.html')) return 'text/html';
  if (path.endsWith('.css')) return 'text/css';
  if (path.endsWith('.js')) return 'application/javascript';
  if (path.endsWith('.json')) return 'application/json';
  if (path.endsWith('.png')) return 'image/png';
  if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
  if (path.endsWith('.svg')) return 'image/svg+xml';
  if (path.endsWith('.ico')) return 'image/x-icon';
  if (path.endsWith('.woff')) return 'font/woff';
  if (path.endsWith('.woff2')) return 'font/woff2';
  return 'application/octet-stream';
}