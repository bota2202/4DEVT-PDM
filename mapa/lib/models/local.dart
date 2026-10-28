import 'package:latlong2/latlong.dart';

const centrosCidades = {
  'São Paulo': LatLng(-23.5505, -46.6333),
  'Campinas': LatLng(-22.9099, -47.0626),
  'Jundiaí': LatLng(-23.1857, -46.8978),
};

LatLng centroDe(String cidade) => centrosCidades[cidade] ?? centrosCidades['São Paulo']!;

String cidadeMaisProxima(LatLng ponto) {
  const distancia = Distance();
  return centrosCidades.entries.reduce((a, b) => distancia(ponto, a.value) <= distancia(ponto, b.value) ? a : b).key;
}

class Local {
  final String id;
  final String nome;
  final String categoria;
  final String cidade;
  final double avaliacao;
  final double distancia;
  final String horario;
  final String descricao;
  final bool favorito;
  final double lat;
  final double lng;
  final String telefone;

  Local({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.cidade,
    required this.avaliacao,
    required this.distancia,
    required this.horario,
    required this.descricao,
    this.favorito = false,
    double? lat,
    double? lng,
    this.telefone = '',
  })  : lat = lat ?? centroDe(cidade).latitude,
        lng = lng ?? centroDe(cidade).longitude;

  LatLng get posicao => LatLng(lat, lng);

  factory Local.fromMap(String id, Map<String, dynamic> data) {
    return Local(
      id: id,
      nome: data['nome'] ?? '',
      categoria: data['categoria'] ?? '',
      cidade: data['cidade'] ?? '',
      avaliacao: (data['avaliacao'] ?? 0).toDouble(),
      distancia: (data['distancia'] ?? 0).toDouble(),
      horario: data['horario'] ?? '',
      descricao: data['descricao'] ?? '',
      favorito: data['favorito'] ?? false,
      // Documentos antigos sem coordenadas ficam no centro da cidade.
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      telefone: data['telefone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categoria': categoria,
      'cidade': cidade,
      'avaliacao': avaliacao,
      'distancia': distancia,
      'horario': horario,
      'descricao': descricao,
      'favorito': favorito,
      'lat': lat,
      'lng': lng,
      'telefone': telefone,
    };
  }
}
