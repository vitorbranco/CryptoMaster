import 'package:flutter/material.dart';
import 'package:crypto_master_flutter/widgets/auth_check.dart';

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryptoMaster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: AuthCheck(),
    );
  }
}
