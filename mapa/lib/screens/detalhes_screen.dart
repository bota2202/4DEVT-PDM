import 'package:flutter/material.dart';
import '../models/local.dart';
import '../services/local_service.dart';

class DetalhesScreen extends StatefulWidget {
  final String localId;
  const DetalhesScreen({super.key, required this.localId});
  @override State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final service = LocalService.instance;
  Local? get local { try { return service.listarLocais().firstWhere((e) => e.id == widget.localId); } catch (_) { return null; } }

  IconData getIcon(String categoria) { switch (categoria) { case 'Academia': return Icons.fitness_center; case 'Restaurante': return Icons.restaurant; case 'Hospital': return Icons.local_hospital; case 'Clínica': return Icons.medical_services; case 'Esportes': return Icons.sports_soccer; default: return Icons.place; } }

  @override
  Widget build(BuildContext context) {
    final item = local;
    if (item == null) return const Scaffold(body: Center(child: Text('Local não encontrado.')));
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), actions: [IconButton(onPressed: () { setState(() => service.alterarFavorito(item.id)); }, icon: Icon(item.favorito ? Icons.favorite : Icons.favorite_border, color: item.favorito ? Colors.red : null)), IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined))]),
      body: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 210, width: double.infinity, color: Colors.grey.shade200, child: Center(child: Icon(getIcon(item.categoria), size: 72, color: Colors.grey.shade400))),
        Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.nome, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3), Text(item.categoria, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 10), Row(children: [const Icon(Icons.star, size: 19, color: Colors.amber), Text(' ${item.avaliacao.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(width: 8), Text('(24 avaliações)', style: TextStyle(color: Colors.grey.shade600))]),
          const SizedBox(height: 14),
          Row(children: [const Icon(Icons.location_on_outlined, size: 19), const SizedBox(width: 5), Text('${item.distancia.toStringAsFixed(1)} km'), const SizedBox(width: 20), const Icon(Icons.schedule_outlined, size: 19), const SizedBox(width: 5), Expanded(child: Text(item.horario))]),
          const Divider(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_Action(icon: Icons.phone_outlined, label: 'Ligar', onTap: () {}), _Action(icon: Icons.near_me_outlined, label: 'Como chegar', onTap: () {}), _Action(icon: Icons.calendar_month_outlined, label: 'Agendar', onTap: () {})]),
          const Divider(height: 30),
          const Text('Sobre', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 7), Text(item.descricao, style: TextStyle(height: 1.45, color: Colors.grey.shade700)),
          const SizedBox(height: 24), const Text('Fotos', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 10), Row(children: List.generate(3, (_) => Expanded(child: Container(height: 82, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.image_outlined, color: Colors.grey.shade400))))),
          const SizedBox(height: 16), SizedBox(width: double.infinity, height: 48, child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.location_on_outlined), label: const Text('Ver no mapa'))), const SizedBox(height: 28),
        ])),
      ])),
    );
  }
}
class _Action extends StatelessWidget { final IconData icon; final String label; final VoidCallback onTap; const _Action({required this.icon, required this.label, required this.onTap}); @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: Column(children: [CircleAvatar(backgroundColor: Colors.grey.shade100, child: Icon(icon, color: Colors.black87)), const SizedBox(height: 5), Text(label, style: const TextStyle(fontSize: 11))]))); }
