import 'package:flutter/material.dart';

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
