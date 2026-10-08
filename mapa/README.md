# Mapa de Locais — versão no projeto original

Projeto feito diretamente sobre o projeto Flutter enviado, mantendo Android/iOS e substituindo o conteúdo padrão do `lib/` pela aplicação da atividade.

## Importante
Esta versão **não utiliza Firebase nem banco de dados**. Os dados ficam em memória no `LocalService`.

## Funcionalidades
- Tela de mapa/entrada inspirada no wireframe.
- Seleção de São Paulo, Campinas e Jundiaí.
- Pesquisa por nome ou categoria.
- Filtro por cidade e categoria.
- Filtro de favoritos.
- Lista de resultados.
- Cadastro de locais.
- Edição de locais.
- Exclusão com confirmação.
- Tela de detalhes.
- Favoritar/desfavoritar.
- Representação visual de mapa sem dependências externas.
- 10 locais iniciais para demonstração.

## Como executar
```bash
flutter pub get
flutter run
```

As alterações de cadastro/edição/exclusão/favoritos permanecem apenas durante a execução do aplicativo. Ao fechar o app, a lista volta aos dados iniciais.
