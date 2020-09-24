import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//bilbioteca pra fazer requisições em http
import 'package:http/http.dart' as http;

//Conversão para JSON
import 'dart:convert';
//para fazer requisições assincronas
import 'package:async/async.dart';
//requisição json
const request = 'https://api.hgbrasil.com/finance?key=dc9bf62a0';

void main() async {
  // ignore: unnecessary_statements
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

//Faz requisição futura
Future<Map> getData() async{
  //Faz requisição Json
  http.Response response = await http.get(request);
  //Retorna converção para json
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Controladores
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  //Declarando variaveis de Conversão
  double dolar;
  double euro;

  //Eventos
  void _realChanged(String text){
    //variavel local recebendo o texto do controller e o convertendo
    double real = double.parse(text);

    //calculo
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    double dolar = double.parse(text);

    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar)/euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    double euro = double.parse(text);

    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      //MAP Porque esse é o formato de JSON
      body: FutureBuilder<Map>(
        //Pegar a requisição
          future: getData(),
          //declarar builder
          // ignore: missing_return
          builder: (context, snapshot){
            //Switch de carregamento que faz verificação do estado da conexão
            switch(snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text("Carregando Dados...",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                //caso deu erro no carregamento
                if(snapshot.hasError){
                  child: Text("Erro ao Carregar os dados",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0
                    ),
                    textAlign: TextAlign.center,
                  );
                } else {
                  //Sucesso no carregamento
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    //Faz a tela ficar responsiva
                    //Filho em Coluna
                    child: Column(
                      //Alinhando o conteudo no centro
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                          //campo de inserção
                            buildTextField("Reais", "R\$", realController, _realChanged),
                          Divider(),
                            buildTextField("Dolar", "US\$", dolarController, _dolarChanged),
                          Divider(),
                            buildTextField("Euro", "€", euroController, _euroChanged)
                        ],
                    ),
                  );
                }
            }
          }
      ),

    );
  }
}


//Text Builder
Widget buildTextField(String label, String prefix, TextEditingController cM, Function f){
    return TextField(
      //Decoração do campo
      controller: cM,
      decoration: InputDecoration(
        //Texto do campo
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          prefix: Text(prefix)
      ),
      style: TextStyle(
          color: Colors.amber,
          fontSize: 25.0
      ),
      onChanged: f,
      keyboardType: TextInputType.number,
    );
}

