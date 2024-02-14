import 'package:flutter/material.dart';
import 'package:test_1/Components/myTextfield.dart';
import 'package:test_1/Components/my_button.dart';
import 'package:test_1/auth/auth_service.dart';

class LoginPage extends StatelessWidget{
  final TextEditingController _emailController =TextEditingController();
  final TextEditingController _pwController = TextEditingController();


  // tap to go to register page

  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  // login method
  void Login(BuildContext context) async{
    final authService = AuthService();

    // Try Login
    try{
      await authService.signInWithEmailPassword(_emailController.text, _pwController.text,);

  }
  // Catch Errors
  catch(e){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
        title: Text(e.toString()),
      ),
      );
  }

  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // logo
            Image.asset(
              'assets/AgridisScan_logo.png',
              width: 80,
              height: 80,
            ),

            const SizedBox(height: 10),

            // Welcome back Message
            Text(
                "Welcome Back!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 20,
              ),

            ),

            const SizedBox(height: 10),

            //Textfield
            MyTextField(
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),
            const SizedBox(height: 10),
            MyTextField(
              hintText: "Password",
              obscureText: true,
              controller: _pwController,
            ),

            const SizedBox(height: 10),

            // login button
            MyButton(
              text: 'Login',
              onTap: () => Login(context),
            ),

            const SizedBox(height: 10),

            // register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not a member?',
                  style:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    ' Sign up now',
                    style:
                    TextStyle(
                        fontWeight: FontWeight.bold,
                        color:Theme.of(context).colorScheme.secondary
                    ),
                  ),
                )
              ]
            ),
          ],

        )

      ),
    );
  }
}