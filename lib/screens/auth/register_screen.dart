import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../screens/home_screen.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<String> _instituicoes = ['AMC'];
  final _telefoneFormatter = MaskTextInputFormatter(
  mask: '(##)#####-####',
  filter: { "#": RegExp(r'[0-9]') },
  type: MaskAutoCompletionType.lazy,
);


  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedInstituicao;

  // Cores atualizadas para light mode
  static const Color policeYellow = Color(0xFFFFC107);
  static const Color backgroundColor = Colors.white;
  static const Color cardColor = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color errorColor = Colors.redAccent;
  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    if (_instituicoes.isNotEmpty) {
      _selectedInstituicao = _instituicoes[0];
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final error = await authService.registerUser(
        nomeCompleto: _fullNameController.text.trim(),
        nomeDeGuerra: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _phoneController.text.trim(),
        senha: _passwordController.text.trim(),
        instituicao: _selectedInstituicao!,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (error == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          setState(() => _errorMessage = error);
          debugPrint("Erro ao cadastrar: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro: $error")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Erro inesperado: $e";
        });
        debugPrint("Erro completo: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro inesperado: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: policeYellow,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 32),
                Icon(Icons.person_add, size: 64, color: policeYellow),
                const SizedBox(height: 16),
                Text('Crie sua conta',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    )),
                const SizedBox(height: 8),
                Text('Preencha os dados para se cadastrar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textSecondary,
                    )),
                const SizedBox(height: 32),

                Card(
                  color: cardColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      _buildTextField(_fullNameController, 'Nome Completo', Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildTextField(_usernameController, 'Nome de Guerra', Icons.shield_outlined),
                      const SizedBox(height: 16),
                      _buildTextField(_emailController, 'E-mail', Icons.email_outlined, type: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      // _buildTextField(_phoneController, 'Telefone', Icons.phone, type: TextInputType.phone),
                      TextFormField(
                        controller: _phoneController,
                        inputFormatters: [_telefoneFormatter],
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          labelStyle: const TextStyle(color: textSecondary),
                          prefixIcon: const Icon(Icons.phone, color: policeYellow),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: policeYellow, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Preencha o campo Telefone';
                          }
                          if (!_telefoneFormatter.isFill()) {
                            return 'Telefone incompleto';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedInstituicao,
                        items: _instituicoes.map((String instituicao) {
                          return DropdownMenuItem<String>(
                            value: instituicao,
                            child: Text(instituicao, style: const TextStyle(color: textPrimary)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedInstituicao = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Instituição',
                          labelStyle: const TextStyle(color: textSecondary),
                          prefixIcon: const Icon(Icons.account_balance, color: policeYellow),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: policeYellow, width: 2),
                          ),
                        ),
                        dropdownColor: backgroundColor,
                        style: const TextStyle(color: textPrimary),
                        validator: (value) => value == null ? 'Selecione uma instituição' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(_passwordController, 'Senha', Icons.lock_outline, isPassword: true),
                      const SizedBox(height: 16),
                      _buildTextField(_confirmPasswordController, 'Confirmar Senha', Icons.lock_reset, isPassword: true),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(_errorMessage!, style: const TextStyle(color: errorColor)),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: policeYellow,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('CADASTRAR', style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Já tem uma conta? ',
                            style: TextStyle(color: textSecondary),
                            children: [
                              TextSpan(
                                text: 'Entrar',
                                style: TextStyle(
                                  color: policeYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      style: const TextStyle(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textSecondary),
        prefixIcon: Icon(icon, color: policeYellow),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: policeYellow, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Preencha o campo $label';
        }
        if (label == 'Confirmar Senha' && value != _passwordController.text) {
          return 'As senhas não coincidem';
        }
        return null;
      },
    );
  }
}