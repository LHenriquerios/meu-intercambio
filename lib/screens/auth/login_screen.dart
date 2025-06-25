import 'package:flutter/material.dart';
import 'package:meu_intercambio_prototype/services/auth_service.dart';
import '../home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;


  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Usamos um bloco `try/finally` para garantir que o loading sempre termine.
    try {
      final authService = AuthService();
      final error = await authService.loginWithEmail(
        email: _emailController.text.trim(),
        senha: _passwordController.text.trim(),
      );

      // Verificação de segurança: não continue se a tela saiu da árvore de widgets
      if (!mounted) return; 

      if (error == null) {
        // Sucesso no login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Falha no login, mostra o erro
        setState(() {
          _errorMessage = error;
        });
      }
    } finally {
      // Este bloco é executado SEMPRE, no sucesso ou no erro.
      // Lugar perfeito para parar o indicador de carregamento.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color policeYellow = Color.fromARGB(249, 254, 192, 4);
    const Color backgroundColor = Colors.white;
    const Color cardColor = Color(0xFFF5F5F5);
    const Color textPrimary = Color(0xFF333333);
    const Color textSecondary = Color(0xFF666666);
    const Color errorColor = Colors.redAccent;
    const Color borderColor = Color(0xFFE0E0E0);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Troca de Turno',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistema de Intercâmbio de Serviços',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 2,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: const TextStyle(color: textSecondary),
                                prefixIcon: const Icon(Icons.email_outlined,
                                    color: policeYellow),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: policeYellow, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Insira seu Email.';
                                }
                                if (!value.contains('@')) {
                                  return 'Insira um email válido.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              style: const TextStyle(color: textPrimary),
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                labelStyle: const TextStyle(color: textSecondary),
                                prefixIcon: const Icon(Icons.lock_outline,
                                    color: policeYellow),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: policeYellow, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Insira sua senha.';
                                }
                                if (value.length < 6) {
                                  return 'Mínimo de 6 caracteres.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            if (_errorMessage != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 4),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                      color: errorColor, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: policeYellow,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                  ),
                                  elevation: 2,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 3)
                                    : const Text('ACESSAR'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 16),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Não tem cadastro? ',
                          style: TextStyle(color: textSecondary),
                          children: [
                            TextSpan(
                              text: 'Cadastre-se',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: policeYellow,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}