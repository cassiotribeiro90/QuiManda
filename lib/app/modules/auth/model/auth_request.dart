class VerifyOtpRequest {
  final String phone;
  final String code;
  final String deviceId;
  final String? deviceToken;

  VerifyOtpRequest({
    required this.phone,
    required this.code,
    required this.deviceId,
    this.deviceToken,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'phone': phone,
      'code': code,
      'device_id': deviceId,
    };
    if (deviceToken != null) {
      data['device_token'] = deviceToken!;
    }
    return data;
  }
}

class LoginRequest {
  final String email;
  final String senha;
  final String deviceId;
  final String? deviceToken;

  LoginRequest({
    required this.email,
    required this.senha,
    required this.deviceId,
    this.deviceToken,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'email': email,
      'senha': senha,
      'device_id': deviceId,
    };
    if (deviceToken != null) {
      data['device_token'] = deviceToken!;
    }
    return data;
  }
}
