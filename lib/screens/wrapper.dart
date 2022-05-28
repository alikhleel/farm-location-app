// @dart=2.9

import '../models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
import 'login_page.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user != null) {
      if (user.uid != null) {
        return HomePage();
      } else {
        return Container();
      }
    } else {
      return const LoginPage();
    }
  }
}
