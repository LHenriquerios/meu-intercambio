// screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<Map<String, dynamic>?> _userDataFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _userDataFuture = _authService.getCurrentUserData();
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sair: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Paleta de Cores (Light Mode) ---
    const Color lightBackground = Color(0xFFFAFAFA);
    const Color policeYellow = Color(0xFFFFC107);
    const Color textPrimaryLight = Color(0xFF212121);
    const Color textSecondaryLight = Color(0xFF757575);

    // Estilos para os textos de informação
    const infoStyle = TextStyle(color: textPrimaryLight, fontSize: 18, fontWeight: FontWeight.w500);
    const labelStyle = TextStyle(color: textSecondaryLight, fontSize: 16);

    return Scaffold(
      // 1. AppBar restaurada como no original, mas com cores do tema
      
      backgroundColor: lightBackground,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: policeYellow));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Nenhum dado de perfil encontrado.', style: TextStyle(color: textSecondaryLight)));
          }

          final userData = snapshot.data!;

          // 2. Estrutura com ListView e ListTile restaurada
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const Icon(Icons.person_pin, size: 100, color: policeYellow),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('Nome Completo', style: labelStyle),
                subtitle: Text(userData['nomeCompleto'] ?? 'Não informado', style: infoStyle),
              ),
              ListTile(
                title: const Text('Nome de Guerra', style: labelStyle),
                subtitle: Text(userData['nomeDeGuerra'] ?? 'Não informado', style: infoStyle),
              ),
              ListTile(
                title: const Text('E-mail', style: labelStyle),
                subtitle: Text(userData['email'] ?? 'Não informado', style: infoStyle),
              ),
              ListTile(
                title: const Text('Telefone', style: labelStyle),
                subtitle: Text(userData['telefone'] ?? 'Não informado', style: infoStyle),
              ),
              ListTile(
                title: const Text('Instituição', style: labelStyle),
                subtitle: Text(userData['instituicao'] ?? 'Não informada', style: infoStyle),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('SAIR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
