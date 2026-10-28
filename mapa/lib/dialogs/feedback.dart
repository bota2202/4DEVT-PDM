import 'package:flutter/material.dart';

// Executa uma operação (banco, GPS, link) e mostra mensagem de sucesso ou erro.
Future<void> executarComMensagem(BuildContext context, Future<void> operacao, String sucesso) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await operacao;
    messenger.showSnackBar(SnackBar(content: Text(sucesso)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(backgroundColor: Colors.red.shade700, content: Text('Erro: $e')));
  }
}
