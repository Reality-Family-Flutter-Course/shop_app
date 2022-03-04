import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/screens/products_overview_screen.dart';

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    "email": "",
    "password": "",
  };
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  AnimationController? _controller;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(
        0,
        -1.5,
      ),
      end: const Offset(
        0,
        0,
      ),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeIn,
      ),
    );
    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeIn,
      ),
    );
    //_heightAnimation!.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Произошла ошибка"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("ОК"),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false).auth(
          _authData["email"] ?? "",
          _authData["password"] ?? "",
        );
      } else {
        await Provider.of<Auth>(context, listen: false).singup(
          _authData["email"] ?? "",
          _authData["password"] ?? "",
        );
      }

      Navigator.of(context)
          .pushReplacementNamed(ProductsOverviewScreen.routeName);
    } on HttpException catch (error) {
      var errorMessage =
          "${_authMode == AuthMode.login ? "Вход" : "Регистрации"} не выполнен";
      if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "Учетной записи с данной почтой не найдено";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "Некорректный пароль";
      } else if (error.toString().contains("EMAIL_EXISTS")) {
        errorMessage = "Учетная запись с данной почтой уже существует";
      }

      _showErrorDialog(errorMessage);
    } catch (error) {
      final errorMessage =
          "Во время ${_authMode == AuthMode.login ? "входе" : "регистрации"} произошла ошибка.\nПопробуйте позже";

      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.register ? 320 : 260,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 15,
              ),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Почта"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains("@")) {
                        return "Некорректная почта";
                      }
                    },
                    onSaved: (newValue) {
                      _authData["email"] = newValue ?? "";
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Пароль"),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 5) {
                        return "Некорректный пароль";
                      }
                    },
                    onSaved: (newValue) {
                      _authData["password"] = newValue ?? "";
                    },
                  ),
                  AnimatedContainer(
                    constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.register ? 60 : 0,
                      maxHeight: _authMode == AuthMode.register ? 120 : 0,
                    ),
                    duration: const Duration(
                      milliseconds: 300,
                    ),
                    child: FadeTransition(
                      opacity: _opacityAnimation!,
                      child: SlideTransition(
                        position: _slideAnimation!,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.register,
                          decoration: const InputDecoration(
                              labelText: "Подтверждение пароля"),
                          obscureText: true,
                          validator: _authMode == AuthMode.register
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return "Пароли не совпадают";
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  !_isLoading
                      ? ElevatedButton(
                          onPressed: _submit,
                          child: Text(_authMode == AuthMode.login
                              ? "Войти"
                              : "Зарегистрироваться"),
                        )
                      : const CircularProgressIndicator(),
                  TextButton(
                    onPressed: () {
                      switch (_authMode) {
                        case AuthMode.login:
                          setState(() {
                            _authMode = AuthMode.register;
                          });
                          _controller!.forward();
                          break;
                        case AuthMode.register:
                          setState(() {
                            _authMode = AuthMode.login;
                          });
                          _controller!.reverse();
                          break;
                      }
                    },
                    child: Text(
                      _authMode == AuthMode.login
                          ? "У меня нет учетной записи"
                          : "У меня есть учетная запись",
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AuthMode {
  login,
  register,
}
