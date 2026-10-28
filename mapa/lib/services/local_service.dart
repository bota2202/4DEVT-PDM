import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/local.dart';

class LocalService {
  final CollectionReference<Map<String, dynamic>> locais = FirebaseFirestore.instance.collection('locais');

  // Read: a lista se atualiza sozinha a cada alteração no Firestore.
  Stream<List<Local>> listarLocais() {
    return locais.snapshots().map((snapshot) => snapshot.docs.map((doc) => Local.fromMap(doc.id, doc.data())).toList());
  }

  // Read de um único documento (tela de detalhes). null = documento excluído.
  Stream<Local?> observarLocal(String id) {
    return locais.doc(id).snapshots().map((doc) => doc.exists ? Local.fromMap(doc.id, doc.data()!) : null);
  }

  Future<void> adicionar(Local local) => locais.add(local.toMap());

  Future<void> atualizar(Local local) => locais.doc(local.id).update(local.toMap());

  Future<void> excluir(String id) => locais.doc(id).delete();

  Future<void> alterarFavorito(String id, bool favorito) => locais.doc(id).update({'favorito': favorito});

  // Coleção vazia: cadastra os 10 locais iniciais.
  // Locais iniciais antigos sem coordenadas: completa lat/lng/telefone.
  Future<void> prepararDados() async {
    // Pergunta ao servidor (não ao cache) para não duplicar os dados se abrir offline.
    final atuais = await locais.get(const GetOptions(source: Source.server));
    final batch = FirebaseFirestore.instance.batch();
    if (atuais.docs.isEmpty) {
      for (final local in locaisIniciais) {
        batch.set(locais.doc(), local.toMap());
      }
    } else {
      for (final doc in atuais.docs.where((d) => !d.data().containsKey('lat'))) {
        final inicial = locaisIniciais.where((l) => l.nome == doc.data()['nome']).firstOrNull;
        if (inicial != null) batch.update(doc.reference, {'lat': inicial.lat, 'lng': inicial.lng, 'telefone': inicial.telefone});
      }
    }
    await batch.commit();
  }
}

// Filtro em memória (seção 16 do tutorial): os dados vêm do Firestore e o Flutter filtra.
List<Local> filtrarLocais(List<Local> locais, {String texto = '', String cidade = 'Todas', String categoria = 'Todos', bool apenasFavoritos = false}) {
  final termo = texto.trim().toLowerCase();
  return locais.where((local) {
    final textoOk = termo.isEmpty || local.nome.toLowerCase().contains(termo) || local.categoria.toLowerCase().contains(termo);
    final cidadeOk = cidade == 'Todas' || local.cidade == cidade;
    final categoriaOk = categoria == 'Todos' || local.categoria == categoria;
    final favoritoOk = !apenasFavoritos || local.favorito;
    return textoOk && cidadeOk && categoriaOk && favoritoOk;
  }).toList()..sort((a, b) => a.distancia.compareTo(b.distancia)); // mais perto primeiro
}

final locaisIniciais = [
  Local(id: '', nome: 'Academia Fitness', categoria: 'Academia', cidade: 'São Paulo', avaliacao: 4.8, distancia: 1.2, horario: '06:00 - 22:00', descricao: 'Academia completa com musculação, funcional, aulas coletivas e personal trainer.', lat: -23.5614, lng: -46.6559, telefone: '(11) 3251-0001'),
  Local(id: '', nome: 'Smart Fit', categoria: 'Academia', cidade: 'São Paulo', avaliacao: 4.5, distancia: 2.4, horario: '05:00 - 23:00', descricao: 'Espaço moderno para treino, cardio e musculação.', favorito: true, lat: -23.5475, lng: -46.6361, telefone: '(11) 3251-0002'),
  Local(id: '', nome: 'Body Center', categoria: 'Academia', cidade: 'São Paulo', avaliacao: 4.3, distancia: 3.1, horario: '06:00 - 21:00', descricao: 'Centro de treinamento com equipamentos modernos e acompanhamento profissional.', lat: -23.5869, lng: -46.6823, telefone: '(11) 3251-0003'),
  Local(id: '', nome: 'Proforma Academia', categoria: 'Academia', cidade: 'São Paulo', avaliacao: 4.0, distancia: 4.7, horario: '06:00 - 22:00', descricao: 'Academia para todos os níveis, com aulas e musculação.', lat: -23.5329, lng: -46.6395, telefone: '(11) 3251-0004'),
  Local(id: '', nome: 'Iron Gym', categoria: 'Academia', cidade: 'São Paulo', avaliacao: 4.2, distancia: 5.2, horario: '07:00 - 22:00', descricao: 'Ambiente focado em musculação e treinamento de força.', lat: -23.5980, lng: -46.6370, telefone: '(11) 3251-0005'),
  Local(id: '', nome: 'Restaurante Sabor', categoria: 'Restaurante', cidade: 'Campinas', avaliacao: 4.7, distancia: 1.8, horario: '11:00 - 23:00', descricao: 'Restaurante com pratos brasileiros, opções executivas e ambiente familiar.', lat: -22.9056, lng: -47.0608, telefone: '(19) 3232-0006'),
  Local(id: '', nome: 'Hospital Central', categoria: 'Hospital', cidade: 'Campinas', avaliacao: 4.6, distancia: 2.7, horario: '24 horas', descricao: 'Atendimento médico e serviços hospitalares de emergência e consultas.', lat: -22.8960, lng: -47.0580, telefone: '(19) 3232-0007'),
  Local(id: '', nome: 'Clínica Vida', categoria: 'Clínica', cidade: 'Jundiaí', avaliacao: 4.9, distancia: 1.5, horario: '07:00 - 19:00', descricao: 'Clínica multidisciplinar com atendimento por especialistas.', lat: -23.1880, lng: -46.8840, telefone: '(11) 4521-0008'),
  Local(id: '', nome: 'Restaurante Paulista', categoria: 'Restaurante', cidade: 'Jundiaí', avaliacao: 4.4, distancia: 3.3, horario: '11:30 - 22:30', descricao: 'Comida caseira, pratos executivos e opções para toda a família.', lat: -23.1950, lng: -46.8990, telefone: '(11) 4521-0009'),
  Local(id: '', nome: 'Arena Esportes', categoria: 'Esportes', cidade: 'Jundiaí', avaliacao: 4.1, distancia: 4.2, horario: '08:00 - 22:00', descricao: 'Complexo esportivo com quadras e espaços para atividades físicas.', lat: -23.1760, lng: -46.9100, telefone: '(11) 4521-0010'),
];
