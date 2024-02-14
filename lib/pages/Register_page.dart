
import 'package:flutter/material.dart';
import 'package:test_1/auth/auth_service.dart';

import '../Components/myTextfield.dart';
import '../Components/my_button.dart';

class RegisterPage extends StatelessWidget{
  final TextEditingController _emailController =TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  final void Function()? onTap;


  RegisterPage({super.key, required this.onTap});

  void Sign_up(BuildContext context){
    final _auth = AuthService();

    if (_pwController.text == _confirmPwController.text){
      if (_pwController.text.length >= 6){
        try{
          _auth.signUpWithEmailPassword(_emailController.text, _pwController.text);
        }
        catch(e){
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(e.toString()),
            ),
          );
        }
      }
      else{
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text("Password must be at least 6 characters long."),
          ),
        );
      }


    }

    else{
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Password does not Match"),
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
                width: 60,
                height: 60,
              ),

              const SizedBox(height: 10),

              // Welcome back Message
              Text(
                "Create New Account!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 18,
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

              MyTextField(
                hintText: "Confirm Password",
                obscureText: true,
                controller: _confirmPwController,
              ),

              const SizedBox(height: 10),

              // login button
              MyButton(
                text: 'Sign up',
                onTap: () => Sign_up(context),
              ),

              const SizedBox(height: 25),

              // register now
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Text(
                        ' Login now',
                        style:
                        TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary),
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