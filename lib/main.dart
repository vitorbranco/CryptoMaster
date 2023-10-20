import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:crypto_master_flutter/configs/app_settings.dart';
import 'package:crypto_master_flutter/configs/hive_config.dart';
import 'package:crypto_master_flutter/meu_aplicativo.dart';
import 'package:crypto_master_flutter/repositories/conta_repository.dart';
import 'package:crypto_master_flutter/repositories/favoritas_repository.dart';
import 'package:crypto_master_flutter/repositories/moeda_repository.dart';
import 'package:crypto_master_flutter/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => MoedaRepository()),
        ChangeNotifierProvider(create: (context) => ContaRepository(
          moedas: context.read<MoedaRepository>(),
        )),
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ChangeNotifierProvider(create: (context) => FavoritasRepository(
          auth: context.read<AuthService>(),
          moedas: context.read<MoedaRepository>(),
        )),
      ],
      child: MeuAplicativo(),
    ),
  );
}
