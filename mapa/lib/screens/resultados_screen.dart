import 'package:flutter/material.dart';
import '../dialogs/confirm_delete.dart';
import '../dialogs/feedback.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import 'detalhes_screen.dart';

class ResultadosScreen extends StatefulWidget {
  final String cidadeInicial;
  final String pesquisaInicial;
  final bool apenasFavoritos;
  const ResultadosScreen({super.key, this.cidadeInicial = 'Todas', this.pesquisaInicial = '', this.apenasFavoritos = false});
  @override State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final service = LocalService();
  late final Stream<List<Local>> stream = service.listarLocais();
  late final TextEditingController pesquisa;
  late String cidade, categoria;
  late bool favoritos = widget.apenasFavoritos;

  final cidades = const ['Todas', 'São Paulo', 'Campinas', 'Jundiaí'];

  @override void initState() { super.initState(); pesquisa = TextEditingController(text: widget.pesquisaInicial); cidade = cidades.contains(widget.cidadeInicial) ? widget.cidadeInicial : 'Todas'; categoria = 'Todos'; }
  @override void dispose() { pesquisa.dispose(); super.dispose(); }

  Future<void> abrirFormulario([Local? local]) async {
    await showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => LocalForm(local: local, cidadeInicial: cidade, onSave: (item) => executarComMensagem(context, local == null ? service.adicionar(item) : service.atualizar(item), local == null ? 'Local cadastrado!' : 'Local atualizado!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados', style: TextStyle(fontWeight: FontWeight.w800)), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => abrirFormulario(), icon: const Icon(Icons.add), label: const Text('Cadastrar')),
      body: StreamBuilder<List<Local>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const _Mensagem(icon: Icons.cloud_off, titulo: 'Erro ao carregar os locais.', texto: 'Verifique a conexão e a configuração do Firebase.');
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final todos = snapshot.data!;
          final categorias = ['Todos', ...({categoria, ...todos.map((e) => e.categoria)}..remove('Todos')).toList()..sort()];
          final lista = filtrarLocais(todos, texto: pesquisa.text, cidade: cidade, categoria: categoria, apenasFavoritos: favoritos);
          return Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 0), child: Column(children: [
              TextField(controller: pesquisa, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'Pesquisar...', prefixIcon: const Icon(Icons.search), suffixIcon: pesquisa.text.isEmpty ? null : IconButton(onPressed: () { pesquisa.clear(); setState(() {}); }, icon: const Icon(Icons.clear)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
              const SizedBox(height: 10),
              Row(children: [Expanded(child: DropdownButtonFormField<String>(initialValue: cidade, decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined), labelText: 'Cidade', border: OutlineInputBorder()), items: cidades.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => cidade = v!))), const SizedBox(width: 8), Expanded(child: DropdownButtonFormField<String>(initialValue: categoria, decoration: const InputDecoration(prefixIcon: Icon(Icons.filter_list), labelText: 'Categoria', border: OutlineInputBorder()), items: categorias.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => setState(() => categoria = v!)))]),
              const SizedBox(height: 8),
              Row(children: [FilterChip(label: const Text('Somente favoritos'), selected: favoritos, onSelected: (v) => setState(() => favoritos = v)), const Spacer(), Text('${lista.length} resultado(s)', style: TextStyle(color: Colors.grey.shade600, fontSize: 12))]),
            ])),
            const SizedBox(height: 5),
            Expanded(child: lista.isEmpty
              ? const _Mensagem(icon: Icons.search_off, titulo: 'Nenhum local encontrado', texto: 'Tente alterar sua pesquisa ou os filtros.')
              : ListView.builder(padding: const EdgeInsets.fromLTRB(16, 6, 16, 100), itemCount: lista.length, itemBuilder: (_, i) { final local = lista[i]; return LocalCard(local: local, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetalhesScreen(localId: local.id))), onEdit: () => abrirFormulario(local), onDelete: () => excluirLocal(context, local)); })),
          ]);
        },
      ),
    );
  }
}

class _Mensagem extends StatelessWidget {
  final IconData icon; final String titulo, texto;
  const _Mensagem({required this.icon, required this.titulo, required this.texto});
  @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 52, color: Colors.grey), const SizedBox(height: 8), Text(titulo), Text(texto, textAlign: TextAlign.center)]));
}
