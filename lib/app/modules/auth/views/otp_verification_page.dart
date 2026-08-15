import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../routes/app_routes.dart';

class OtpVerificationPage extends StatefulWidget {
  final String telefone;
  const OtpVerificationPage({super.key, required this.telefone});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificação')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Verifique seu SMS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enviamos um código de 6 dígitos para ${widget.telefone}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.length == 6) {
                      context.read<AuthCubit>().verifyOtp(widget.telefone, value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state is AuthOtpVerifying
                        ? null
                        : () {
                            final code = _otpController.text;
                            if (code.length == 6) {
                              context.read<AuthCubit>().verifyOtp(widget.telefone, code);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Digite o código de 6 dígitos.')),
                              );
                            }
                          },
                    child: state is AuthOtpVerifying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Verificar Código'),
                  ),
                ),
                TextButton(
                  onPressed: state is AuthOtpVerifying ? null : () => Navigator.pop(context),
                  child: const Text('Alterar número de telefone'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
