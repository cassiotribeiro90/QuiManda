import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../navigation/navigation_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../core/responsive/responsive_scaffold.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../store/bloc/store_cubit.dart';
import '../../store/bloc/store_state.dart';

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

  void _handleNavigation() {
    final storeState = context.read<StoreCubit>().state;
    final nav = context.read<NavigationCubit>();
    
    debugPrint('🔄 [UI_NAV] Tratando navegação pós-login. Estado da loja: ${storeState.runtimeType}');
    
    if (storeState is StoreLoaded) {
      debugPrint('✅ [UI_NAV] Lojista possui ${storeState.stores.length} lojas');
      if (storeState.hasMultipleStores) {
        debugPrint('🏪 [UI_NAV] Redirecionando para seleção de lojas');
        nav.goToStoreSelection();
      } else {
        debugPrint('🏠 [UI_NAV] Apenas uma loja, indo para Dashboard');
        nav.goToDashboard();
      }
    } else {
      debugPrint('⚠️ [UI_NAV] Estado da loja não carregado, indo para Dashboard por padrão');
      nav.goToDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Verificação')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            debugPrint('✅ [AUTH] Usuário autenticado com sucesso via OTP');
            _handleNavigation();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Verifique seu SMS',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enviamos um código de 6 dígitos para ${widget.telefone}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32, letterSpacing: 12, fontWeight: FontWeight.bold),
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '000000',
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onChanged: (value) {
                        if (value.length == 6) {
                          debugPrint('🔐 [AUTH] OTP completo digitado. Verificando...');
                          context.read<AuthCubit>().verifyOtp(widget.telefone, value);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
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
                            : const Text('VERIFICAR CÓDIGO', style: AppTextStyles.button),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: state is AuthOtpVerifying ? null : () {
                        debugPrint('⬅️ [NAVIGATION] Voltando para alteração de número');
                        context.read<NavigationCubit>().pop();
                      },
                      child: const Text('Alterar número de telefone', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
