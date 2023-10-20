import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:crypto_master_flutter/configs/app_settings.dart";
import "package:crypto_master_flutter/models/moeda.dart";
import "package:crypto_master_flutter/repositories/conta_repository.dart";
import "package:crypto_master_flutter/widgets/grafico_historico.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "package:social_share/social_share.dart";

// ignore: must_be_immutable
class MoedasDetalhesPage extends StatefulWidget {
  Moeda moeda;

  MoedasDetalhesPage({Key? key, required this.moeda}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MoedasDetalhesPageState createState() => _MoedasDetalhesPageState();
}

class _MoedasDetalhesPageState extends State<MoedasDetalhesPage> {
  // NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  late NumberFormat real;
  late Map<String, String> loc;
  final _form = GlobalKey<FormState>();
  final _valor = TextEditingController();
  double quantidade = 0;
  late ContaRepository conta;
  Widget grafico = Container();
  bool graficoLoaded = false;

  getGrafico() {
    if (!graficoLoaded) {
      grafico = GraficoHistorico(moeda: widget.moeda);
      graficoLoaded = true;
    }
    return grafico;
  }

  readNumberFormat() {
    loc = context.watch<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
  }

  comprar() async {
    if (_form.currentState!.validate()) {
      // Salvar compra
      await conta.comprar(widget.moeda, double.parse(_valor.text));

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compra realizada com sucesso!')));
    }
  }

  compartilharPreco() {
    final moeda = widget.moeda;
    SocialShare.shareOptions(
      "Confira o preço do ${moeda.nome} agora: ${real.format(moeda.preco)}",
    );
  }

  @override
  Widget build(BuildContext context) {
    readNumberFormat();
    conta = Provider.of<ContaRepository>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.moeda.nome),
          actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: compartilharPreco,
          ),
        ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        widget.moeda.icone,
                        scale: 2.5,
                      ),
                      Container(width: 10),
                      Text(real.format(widget.moeda.preco),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1,
                            color: Colors.grey[800],
                          ))
                    ],
                  ),
                ),
                getGrafico(),
                (quantidade > 0)
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          child: Text(
                            '$quantidade ${widget.moeda.sigla}',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          margin: EdgeInsets.only(bottom: 24),
                          padding: EdgeInsets.all(4),
                          alignment: Alignment.center,
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(bottom: 24),
                      ),
                Form(
                  key: _form,
                  child: TextFormField(
                    controller: _valor,
                    style: TextStyle(fontSize: 22),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Valor',
                      prefixIcon: Icon(Icons.monetization_on_outlined),
                      suffix: Text(
                        'reais',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Informe o valor da compra';
                      } else if (double.parse(value) < 10) {
                        return 'Compra mínima de R\$10,00';
                      } else if (double.parse(value) > conta.saldo) {
                        return 'Você não tem saldo para essa compra';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        quantidade = (value.isEmpty)
                            ? 0
                            : double.parse(value) / widget.moeda.preco;
                      });
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(top: 24),
                  child: ElevatedButton(
                    onPressed: comprar,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Comprar',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
