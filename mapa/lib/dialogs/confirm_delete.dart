import 'package:flutter/material.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import 'feedback.dart';

Future<bool> confirmarExclusao(BuildContext context, String nome) async {
  return await showDialog<bool>(context: context, builder: (context) => AlertDialog(
    title: const Text('Excluir local?'),
    content: Text('Tem certeza que deseja excluir "$nome"? Essa ação não poderá ser desfeita.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
    ],
  )) ?? false;
}

// Pede confirmação, exclui no Firestore e mostra o resultado.
Future<bool> excluirLocal(BuildContext context, Local local) async {
  if (!await confirmarExclusao(context, local.nome) || !context.mounted) return false;
  await executarComMensagem(context, LocalService().excluir(local.id), 'Local excluído com sucesso.');
  return true;
}
