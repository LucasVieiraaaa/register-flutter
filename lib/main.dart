import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  _recuperarBD() async {
    final caminho = await getDatabasesPath();
    final local = join(caminho, "bancodados.db");

    var retorno = await openDatabase(
      local,
      version: 1,
      onCreate: (db, dbVersaoRecente) {
        String sql = "CREATE TABLE usuarios ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "nome VARCHAR, idade INTEGER)";
        db.execute(sql);
      },
    );

    print("Aberto ${retorno.isOpen.toString()}");

    return retorno;
  }

  _salvarDados(BuildContext context, String nome, int idade) async {
    Database db = await _recuperarBD();

    Map<String, dynamic> dadosUsuario = {
      "nome": nome,
      "idade": idade,
    };

    int id = await db.insert("usuarios", dadosUsuario);
    print("Salvo $id");
    _mostrarDialogo(context, "Usuário salvo com sucesso!");
  }

  _mostrarDialogo(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Resultado"),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  _listarUsuarios() async {
    Database db = await _recuperarBD();
    String sql = "SELECT * FROM usuarios";
    List usuarios = await db.rawQuery(sql);

    for (var usu in usuarios) {
      print(
          " id: ${usu['id'].toString()} nome: ${usu['nome']} idade: ${usu['idade']}");
    }
  }

  _listarUmUsuario(BuildContext context, int id) async {
    Database db = await _recuperarBD();

    List usuarios = await db.query(
      "usuarios",
      columns: ["id", "nome", "idade"],
      where: "id = ?",
      whereArgs: [id],
    );

    if (usuarios.isNotEmpty) {
      var usuario = usuarios.first;
      _mostrarDialogo(context,
          "ID: ${usuario['id']} \nNome: ${usuario['nome']} \nIdade: ${usuario['idade']}");
    } else {
      _mostrarDialogo(context, "Usuário com ID $id não encontrado.");
    }
  }

  _excluirUsuario(BuildContext context, int id) async {
    Database db = await _recuperarBD();

    int retorno = await db.delete(
      "usuarios",
      where: "id = ?",
      whereArgs: [id],
    );

    print("Itens excluídos: $retorno");
    _mostrarDialogo(context, "Usuário com ID $id excluído com sucesso.");
  }

  _atualizarUsuario(
      BuildContext context, int id, String? nome, int? idade) async {
    Database db = await _recuperarBD();

    Map<String, dynamic> dadosUsuario = {};
    if (nome != null && nome.isNotEmpty) {
      dadosUsuario["nome"] = nome;
    }
    if (idade != null) {
      dadosUsuario["idade"] = idade;
    }

    if (dadosUsuario.isNotEmpty) {
      int retorno = await db.update(
        "usuarios",
        dadosUsuario,
        where: "id = ?",
        whereArgs: [id],
      );

      print("Itens atualizados: $retorno");
      _mostrarDialogo(context, "Usuário com ID $id atualizado com sucesso.");
    } else {
      _mostrarDialogo(context, "Nenhuma informação para atualizar.");
    }
  }

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(0.5),
              width: 300,
              alignment: Alignment.center,
              child: TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  label: Text("Digite o nome:"),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Container(
              margin: const EdgeInsets.all(0.5),
              width: 300,
              alignment: Alignment.center,
              child: TextField(
                controller: _idadeController,
                decoration: const InputDecoration(
                  label: Text("Digite a idade:"),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _salvarDados(context, _nomeController.text,
                    int.tryParse(_idadeController.text) ?? 0);
              },
              child: const Text("Salvar um usuário"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _listarUsuarios,
              child: const Text("Listar todos usuários"),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.all(0.5),
              width: 300,
              alignment: Alignment.center,
              child: TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  label: Text(
                      "Digite o ID do usuário para listar/excluir/atualizar:"),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                int? id = int.tryParse(_idController.text);
                if (id != null) {
                  _listarUmUsuario(context, id);
                } else {
                  _mostrarDialogo(
                      context, "Por favor, insira um ID válido para listar.");
                }
              },
              child: const Text("Listar um usuário"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                int? id = int.tryParse(_idController.text);
                if (id != null) {
                  _excluirUsuario(context, id);
                } else {
                  _mostrarDialogo(
                      context, "Por favor, insira um ID válido para excluir.");
                }
              },
              child: const Text("Excluir usuário"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                int? id = int.tryParse(_idController.text);
                if (id != null) {
                  String? nome = _nomeController.text.isNotEmpty
                      ? _nomeController.text
                      : null;
                  int? idade = int.tryParse(_idadeController.text);
                  _atualizarUsuario(context, id, nome, idade);
                } else {
                  _mostrarDialogo(context,
                      "Por favor, insira um ID válido para atualizar.");
                }
              },
              child: const Text("Atualizar usuário"),
            ),
          ],
        ),
      ),
    );
  }
}
