import 'package:flutter/material.dart';
import 'package:crypto_master_flutter/configs/app_settings.dart';
import 'package:crypto_master_flutter/models/moeda.dart';
import 'package:crypto_master_flutter/pages/moedas_detalhes_page.dart';
import 'package:crypto_master_flutter/repositories/favoritas_repository.dart';
import 'package:crypto_master_flutter/repositories/moeda_repository.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoedasPage extends StatefulWidget {
  const MoedasPage({Key? key}) : super(key: key);

  @override
  State<MoedasPage> createState() => _MoedasPageState();
}

class _MoedasPageState extends State<MoedasPage> {
  late List<Moeda> tabela;
  late NumberFormat real;
  late Map<String, String> loc;
  List<Moeda> selecionadas = [];
  late FavoritasRepository favoritas;
  late MoedaRepository moedas;

  readNumberFormat() {
    loc = context.watch<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
  }

  changeLanguageButton() {
    final locale = loc['locale'] == 'pt_BR' ? 'en_US' : 'pt_BR';
    final name = loc['locale'] == 'pt_BR' ? '\$' : 'R\$';
    return PopupMenuButton(
      icon: Icon(Icons.language),
      itemBuilder: (context) => [
        PopupMenuItem(child: ListTile(
          leading: Icon(Icons.swap_vert),
          title: Text('Usar $locale'),
          onTap: () {
            context.read<AppSettings>().setLocale(locale, name);
            Navigator.pop(context);
          },
        ))
      ],
    );
  }

  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        title: const Text('CryptoMaster'),
        actions: [
          changeLanguageButton(),
        ],
      );
    } else {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              selecionadas = [];
            });
          },
        ),
        title: Text('${selecionadas.length} selecionadas',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.deepPurple[100],
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      );
    }
  }

  mostrarDetalhes(Moeda moeda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoedasDetalhesPage(moeda: moeda),
      ),
    );
  }

  limparSelecionadas() {
    setState(() {
      selecionadas = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // favoritas = Provider.of<FavoritasRepository>(context);
    favoritas = context.watch<FavoritasRepository>();
    moedas = context.watch<MoedaRepository>();
    tabela = moedas.tabela;
    readNumberFormat();


    return Scaffold(
      appBar: appBarDinamica(),      
      body: RefreshIndicator(
        onRefresh: () => moedas.checkPrecos(),
        child: ListView.separated(
            itemBuilder: (BuildContext context, int moeda) {
              return ListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
                leading: (selecionadas.contains(tabela[moeda]))
                    ? const CircleAvatar(
                        child: Icon(Icons.check),
                      )
                    : SizedBox(
                        width: 40,
                        child: Image.network(tabela[moeda].icone),
                      ),
                title: Row(
                  children: [
                    Text(
                      tabela[moeda].nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (favoritas.lista.any((fav) => fav.sigla == tabela[moeda].sigla)) Icon(Icons.star, color: Colors.amber, size: 8),
                  ],
                ),
                trailing: Text(real.format(tabela[moeda].preco)),
                selected: selecionadas.contains(tabela[moeda]),
                selectedTileColor: const Color.fromARGB(24, 104, 58, 183),
                onLongPress: () {
                  setState(() {
                    (selecionadas.contains(tabela[moeda]))
                        ? selecionadas.remove(tabela[moeda])
                        : selecionadas.add(tabela[moeda]);
                  });
                },
                onTap: () => mostrarDetalhes(tabela[moeda]),
              );
            },
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: tabela.length),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selecionadas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                favoritas.saveAll(selecionadas);
                limparSelecionadas();
              },
              icon: const Icon(Icons.star),
              label: const Text(
                'FAVORITAR',
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
