import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import '../dialogs/confirm_delete.dart';
import '../dialogs/feedback.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import 'mapa_screen.dart';

class DetalhesScreen extends StatefulWidget {
  final String localId;
  const DetalhesScreen({super.key, required this.localId});
  @override State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final service = LocalService();
  late final Stream<Local?> stream = service.observarLocal(widget.localId);

  void alternarFavorito(Local item) => executarComMensagem(context, service.alterarFavorito(item.id, !item.favorito), item.favorito ? 'Removido dos favoritos.' : 'Adicionado aos favoritos!');

  void editar(Local item) => showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => LocalForm(local: item, onSave: (l) => executarComMensagem(context, service.atualizar(l), 'Local atualizado!')));

  Future<void> excluir(Local item) async {
    if (await excluirLocal(context, item) && mounted) Navigator.pop(context);
  }

  Future<void> abrirLink(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) throw 'não foi possível abrir $uri';
  }

  void ligar(Local item) => executarComMensagem(context, abrirLink(Uri(scheme: 'tel', path: item.telefone.replaceAll(RegExp(r'[^0-9+]'), ''))), 'Abrindo o discador...');

  void comoChegar(Local item) => executarComMensagem(context, abrirLink(Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': '${item.lat},${item.lng}'})), 'Abrindo a rota no Google Maps...');

  Future<void> compartilhar(Local item) async {
    final texto = '${item.nome} (${item.categoria})\n${item.cidade} · ${item.horario}${item.telefone.isEmpty ? '' : ' · ${item.telefone}'}\nhttps://www.google.com/maps/search/?api=1&query=${item.lat},${item.lng}';
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Clipboard.setData(ClipboardData(text: texto));
      messenger.showSnackBar(const SnackBar(content: Text('Dados do local copiados. É só colar onde quiser.')));
    } catch (_) {
      // Navegador bloqueou a área de transferência: mostra o texto para copiar à mão.
      if (!mounted) return;
      showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Compartilhar'), content: SelectableText(texto), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]));
    }
  }

  void verNoMapa(Local item) {
    focoNoMapa.value = item;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Local?>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Erro ao carregar o local.')));
        if (snapshot.connectionState == ConnectionState.waiting) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        final item = snapshot.data;
        if (item == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Local não encontrado.')));
        return _detalhes(item);
      },
    );
  }

  Widget _detalhes(Local item) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), actions: [
        IconButton(tooltip: 'Favorito', onPressed: () => alternarFavorito(item), icon: Icon(item.favorito ? Icons.favorite : Icons.favorite_border, color: item.favorito ? Colors.red : null)),
        IconButton(tooltip: 'Editar', onPressed: () => editar(item), icon: const Icon(Icons.edit_outlined)),
        IconButton(tooltip: 'Excluir', onPressed: () => excluir(item), icon: const Icon(Icons.delete_outline)),
      ]),
      body: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 210, child: FlutterMap(
          key: ValueKey(item.posicao), // recentraliza se a posição mudar
          options: MapOptions(initialCenter: item.posicao, initialZoom: 16, interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), onTap: (_, _) => verNoMapa(item)),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.mapa'),
            MarkerLayer(markers: [Marker(point: item.posicao, width: 44, height: 44, alignment: Alignment.topCenter, child: Icon(Icons.location_on, size: 44, color: Colors.red.shade700))]),
          ],
        )),
        Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(iconeCategoria(item.categoria), color: Colors.grey.shade600), const SizedBox(width: 8), Expanded(child: Text(item.nome, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)))]),
          const SizedBox(height: 3), Text('${item.categoria} · ${item.cidade}', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 10), Row(children: [const Icon(Icons.star, size: 19, color: Colors.amber), Text(' ${item.avaliacao.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w700))]),
          const SizedBox(height: 14),
          Wrap(spacing: 20, runSpacing: 8, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on_outlined, size: 19), const SizedBox(width: 5), Text('${item.distancia.toStringAsFixed(1)} km')]),
            Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.schedule_outlined, size: 19), const SizedBox(width: 5), Text(item.horario)]),
            if (item.telefone.isNotEmpty) Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.phone_outlined, size: 19), const SizedBox(width: 5), Text(item.telefone)]),
          ]),
          const Divider(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Action(icon: Icons.phone_outlined, label: 'Ligar', onTap: item.telefone.isEmpty ? null : () => ligar(item)),
            _Action(icon: Icons.near_me_outlined, label: 'Como chegar', onTap: () => comoChegar(item)),
            _Action(icon: Icons.share_outlined, label: 'Compartilhar', onTap: () => compartilhar(item)),
          ]),
          const Divider(height: 30),
          const Text('Sobre', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 7), Text(item.descricao, style: TextStyle(height: 1.45, color: Colors.grey.shade700)),
          const SizedBox(height: 24), SizedBox(width: double.infinity, height: 48, child: FilledButton.icon(onPressed: () => verNoMapa(item), icon: const Icon(Icons.location_on_outlined), label: const Text('Ver no mapa'))), const SizedBox(height: 28),
        ])),
      ])),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback? onTap;
  const _Action({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cor = onTap == null ? Colors.grey.shade400 : Colors.black87;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: Column(children: [CircleAvatar(backgroundColor: Colors.grey.shade100, child: Icon(icon, color: cor)), const SizedBox(height: 5), Text(onTap == null ? 'Sem telefone' : label, style: TextStyle(fontSize: 11, color: cor))])));
  }
}
