import 'package:flutter/material.dart';
import 'user.dart';
import 'confirmation.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';

class SignUpScreen extends StatefulWidget {
  final CognitoUserPool userPool;

  SignUpScreen({this.userPool});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User _user = User();
  UserService userService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userService = UserService(widget.userPool);
  }

  void submit(BuildContext context) async {
    print('IN SignUpScreen class submit()');
    _formKey.currentState.save();

    String message;
    bool signUpSuccess = false;
    try {
      _user = await userService.signUp(_user.email, _user.password, _user.name);
      signUpSuccess = true;
      message = 'User sign up successful!';
    } on CognitoClientException catch (e) {
      if (e.code == 'UsernameExistsException' ||
          e.code == 'InvalidParameterException' ||
          e.code == 'ResourceNotFoundException') {
        message = e.message;
      } else {
        message = 'Unknown client error occurred';
      }
    } catch (e) {
      message = 'Unknown error occurred';
    }

    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          if (signUpSuccess) {
            Navigator.pop(context);
            if (!_user.confirmed) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ConfirmationScreen(email: _user.email)),
              );
            }
          }
        },
      ),
      duration: Duration(seconds: 30),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    print('IN SignUpScreen class build()');
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.account_box),
                    title: TextFormField(
                      decoration: InputDecoration(labelText: 'Name'),
                      onSaved: (String name) {
                        print('Name onSaved');
                        _user.name = name;
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: TextFormField(
                      decoration: InputDecoration(
                          hintText: 'example@inspire.my', labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (String email) {
                        print('Email onSaved');
                        _user.email = email;
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Password!',
                      ),
                      obscureText: true,
                      onSaved: (String password) {
                        print('Password onSaved');
                        _user.password = password;
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20.0),
                    width: screenSize.width,
                    child: RaisedButton(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        submit(context);
                      },
                      color: Colors.blue,
                    ),
                    margin: EdgeInsets.only(
                      top: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
