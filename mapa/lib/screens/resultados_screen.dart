import 'package:flutter/material.dart';
import '../dialogs/confirm_delete.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import 'detalhes_screen.dart';

class ResultadosScreen extends StatefulWidget {
  final String cidadeInicial;
  final String pesquisaInicial;
  const ResultadosScreen({super.key, this.cidadeInicial = 'Todas', this.pesquisaInicial = ''});
  @override State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final service = LocalService.instance;
  late final TextEditingController pesquisa;
  late String cidade, categoria;
  bool favoritos = false;

  final cidades = const ['Todas', 'São Paulo', 'Campinas', 'Jundiaí'];
  List<String> get categorias => ['Todos', ...service.listarLocais().map((e) => e.categoria).toSet()];

  @override void initState() { super.initState(); pesquisa = TextEditingController(text: widget.pesquisaInicial); cidade = cidades.contains(widget.cidadeInicial) ? widget.cidadeInicial : 'Todas'; categoria = 'Todos'; }
  @override void dispose() { pesquisa.dispose(); super.dispose(); }

  List<Local> get locais => service.filtrar(texto: pesquisa.text, cidade: cidade, categoria: categoria, apenasFavoritos: favoritos);

  Future<void> abrirFormulario([Local? local]) async {
    await showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => LocalForm(local: local, onSave: (item) { setState(() { if (local == null) service.adicionar(item); else service.atualizar(item); }); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(local == null ? 'Local cadastrado!' : 'Local atualizado!'))); }));
  }

  Future<void> excluir(Local local) async {
    if (!await confirmarExclusao(context, local.nome)) return;
    setState(() => service.excluir(local.id));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local excluído com sucesso.')));
  }

  @override
  Widget build(BuildContext context) {
    final lista = locais;
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados', style: TextStyle(fontWeight: FontWeight.w800)), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => abrirFormulario(), icon: const Icon(Icons.add), label: const Text('Cadastrar')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 0), child: Column(children: [
          TextField(controller: pesquisa, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'Pesquisar...', prefixIcon: const Icon(Icons.search), suffixIcon: pesquisa.text.isEmpty ? null : IconButton(onPressed: () { pesquisa.clear(); setState(() {}); }, icon: const Icon(Icons.clear)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: DropdownButtonFormField<String>(value: cidade, decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined), labelText: 'Cidade', border: OutlineInputBorder()), items: cidades.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => cidade = v!))), const SizedBox(width: 8), Expanded(child: DropdownButtonFormField<String>(value: categoria, decoration: const InputDecoration(prefixIcon: Icon(Icons.filter_list), labelText: 'Categoria', border: OutlineInputBorder()), items: categorias.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => setState(() => categoria = v!)))]),
          const SizedBox(height: 8),
          Row(children: [FilterChip(label: const Text('Somente favoritos'), selected: favoritos, onSelected: (v) => setState(() => favoritos = v)), const Spacer(), Text('${lista.length} resultado(s)', style: TextStyle(color: Colors.grey.shade600, fontSize: 12))]),
        ])),
        const SizedBox(height: 5),
        Expanded(child: lista.isEmpty ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.search_off, size: 52, color: Colors.grey), SizedBox(height: 8), Text('Nenhum local encontrado'), Text('Tente alterar sua pesquisa ou os filtros.')])) : ListView.builder(padding: const EdgeInsets.fromLTRB(16, 6, 16, 100), itemCount: lista.length, itemBuilder: (_, i) { final local = lista[i]; return LocalCard(local: local, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetalhesScreen(localId: local.id))).then((_) => setState(() {})), onEdit: () => abrirFormulario(local), onDelete: () => excluir(local)); })),
      ]),
    );
  }
}
