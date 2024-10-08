import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:posadmin/counter/Auth/auth_bloc.dart';
import 'package:posadmin/counter/cubit/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => LoginCubit(),
      ),
      BlocProvider(
        create: (context) => AuthBloc(),
      )
    ], child: LoginView());
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String email = '';
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String textChange() {
    return emailController.text;
  }

  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Image.asset('assets/images/Logo.png')],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * 0.5,
            color: Color.fromRGBO(31, 29, 43, 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    onChanged: (value) {
                      email = value;
                      print(email);
                    },
                    controller: emailController,
                    style: TextStyle(
                      height: 3,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      hintText: 'Enter Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: passwordController,
                    style: TextStyle(
                      height: 3,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      hintText: 'Enter Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthLoginSuccess) {
                        final snack = SnackBar(
                          content: Text(state.Message),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snack);
                        emailController.text = '';
                        passwordController.text = '';
                        context.go('/pos');
                      } else if (state is AuthFailedState) {
                        final snack = SnackBar(
                          content: Text(state.Message),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snack);
                      }
                    },
                    child: SizedBox(),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.white,
                        fixedSize: Size(500, 60)),
                    onPressed: () async {
                      if (emailController.text.isNotEmpty &&
                          passwordController.text.isNotEmpty) {
                        BlocProvider.of<AuthBloc>(context).add(
                          SignInUser(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          ),
                        );
                      } else {
                        const snackBar = SnackBar(
                          content: Text('Please enter email and password'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
