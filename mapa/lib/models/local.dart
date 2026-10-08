class Local {
  final String id;
  String nome;
  String categoria;
  String cidade;
  double avaliacao;
  double distancia;
  String horario;
  String descricao;
  bool favorito;

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
  });
}
