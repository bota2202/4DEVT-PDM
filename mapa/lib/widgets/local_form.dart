import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/local.dart';

class LocalForm extends StatefulWidget {
  final Local? local;
  final LatLng? posicao; // ponto escolhido no mapa (segurar o dedo)
  final String? cidadeInicial;
  final void Function(Local local) onSave;
  const LocalForm({super.key, this.local, this.posicao, this.cidadeInicial, required this.onSave});

  @override State<LocalForm> createState() => _LocalFormState();
}

class _LocalFormState extends State<LocalForm> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nome, horario, avaliacao, distancia, descricao, telefone;
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
    telefone = TextEditingController(text: l?.telefone ?? '');
    if (l != null && !categorias.contains(l.categoria)) categorias.add(l.categoria); // categoria criada fora do app
    categoria = l?.categoria ?? categorias.first;
    final p = widget.posicao;
    cidade = l?.cidade ?? (p != null ? cidadeMaisProxima(p) : (cidades.contains(widget.cidadeInicial) ? widget.cidadeInicial! : cidades.first));
  }

  @override void dispose() { nome.dispose(); horario.dispose(); avaliacao.dispose(); distancia.dispose(); descricao.dispose(); telefone.dispose(); super.dispose(); }

  // Ponto no mapa: o escolhido; ao editar, o atual (se a cidade não mudou); senão, o centro da cidade.
  LatLng get posicaoFinal {
    final old = widget.local;
    if (widget.posicao != null) return widget.posicao!;
    if (old != null && old.cidade == cidade) return old.posicao;
    return centroDe(cidade);
  }

  InputDecoration decoration(String label, IconData icon) => InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));

  void salvar() {
    if (!formKey.currentState!.validate()) return;
    final old = widget.local;
    widget.onSave(Local(id: old?.id ?? '', nome: nome.text.trim(), categoria: categoria, cidade: cidade, avaliacao: double.tryParse(avaliacao.text.replaceAll(',', '.')) ?? 0, distancia: double.tryParse(distancia.text.replaceAll(',', '.')) ?? 0, horario: horario.text.trim(), descricao: descricao.text.trim(), favorito: old?.favorito ?? false, lat: posicaoFinal.latitude, lng: posicaoFinal.longitude, telefone: telefone.text.trim()));
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
      DropdownButtonFormField<String>(initialValue: categoria, decoration: decoration('Categoria', Icons.category_outlined), items: categorias.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => categoria = v!)),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(initialValue: cidade, decoration: decoration('Cidade', Icons.location_city_outlined), items: cidades.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => cidade = v!)),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: TextFormField(controller: avaliacao, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: decoration('Avaliação', Icons.star_border), validator: (v) { final n = double.tryParse((v ?? '').replaceAll(',', '.')); return n == null || n < 0 || n > 5 ? 'De 0 a 5' : null; })), const SizedBox(width: 10), Expanded(child: TextFormField(controller: distancia, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: decoration('Distância (km)', Icons.near_me_outlined), validator: (v) => double.tryParse((v ?? '').replaceAll(',', '.')) == null ? 'Inválida' : null))]),
      const SizedBox(height: 12),
      TextFormField(controller: horario, decoration: decoration('Horário', Icons.schedule_outlined), validator: (v) => v == null || v.trim().isEmpty ? 'Informe o horário' : null),
      const SizedBox(height: 12),
      TextFormField(controller: telefone, keyboardType: TextInputType.phone, decoration: decoration('Telefone (opcional)', Icons.phone_outlined), validator: (v) => (v ?? '').length > 30 ? 'Muito longo' : null),
      const SizedBox(height: 12),
      Row(children: [Icon(Icons.pin_drop_outlined, size: 18, color: Colors.grey.shade600), const SizedBox(width: 6), Expanded(child: Text(widget.posicao != null ? 'Posição: ponto escolhido no mapa' : widget.local != null && widget.local!.cidade == cidade ? 'Posição: mantém a atual no mapa' : 'Posição: centro de $cidade (segure no mapa para escolher o ponto)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)))]),
      const SizedBox(height: 12),
      TextFormField(controller: descricao, maxLines: 4, decoration: decoration('Descrição', Icons.notes_outlined), validator: (v) => v == null || v.trim().isEmpty ? 'Informe a descrição' : null),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(onPressed: salvar, icon: const Icon(Icons.save_outlined), label: Text(widget.local == null ? 'Cadastrar' : 'Salvar alterações'))),
    ]))),
  );
}
