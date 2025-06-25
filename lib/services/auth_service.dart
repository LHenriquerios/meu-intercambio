import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Seus getters e streams (sem alterações) ---
  User? get currentUser => _auth.currentUser;

  Stream<String?> get userIdStream {
    return _auth.authStateChanges().map((User? user) {
      return user?.uid;
    });
  }

  // --- NOVO: Função auxiliar para traduzir os códigos de erro do Firebase Auth ---
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este e-mail já está em uso por outra conta.';
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este e-mail.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Credenciais incorretas. Por favor, tente novamente.';
      default:
        return 'Ocorreu um erro de autenticação. Tente novamente.';
    }
  }

  /// Login com email e senha
  Future<String?> loginWithEmail({
    required String email,
    required String senha,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      // --- ALTERADO: Chamando a função de tradução ---
      debugPrint("Erro de Auth (Login): ${e.code}");
      return _getAuthErrorMessage(e.code);
    } catch (e) {
      debugPrint("Erro geral (Login): $e");
      return 'Ocorreu um erro inesperado ao fazer login.';
    }
  }

  /// Cadastra novo usuário
  Future<String?> registerUser({
    required String nomeCompleto,
    required String email,
    required String senha,
    required String instituicao,
    String? nomeDeGuerra,
    String? telefone,
  }) async {
    try {
      debugPrint("Tentando criar usuário no Firebase Auth...");
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      debugPrint("Usuário criado no Auth, UID: ${result.user?.uid}");
      
      String uid = result.user!.uid;

      debugPrint("Salvando dados no Firestore...");
      await _firestore.collection('users').doc(uid).set({
        'nomeCompleto': nomeCompleto,
        'email': email,
        'instituicao': instituicao,
        'nomeDeGuerra': nomeDeGuerra ?? '',
        'telefone': telefone ?? '',
        'criadoEm': FieldValue.serverTimestamp(),
      });

      debugPrint("Usuário registrado com sucesso!");
      return null;
    } on FirebaseAuthException catch (e) {
      // --- ALTERADO: Chamando a função de tradução ---
      debugPrint("Erro no Firebase Auth: ${e.code} - ${e.message}");
      return _getAuthErrorMessage(e.code);
    } on FirebaseException catch (e) {
      debugPrint("Erro no Firestore: ${e.code} - ${e.message}");
      return "Erro ao salvar dados. Tente novamente."; // Mensagem mais amigável
    } catch (e, stack) {
      debugPrint("Erro inesperado: $e");
      debugPrint("Stack trace: $stack");
      return "Ocorreu um erro inesperado."; // Mensagem mais amigável
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- Seus outros métodos (sem alterações) ---
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        final DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data() as Map<String, dynamic>?;
      } catch (e) {
        debugPrint('Erro ao buscar dados do usuário: $e');
        return null;
      }
    }
    return null;
  }

  String? get currentUserId => _auth.currentUser?.uid;
}