import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api_client.dart';
import '../../routes/app_routes.dart';
import 'device_service.dart';
import 'tts_service.dart';
import '../../modules/pedidos/cubit/pedidos_cubit.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  ApiClient? _apiClient;
  DeviceService? _deviceService;
  
  // 🔥 OBTER INSTÂNCIA APENAS QUANDO NECESSÁRIO (NÃO NO WINDOWS)
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  String? _token;
  BuildContext? _context;
  PedidosCubit? _pedidoCubit;

  /// 🔥 SETTERS PARA INJEÇÃO
  void setDependencies(ApiClient apiClient, DeviceService deviceService) {
    _apiClient = apiClient;
    _deviceService = deviceService;
  }

  set context(BuildContext ctx) => _context = ctx;
  set pedidoCubit(PedidosCubit cubit) => _pedidoCubit = cubit;

  /// 🔥 INICIALIZA O FCM
  Future<void> init() async {

    // 🔥 SÓ INICIALIZA SE NÃO FOR WINDOWS
    if (!kIsWeb && Platform.isWindows) {
      debugPrint('[FCM] ⏳ Windows não suporta Firebase Messaging');
      return;
    }

    if (_isInitialized) return;

    try {
      // Solicita permissão
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('[FCM] ❌ Permissão negada');
        return;
      }

      // Obtém o token
      _token = await _fcm.getToken();
      debugPrint('[FCM] 📱 Token: $_token');

      // Inicializa notificações locais
      await _initLocalNotifications();

      // 🔥 HANDLERS
      // 1. Foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 2. Aberto por notificação
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // 3. Background (isolate)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 4. Token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('[FCM] 🔄 Token atualizado: $newToken');
        _token = newToken;
        sendTokenToBackend();
      });

      _isInitialized = true;
      debugPrint('[FCM] ✅ Inicializado com sucesso');

    } catch (e) {
      debugPrint('[FCM] ❌ Erro: $e');
    }
  }

  /// 🔥 NOTIFICAÇÕES LOCAIS
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(settings);
  }

  /// 🔥 MOSTRA NOTIFICAÇÃO LOCAL (sistema)
  Future<void> showLocalNotification(String title, String body, Map<String, dynamic> data) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pedidos_channel',
      'Pedidos',
      channelDescription: 'Notificações de pedidos',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      0,
      title,
      body,
      details,
      payload: data['pedido_id']?.toString() ?? '',
    );
  }

  /// 🔥 HANDLER: Foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] 📨 Foreground: ${message.notification?.title}');

    // Mostra overlay
    _showInAppOverlay(message);

    // Dispara TTS se for novo pedido
    if (message.data['type'] == 'novo_pedido' || message.data['status'] == 'novo') {
      TtsService().speakText('Novo pedido recebido!');
    }

    // Recarrega pedidos
    _pedidoCubit?.carregarPedidosAtivos(silencioso: true);
  }

  /// 🔥 HANDLER: Aberto por notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] 📨 App aberto por notificação: ${message.data}');
    final pedidoId = message.data['pedido_id']?.toString();
    _navigateToPedido(pedidoId);
  }

  /// 🔥 MOSTRA OVERLAY IN-APP
  void _showInAppOverlay(RemoteMessage message) {
    final context = _context;
    if (context == null) return;

    final title = message.notification?.title ?? 'Novo Pedido';
    final body = message.notification?.body ?? '';
    final pedidoId = message.data['pedido_id']?.toString();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              entry.remove();
              _navigateToPedido(pedidoId);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: entry.remove,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 6), () {
      if (entry.mounted) entry.remove();
    });
  }

  /// 🔥 NAVEGAÇÃO
  void _navigateToPedido(String? pedidoId) {
    // Por enquanto redireciona para dashboard e deixa o cubit carregar
    ApiClient.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  /// 🔥 ENVIA TOKEN PARA O BACKEND
  Future<void> sendTokenToBackend() async {
    if (!kIsWeb && Platform.isWindows) return;

    if (_token == null) {
      try {
        _token = await _fcm.getToken();
      } catch (e) {
        debugPrint('[FCM] ❌ Erro ao obter token: $e');
        return;
      }
    }
    
    if (_token == null || _apiClient == null || _deviceService == null) return;

    try {
      final deviceId = await _deviceService!.getDeviceId();
      await _apiClient!.post(
        '/api/lojista/auth-lojista/device-token',
        data: {
          'device_token': _token,
          'device_id': deviceId,
        },
      );
      debugPrint('[FCM] ✅ Token sincronizado');
    } catch (e) {
      debugPrint('[FCM] ❌ Erro ao enviar token: $e');
    }
  }

  /// 🔥 REMOVE O TOKEN
  Future<void> removeTokenFromBackend() async {
    if (!kIsWeb && Platform.isWindows) return;
    if (_apiClient == null) return;
    try {
      await _apiClient!.delete('/api/lojista/auth-lojista/device-token');
      debugPrint('[FCM] ✅ Token removido');
    } catch (e) {
      debugPrint('[FCM] ❌ Erro ao remover token: $e');
    }
  }

  String? get token => _token;

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('[FCM] 📨 Background: ${message.messageId}');
  }
}
