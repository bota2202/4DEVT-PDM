import 'package:flutter/material.dart';
import '../models/local.dart';

class LocalCard extends StatelessWidget {
  final Local local;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LocalCard({super.key, required this.local, required this.onTap, required this.onEdit, required this.onDelete});

  IconData get icon {
    switch (local.categoria) {
      case 'Academia': return Icons.fitness_center;
      case 'Restaurante': return Icons.restaurant;
      case 'Hospital': return Icons.local_hospital;
      case 'Clínica': return Icons.medical_services;
      case 'Esportes': return Icons.sports_soccer;
      default: return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.grey.shade500, size: 30)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(local.nome, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 3),
              Text(local.categoria, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 5),
              Row(children: [Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600), Text(' ${local.distancia.toStringAsFixed(1)} km', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)), const SizedBox(width: 10), const Icon(Icons.star, size: 14, color: Colors.amber), Text(' ${local.avaliacao.toStringAsFixed(1)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12))]),
            ])),
            PopupMenuButton<String>(
              onSelected: (value) { if (value == 'editar') onEdit(); if (value == 'excluir') onDelete(); },
              itemBuilder: (_) => const [PopupMenuItem(value: 'editar', child: Text('Editar')), PopupMenuItem(value: 'excluir', child: Text('Excluir'))],
              icon: const Icon(Icons.more_vert),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ]),
        ),
      ),
    );
  }
}
