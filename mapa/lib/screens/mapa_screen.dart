import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../dialogs/confirm_delete.dart';
import '../dialogs/feedback.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import 'detalhes_screen.dart';
import 'resultados_screen.dart';

// "Ver no mapa" (tela de detalhes) coloca o local aqui; o mapa centraliza nele.
final focoNoMapa = ValueNotifier<Local?>(null);

const _tilesMapa = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _tilesSatelite = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});
  @override State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final locais = LocalService().listarLocais();
  final pesquisa = TextEditingController();
  final mapa = MapController();
  String cidade = 'São Paulo';
  String? selecionadoId;
  LatLng? minhaPosicao;
  bool satelite = false;

  @override
  void initState() {
    super.initState();
    focoNoMapa.addListener(_focar);
  }

  @override
  void dispose() {
    focoNoMapa.removeListener(_focar);
    pesquisa.dispose();
    mapa.dispose();
    super.dispose();
  }

  void _focar() {
    final local = focoNoMapa.value;
    if (local == null) return;
    focoNoMapa.value = null;
    setState(() { cidade = local.cidade; selecionadoId = local.id; });
    mapa.move(local.posicao, 16);
  }

  void trocarCidade(String nova) {
    setState(() { cidade = nova; selecionadoId = null; });
    mapa.move(centroDe(nova), 13);
  }

  Future<void> minhaLocalizacao() async {
    if (!await Geolocator.isLocationServiceEnabled()) throw 'a localização do aparelho está desligada';
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) permissao = await Geolocator.requestPermission();
    if (permissao == LocationPermission.denied || permissao == LocationPermission.deniedForever) throw 'permissão de localização negada';
    final pos = await Geolocator.getCurrentPosition();
    setState(() => minhaPosicao = LatLng(pos.latitude, pos.longitude));
    mapa.move(minhaPosicao!, 15);
  }

  void abrirResultados({bool favoritos = false}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultadosScreen(cidadeInicial: favoritos ? 'Todas' : cidade, pesquisaInicial: favoritos ? '' : pesquisa.text, apenasFavoritos: favoritos)));
  }

  void abrirDetalhes(Local local) => Navigator.push(context, MaterialPageRoute(builder: (_) => DetalhesScreen(localId: local.id)));

  void cadastrarAqui(LatLng ponto) {
    showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => LocalForm(posicao: ponto, onSave: (local) => executarComMensagem(context, LocalService().adicionar(local), 'Local cadastrado!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(18, 12, 18, 8), child: Column(children: [
          Row(children: [const Icon(Icons.location_on_outlined, size: 24), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cidade selecionada', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), DropdownButtonHideUnderline(child: DropdownButton<String>(value: cidade, isDense: true, items: centrosCidades.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => trocarCidade(v!)))]))]),
          const SizedBox(height: 6),
          TextField(controller: pesquisa, onChanged: (_) => setState(() {}), onSubmitted: (_) => abrirResultados(), decoration: InputDecoration(hintText: 'Buscar por nome ou categoria...', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(tooltip: 'Ver resultados', onPressed: abrirResultados, icon: const Icon(Icons.arrow_forward)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)), filled: true, fillColor: Colors.grey.shade50)),
        ])),
        Expanded(child: StreamBuilder<List<Local>>(
          stream: locais,
          builder: (context, snapshot) {
            final todos = snapshot.data ?? [];
            final visiveis = filtrarLocais(todos, texto: pesquisa.text);
            final daCidade = visiveis.where((l) => l.cidade == cidade).length;
            final selecionado = todos.where((l) => l.id == selecionadoId).firstOrNull;
            return Stack(children: [
              FlutterMap(
                mapController: mapa,
                options: MapOptions(
                  initialCenter: centroDe(cidade),
                  initialZoom: 13,
                  onTap: (_, _) => setState(() => selecionadoId = null),
                  onLongPress: (_, ponto) => cadastrarAqui(ponto),
                  onSecondaryTap: (_, ponto) => cadastrarAqui(ponto), // botão direito no PC
                ),
                children: [
                  TileLayer(urlTemplate: satelite ? _tilesSatelite : _tilesMapa, userAgentPackageName: 'com.example.mapa'),
                  MarkerLayer(markers: [
                    if (minhaPosicao != null) Marker(point: minhaPosicao!, width: 24, height: 24, child: Container(decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)]))),
                    for (final l in visiveis) Marker(
                      point: l.posicao, width: 44, height: 44, alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => setState(() => selecionadoId = l.id),
                        child: Tooltip(message: l.nome, child: Icon(Icons.location_on, size: l.id == selecionadoId ? 44 : 36, color: l.favorito ? Colors.red.shade700 : Colors.black87, shadows: const [Shadow(blurRadius: 4, color: Colors.black38)])),
                      ),
                    ),
                  ]),
                  RichAttributionWidget(alignment: AttributionAlignment.bottomLeft, attributions: [TextSourceAttribution(satelite ? 'Esri World Imagery' : 'OpenStreetMap', onTap: () => launchUrl(Uri.parse(satelite ? 'https://www.esri.com' : 'https://www.openstreetmap.org/copyright')))]),
                ],
              ),
              if (snapshot.hasError) const Positioned(top: 10, left: 14, right: 14, child: Card(color: Color(0xffffebee), child: Padding(padding: EdgeInsets.all(10), child: Text('Erro ao carregar os locais do banco.')))),
              if (!snapshot.hasData && !snapshot.hasError) const Positioned(top: 10, left: 0, right: 0, child: Center(child: CircularProgressIndicator())),
              Positioned(top: 10, left: 14, child: Material(color: Colors.white, elevation: 2, borderRadius: BorderRadius.circular(8), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Text('Segure (ou botão direito) no mapa para cadastrar', style: TextStyle(fontSize: 11))))),
              Positioned(right: 12, bottom: selecionado == null ? 80 : 190, child: Column(children: [
                FloatingActionButton.small(heroTag: 'locate', tooltip: 'Minha localização', onPressed: () => executarComMensagem(context, minhaLocalizacao(), 'Você está aqui.'), backgroundColor: Colors.white, foregroundColor: Colors.black87, child: const Icon(Icons.my_location)),
                const SizedBox(height: 8),
                FloatingActionButton.small(heroTag: 'layers', tooltip: satelite ? 'Mapa' : 'Satélite', onPressed: () => setState(() => satelite = !satelite), backgroundColor: Colors.white, foregroundColor: Colors.black87, child: Icon(satelite ? Icons.map_outlined : Icons.satellite_alt_outlined)),
              ])),
              if (selecionado != null) Positioned(left: 14, right: 14, bottom: 72, child: Material(elevation: 4, borderRadius: BorderRadius.circular(14), child: LocalCard(local: selecionado, onTap: () => abrirDetalhes(selecionado), onEdit: () => showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => LocalForm(local: selecionado, onSave: (l) => executarComMensagem(context, LocalService().atualizar(l), 'Local atualizado!'))), onDelete: () => excluirLocal(context, selecionado)))),
              Positioned(left: 14, right: 14, bottom: 14, child: FilledButton.icon(onPressed: abrirResultados, icon: const Icon(Icons.list_alt), label: Text(snapshot.hasData ? 'Ver $daCidade ${daCidade == 1 ? 'resultado' : 'resultados'} em $cidade' : 'Ver resultados'))),
            ]);
          },
        )),
        NavigationBar(selectedIndex: 0, height: 66, onDestinationSelected: (i) { if (i == 1) abrirResultados(); if (i == 2) abrirResultados(favoritos: true); }, destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Lista'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
        ]),
      ])),
    );
  }
}
