import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

/// Serviço para gerenciar o ID único do dispositivo
class DeviceService {
  final SharedPreferences _prefs;
  static const String _keyDeviceId = 'device_id';
  String? _cachedDeviceId;

  DeviceService(this._prefs);

  /// 🔥 OBTÉM OU CRIA UM DEVICE ID ÚNICO
  Future<String> getDeviceId() async {
    // Se já tem em cache, retorna
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    // Busca no storage
    String? deviceId = _prefs.getString(_keyDeviceId);

    // Se não existe, cria um novo
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _generateDeviceId();
      await _prefs.setString(_keyDeviceId, deviceId);
      debugPrint('[DEVICE] 🔑 Novo device ID gerado: $deviceId');
    } else {
      debugPrint('[DEVICE] 🔑 Device ID carregado: $deviceId');
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }

  /// 🔥 GERA UM ID ÚNICO PARA O DISPOSITIVO
  String _generateDeviceId() {
    // Usa UUID para gerar um ID único
    return const Uuid().v4();
  }

  /// 🔥 LIMPA O DEVICE ID (LOGOUT) - Opcional, geralmente o device_id permanece o mesmo
  Future<void> clearDeviceId() async {
    await _prefs.remove(_keyDeviceId);
    _cachedDeviceId = null;
    debugPrint('[DEVICE] 🗑️ Device ID removido');
  }
}
