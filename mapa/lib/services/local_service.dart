import '../models/local.dart';

class LocalService {
  LocalService._();
  static final LocalService instance = LocalService._();

  final List<Local> _locais = [
    Local(id: '1', nome: 'Academia Fitness', categoria: 'Academia', cidade: 'São Paulo', avaliacao: 4.8, distancia: 1.2, horario: '06:00 - 22:00', descricao: 'Academia completa com musculação, funcional, aulas coletivas e personal trainer.', favorito: false),
    Local(id: '2', nome: 'Smart Fit', categoria: 'Academia', cidade: 'São Paulo', avaliacao: 4.5, distancia: 2.4, horario: '05:00 - 23:00', descricao: 'Espaço moderno para treino, cardio e musculação.', favorito: true),
    Local(id: '3', nome: 'Body Center', categoria: 'Academia', cidade: 'São Paulo', avaliacao: 4.3, distancia: 3.1, horario: '06:00 - 21:00', descricao: 'Centro de treinamento com equipamentos modernos e acompanhamento profissional.'),
    Local(id: '4', nome: 'Proforma Academia', categoria: 'Academia', cidade: 'São Paulo', avaliacao: 4.0, distancia: 4.7, horario: '06:00 - 22:00', descricao: 'Academia para todos os níveis, com aulas e musculação.'),
    Local(id: '5', nome: 'Iron Gym', categoria: 'Academia', cidade: 'São Paulo', avaliacao: 4.2, distancia: 5.2, horario: '07:00 - 22:00', descricao: 'Ambiente focado em musculação e treinamento de força.'),
    Local(id: '6', nome: 'Restaurante Sabor', categoria: 'Restaurante', cidade: 'Campinas', avaliacao: 4.7, distancia: 1.8, horario: '11:00 - 23:00', descricao: 'Restaurante com pratos brasileiros, opções executivas e ambiente familiar.'),
    Local(id: '7', nome: 'Hospital Central', categoria: 'Hospital', cidade: 'Campinas', avaliacao: 4.6, distancia: 2.7, horario: '24 horas', descricao: 'Atendimento médico e serviços hospitalares de emergência e consultas.'),
    Local(id: '8', nome: 'Clínica Vida', categoria: 'Clínica', cidade: 'Jundiaí', avaliacao: 4.9, distancia: 1.5, horario: '07:00 - 19:00', descricao: 'Clínica multidisciplinar com atendimento por especialistas.'),
    Local(id: '9', nome: 'Restaurante Paulista', categoria: 'Restaurante', cidade: 'Jundiaí', avaliacao: 4.4, distancia: 3.3, horario: '11:30 - 22:30', descricao: 'Comida caseira, pratos executivos e opções para toda a família.'),
    Local(id: '10', nome: 'Arena Esportes', categoria: 'Esportes', cidade: 'Jundiaí', avaliacao: 4.1, distancia: 4.2, horario: '08:00 - 22:00', descricao: 'Complexo esportivo com quadras e espaços para atividades físicas.'),
  ];

  List<Local> listarLocais() => List.unmodifiable(_locais);

  void adicionar(Local local) => _locais.add(local);

  void atualizar(Local local) {
    final index = _locais.indexWhere((item) => item.id == local.id);
    if (index != -1) _locais[index] = local;
  }

  void excluir(String id) => _locais.removeWhere((local) => local.id == id);

  void alterarFavorito(String id) {
    final local = _locais.firstWhere((item) => item.id == id);
    local.favorito = !local.favorito;
  }

  List<Local> filtrar({String texto = '', String cidade = 'Todas', String categoria = 'Todos', bool apenasFavoritos = false}) {
    final termo = texto.trim().toLowerCase();
    return _locais.where((local) {
      final textoOk = termo.isEmpty || local.nome.toLowerCase().contains(termo) || local.categoria.toLowerCase().contains(termo);
      final cidadeOk = cidade == 'Todas' || local.cidade == cidade;
      final categoriaOk = categoria == 'Todos' || local.categoria == categoria;
      final favoritoOk = !apenasFavoritos || local.favorito;
      return textoOk && cidadeOk && categoriaOk && favoritoOk;
    }).toList();
  }
}
