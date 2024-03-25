import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'signup.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/home.dart';

class Login extends StatefulWidget {
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your username';
                    }
                    if (!EmailValidator.validate(value)) {
                      return 'Please enter email in a valid format';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Login'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New user?"),
                    TextButton(
                      // Create a TextButton for Login
                      onPressed: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Signup()));
                      },
                      child: Text('Signup'), // Text shown on the button
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    try {
      if (_formKey.currentState!.validate()) {
        final String email = _emailController.text;
        final String password = _passwordController.text;
        final String uid = _auth.currentUser!.uid;
        print(uid);
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref('users').child(uid);
        DataSnapshot snapshot = await userRef.get();
        if (snapshot.value != null) {
          if (snapshot.child('email').value == email &&
              snapshot.child('password').value == password) {
            _showSnackBar("Login Successful");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Home()));
          } else {
            print(
                "${snapshot.child('email').value}, ${snapshot.child('password').value}");
            _showSnackBar("Login Failed");
          }
        }
      }
    } catch (error) {
      _showSnackBar(error.toString());
    }
  }
}
