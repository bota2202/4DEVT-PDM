import 'package:flutter/material.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import 'resultados_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});
  @override State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final service = LocalService.instance;
  final pesquisa = TextEditingController();
  String cidade = 'São Paulo';

  @override void dispose() { pesquisa.dispose(); super.dispose(); }

  void abrirResultados() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultadosScreen(cidadeInicial: cidade, pesquisaInicial: pesquisa.text))).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(18, 12, 18, 8), child: Column(children: [
          Row(children: [const Icon(Icons.location_on_outlined, size: 24), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cidade selecionada', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), DropdownButtonHideUnderline(child: DropdownButton<String>(value: cidade, isDense: true, items: const [DropdownMenuItem(value: 'São Paulo', child: Text('São Paulo')), DropdownMenuItem(value: 'Campinas', child: Text('Campinas')), DropdownMenuItem(value: 'Jundiaí', child: Text('Jundiaí'))], onChanged: (v) => setState(() => cidade = v!))) ]))]),
          const SizedBox(height: 6),
          TextField(controller: pesquisa, onSubmitted: (_) => abrirResultados(), decoration: InputDecoration(hintText: 'Buscar locais, endereços ou categorias...', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: abrirResultados, icon: const Icon(Icons.arrow_forward)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)), filled: true, fillColor: Colors.grey.shade50)),
        ])),
        Expanded(child: Stack(children: [
          const _FakeMap(),
          Positioned(top: 20, left: 16, child: _MapLabel(text: 'Academia Fitness', icon: Icons.fitness_center)),
          Positioned(top: 105, right: 35, child: _MapMarker(color: Colors.red.shade700)),
          Positioned(top: 185, left: 48, child: _MapMarker(color: Colors.black87)),
          Positioned(top: 250, right: 65, child: _MapMarker(color: Colors.black87)),
          Positioned(bottom: 135, left: 90, child: _MapMarker(color: Colors.black87)),
          Positioned(
            top: 180,
            left: MediaQuery.of(context).size.width / 2 - 18,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: .15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ),
          ),
          Positioned(right: 12, bottom: 95, child: Column(children: [FloatingActionButton.small(heroTag: 'locate', onPressed: () {}, backgroundColor: Colors.white, foregroundColor: Colors.black87, child: const Icon(Icons.my_location)), const SizedBox(height: 8), FloatingActionButton.small(heroTag: 'layers', onPressed: () {}, backgroundColor: Colors.white, foregroundColor: Colors.black87, child: const Icon(Icons.layers_outlined))])),
          Positioned(left: 14, right: 14, bottom: 14, child: FilledButton.icon(onPressed: abrirResultados, icon: const Icon(Icons.list_alt), label: Text('Ver ${service.filtrar(cidade: cidade).length} resultados'))),
        ])),
        const _BottomNav(selected: 0),
      ])),
    );
  }
}

class _FakeMap extends StatelessWidget { const _FakeMap(); @override Widget build(BuildContext context) => CustomPaint(painter: _MapPainter(), child: const SizedBox.expand()); }
class _MapPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xffe8ebe9); canvas.drawRect(Offset.zero & size, bg);
    final blocks = Paint()..color = const Color(0xfff6f7f5)..strokeWidth = 42..style = PaintingStyle.stroke;
    for (var i = -1; i < 7; i++) { canvas.drawLine(Offset(i * 85.0, 0), Offset(i * 85.0 + 180, size.height), blocks); }
    for (var i = -1; i < 7; i++) { canvas.drawLine(Offset(0, i * 75.0), Offset(size.width, i * 75.0 + 100), blocks); }
    final roads = Paint()..color = Colors.white..strokeWidth = 3;
    canvas.drawLine(Offset(size.width * .1, size.height), Offset(size.width * .8, 0), roads);
    canvas.drawLine(Offset(0, size.height * .3), Offset(size.width, size.height * .65), roads);
    canvas.drawLine(Offset(size.width * .3, 0), Offset(size.width * .65, size.height), roads);
    final park = Paint()..color = const Color(0xffd7e4d2); canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-30, size.height*.62, size.width*.4, size.height*.32), const Radius.circular(30)), park);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class _MapMarker extends StatelessWidget { final Color color; const _MapMarker({required this.color}); @override Widget build(BuildContext context) => Icon(Icons.location_on, color: color, size: 28); }
class _MapLabel extends StatelessWidget { final String text; final IconData icon; const _MapLabel({required this.text, required this.icon}); @override Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(8), elevation: 2, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: Row(children: [Icon(icon, size: 15), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]))); }
class _BottomNav extends StatelessWidget { final int selected; const _BottomNav({required this.selected}); @override Widget build(BuildContext context) => NavigationBar(selectedIndex: selected, onDestinationSelected: (_) {}, height: 66, destinations: const [NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'), NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil')]); }
