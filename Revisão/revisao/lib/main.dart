import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: TelaCadastro(), debugShowCheckedModeBanner: false));
}

class TelaCadastro extends StatefulWidget {
  @override
  _TelaCadastroState createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final nome = TextEditingController();
  final idade = TextEditingController();
  final curso = TextEditingController();

  List<Map<String, String>> alunos = [];

  void cadastrar() {
    if (nome.text.isEmpty || idade.text.isEmpty || curso.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));

      return;
    }

    setState(() {
      alunos.add({'nome': nome.text, 'idade': idade.text, 'curso': curso.text});
    });

    nome.clear();
    idade.clear();
    curso.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20),

          TextField(
            controller: nome,
            decoration: InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),

          SizedBox(height: 10),

          TextField(
            controller: idade,
            decoration: InputDecoration(
              labelText: 'Idade',
              border: OutlineInputBorder(),
            ),
          ),

          SizedBox(height: 10),

          TextField(
            controller: curso,
            decoration: InputDecoration(
              labelText: 'Curso',
              border: OutlineInputBorder(),
            ),
          ),

          SizedBox(height: 20),

          ElevatedButton(onPressed: cadastrar, child: Text('Cadastrar')),

          Expanded(
            child: ListView.builder(
              itemCount: alunos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(alunos[index]['nome']!),
                  subtitle: Text(
                    '${alunos[index]['idade']} - ${alunos[index]['curso']}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
