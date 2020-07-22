import 'package:flutter/material.dart';
import 'package:secure_counter/main.dart';
import 'user.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'confirmation.dart';
import 'secure_counter.dart';

/// login sessions
class LoginScreen extends StatefulWidget {
  // LoginScreen({Key key, this.email}) : super(key: key);
  LoginScreen({this.userPool, this.email});

  final String email;
  final CognitoUserPool userPool;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserService _userService;
  User _user = User();
  bool _isAuthenticated = false;
  CognitoUserPool _userPool;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userPool = widget.userPool;
    _userService = UserService(_userPool);
  }

  Future<UserService> _getValues() async {
    print('IN LoginScreen class _getValues()');
    await _userService.init();
    _isAuthenticated = await _userService.checkAuthenticated();
    print('User _isAuthenticated: $_isAuthenticated');
    return _userService;
  }

  submit(BuildContext context) async {
    print('IN LoginScreen class submit()');
    _formKey.currentState.save();
    String message;
    try {
      _user = await _userService.login(_user.email, _user.password);
      message = 'User sucessfully logged in!';
      if (!_user.confirmed) {
        message = 'Please confirm user account';
      }
    } on CognitoClientException catch (e) {
      if (e.code == 'InvalidParameterException' ||
          e.code == 'NotAuthorizedException' ||
          e.code == 'UserNotFoundException' ||
          e.code == 'ResourceNotFoundException') {
        message = e.message;
      } else {
        message = 'An unknown client error occured';
      }
    } catch (e) {
      message = 'An unknown error occurred';
    }
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () async {
          if (_user.hasAccess) {
            Navigator.pop(context);
            if (!_user.confirmed) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ConfirmationScreen(
                        email: _user.email, userPool: _userPool)),
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
    print('IN LoginScreen class build()');
    return FutureBuilder(
        future: _getValues(),
        builder: (context, AsyncSnapshot<UserService> snapshot) {
          if (snapshot.hasData) {
            if (_isAuthenticated) {
              print('IN FutureBuilder - snapshot.hasData && _isAuthenticated');
              return SecureCounterScreen();
            }
            final Size screenSize = MediaQuery.of(context).size;
            return Scaffold(
              appBar: AppBar(
                title: Text('Login'),
              ),
              body: Builder(
                builder: (BuildContext context) {
                  return Container(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: TextFormField(
                              initialValue: widget.email,
                              decoration: InputDecoration(
                                  hintText: 'example@inspire.my',
                                  labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (String email) {
                                _user.email = email;
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.lock),
                            title: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              onSaved: (String password) {
                                _user.password = password;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(20.0),
                            width: screenSize.width,
                            child: RaisedButton(
                              child: Text(
                                'Login',
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
          return Scaffold(appBar: AppBar(title: Text('Loading...')));
        });
  }
}
