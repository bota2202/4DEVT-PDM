import 'package:flutter/material.dart';
import '../models/local.dart';

class LocalForm extends StatefulWidget {
  final Local? local;
  final void Function(Local local) onSave;
  const LocalForm({super.key, this.local, required this.onSave});

  @override State<LocalForm> createState() => _LocalFormState();
}

class _LocalFormState extends State<LocalForm> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nome, horario, avaliacao, distancia, descricao;
  late String categoria, cidade;

  final categorias = ['Academia', 'Restaurante', 'Hospital', 'Clínica', 'Esportes', 'Outro'];
  final cidades = ['São Paulo', 'Campinas', 'Jundiaí'];

  @override
  void initState() {
    super.initState();
    final l = widget.local;
    nome = TextEditingController(text: l?.nome ?? '');
    horario = TextEditingController(text: l?.horario ?? '');
    avaliacao = TextEditingController(text: l?.avaliacao.toString() ?? '4.5');
    distancia = TextEditingController(text: l?.distancia.toString() ?? '1.0');
    descricao = TextEditingController(text: l?.descricao ?? '');
    categoria = l?.categoria ?? categorias.first;
    cidade = l?.cidade ?? cidades.first;
  }

  @override void dispose() { nome.dispose(); horario.dispose(); avaliacao.dispose(); distancia.dispose(); descricao.dispose(); super.dispose(); }

  InputDecoration decoration(String label, IconData icon) => InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));

  void salvar() {
    if (!formKey.currentState!.validate()) return;
    final old = widget.local;
    widget.onSave(Local(id: old?.id ?? DateTime.now().microsecondsSinceEpoch.toString(), nome: nome.text.trim(), categoria: categoria, cidade: cidade, avaliacao: double.tryParse(avaliacao.text.replaceAll(',', '.')) ?? 0, distancia: double.tryParse(distancia.text.replaceAll(',', '.')) ?? 0, horario: horario.text.trim(), descricao: descricao.text.trim(), favorito: old?.favorito ?? false));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: 20, right: 20, top: 18, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
    child: Form(key: formKey, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(widget.local == null ? 'Cadastrar local' : 'Editar local', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]),
      const SizedBox(height: 12),
      TextFormField(controller: nome, decoration: decoration('Nome', Icons.place_outlined), validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: categoria, decoration: decoration('Categoria', Icons.category_outlined), items: categorias.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => categoria = v!)),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: cidade, decoration: decoration('Cidade', Icons.location_city_outlined), items: cidades.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => cidade = v!)),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: TextFormField(controller: avaliacao, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: decoration('Avaliação', Icons.star_border), validator: (v) => double.tryParse((v ?? '').replaceAll(',', '.')) == null ? 'Inválida' : null)), const SizedBox(width: 10), Expanded(child: TextFormField(controller: distancia, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: decoration('Distância (km)', Icons.near_me_outlined), validator: (v) => double.tryParse((v ?? '').replaceAll(',', '.')) == null ? 'Inválida' : null))]),
      const SizedBox(height: 12),
      TextFormField(controller: horario, decoration: decoration('Horário', Icons.schedule_outlined), validator: (v) => v == null || v.trim().isEmpty ? 'Informe o horário' : null),
      const SizedBox(height: 12),
      TextFormField(controller: descricao, maxLines: 4, decoration: decoration('Descrição', Icons.notes_outlined), validator: (v) => v == null || v.trim().isEmpty ? 'Informe a descrição' : null),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(onPressed: salvar, icon: const Icon(Icons.save_outlined), label: Text(widget.local == null ? 'Cadastrar' : 'Salvar alterações'))),
    ]))),
  );
}
