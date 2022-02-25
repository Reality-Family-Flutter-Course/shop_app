import 'package:flutter/material.dart';

class AuthCard extends StatefulWidget {
  AuthCard({Key? key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  Map<String, String> _authData = {
    "email": "",
    "password": "",
  };
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_authMode == AuthMode.login) {
      // await login
    } else {
      // await register
    }

    await Future.delayed(Duration(milliseconds: 500));

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
                if (_authMode == AuthMode.register)
                  TextFormField(
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
                    setState(() {
                      switch (_authMode) {
                        case AuthMode.login:
                          _authMode = AuthMode.register;
                          break;
                        case AuthMode.register:
                          _authMode = AuthMode.login;
                          break;
                      }
                    });
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
    );
  }
}

enum AuthMode {
  login,
  register,
}
