import 'package:flutter_test/flutter_test.dart';
import 'package:mapa/models/local.dart';
import 'package:mapa/services/local_service.dart';

void main() {
  test('Local converte para Map e volta sem perder dados', () {
    final local = locaisIniciais[1];
    final copia = Local.fromMap('abc', local.toMap());
    expect(copia.id, 'abc');
    expect(copia.toMap(), local.toMap());
  });

  test('fromMap aceita inteiros e campos ausentes', () {
    final local = Local.fromMap('x', {'nome': 'A', 'avaliacao': 4});
    expect(local.avaliacao, 4.0);
    expect(local.favorito, false);
    expect(local.cidade, '');
    expect(local.telefone, '');
  });

  test('documento antigo sem coordenadas fica no centro da cidade', () {
    final local = Local.fromMap('x', {'nome': 'A', 'cidade': 'Campinas'});
    expect(local.posicao, centroDe('Campinas'));
  });

  test('ponto segurado no mapa escolhe a cidade mais próxima', () {
    for (final l in locaisIniciais) {
      expect(cidadeMaisProxima(l.posicao), l.cidade, reason: l.nome);
    }
  });

  test('T02 pesquisa por "Academia"', () {
    final r = filtrarLocais(locaisIniciais, texto: 'academia');
    expect(r.length, 5);
    expect(r.map((e) => e.distancia), [1.2, 2.4, 3.1, 4.7, 5.2]); // ordenado do mais perto
  });

  test('T03 cidade Campinas', () {
    expect(filtrarLocais(locaisIniciais, cidade: 'Campinas').map((e) => e.nome), ['Restaurante Sabor', 'Hospital Central']);
  });

  test('T04 categoria + cidade + favoritos', () {
    expect(filtrarLocais(locaisIniciais, cidade: 'Jundiaí', categoria: 'Restaurante').single.nome, 'Restaurante Paulista');
    expect(filtrarLocais(locaisIniciais, apenasFavoritos: true).single.nome, 'Smart Fit');
  });
}
