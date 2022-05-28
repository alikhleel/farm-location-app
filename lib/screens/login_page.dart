// @dart=2.9

import 'package:flutter/material.dart';

import '../constant/color.dart';
import '../services/auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MyBody(),
    );
  }
}

class MyBody extends StatefulWidget {
  const MyBody({Key key}) : super(key: key);

  @override
  _MyBodyState createState() => _MyBodyState();
}

class _MyBodyState extends State<MyBody> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _error = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });
  }

  @override
  void dispose() {
    super.dispose();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Opacity(
                opacity: _error ? 1 : 0,
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height / 25),
                  child: const Text(
                    'عندك خطأ في الإيميل أو كلمة المرور، تأكد منهم',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                ),
              ),
              email(context),
              const SizedBox(height: 25),
              password(context),
              const SizedBox(height: 50),
              loginButton(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget email(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofocus: true,
      focusNode: _emailFocusNode,
      onFieldSubmitted: (_) {
        fieldFocusChange(context, _emailFocusNode, _passwordFocusNode);
      },
      style: Theme.of(context)
          .textTheme
          .headline6
          .copyWith(fontWeight: FontWeight.normal),
      decoration: const InputDecoration(
          hintText: 'الإيميل',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderSide: BorderSide(width: 1))
          // border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
    );
  }

  Widget password(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      textInputAction: TextInputAction.done,
      autofocus: false,
      obscureText: true,
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (_) {
        _submit();
      },
      style: Theme.of(context)
          .textTheme
          .headline6
          .copyWith(fontWeight: FontWeight.normal),
      decoration: const InputDecoration(
          suffixIcon: Icon(Icons.lock),
          hintText: 'كلمة المرور',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderSide: BorderSide(width: 1))

          // border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
    );
  }

  Widget loginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: ElevatedButton(
        onPressed: () {
          _submit();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              const Color(ApplicationColor.primarycolor)),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20)),
        ),
        child: Text('تسجيل الدخول', style: Theme.of(context).textTheme.button),
      ),
    );
  }

  void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future _submit() async {
    bool result = await AuthService()
        .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text)
        .then((value) {
      Navigator.pop(context);
      return value;
    });

    if (!result) {
      setState(() {
        _error = true;
      });
    }
  }
}
