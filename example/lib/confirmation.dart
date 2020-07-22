import 'package:flutter/material.dart';
import 'user.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'login.dart';

class ConfirmationScreen extends StatefulWidget {
  ConfirmationScreen({this.email, this.userPool});

  final String email;
  final CognitoUserPool userPool;

  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String confirmationCode;
  final User _user = User();
  UserService _userService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userService = UserService(widget.userPool);
  }

  _submit(BuildContext context) async {
    print('IN ConfirmationScreen class _submit()');
    _formKey.currentState.save();
    bool accountConfirmed;
    String message;
    try {
      accountConfirmed =
          await _userService.confirmAccount(_user.email, confirmationCode);
      message = 'Account successfully confirmed!';
    } on CognitoClientException catch (e) {
      if (e.code == 'InvalidParameterException' ||
          e.code == 'CodeMismatchException' ||
          e.code == 'NotAuthorizedException' ||
          e.code == 'UserNotFoundException' ||
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
          if (accountConfirmed) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginScreen(email: _user.email)),
            );
          }
        },
      ),
      duration: Duration(seconds: 30),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  _resendConfirmation(BuildContext context) async {
    print('IN ConfirmationScreen class _resendConfirmation()');
    _formKey.currentState.save();
    String message;
    try {
      await _userService.resendConfirmationCode(_user.email);
      message = 'Confirmation code sent to ${_user.email}!';
    } on CognitoClientException catch (e) {
      if (e.code == 'LimitExceededException' ||
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
        onPressed: () {},
      ),
      duration: Duration(seconds: 30),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    print('IN ConfirmationScreen class build()');
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Account'),
      ),
      body: Builder(
          builder: (BuildContext context) => Container(
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
                              InputDecoration(labelText: 'Confirmation Code'),
                          onSaved: (String code) {
                            confirmationCode = code;
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        width: screenSize.width,
                        child: RaisedButton(
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _submit(context);
                          },
                          color: Colors.blue,
                        ),
                        margin: EdgeInsets.only(
                          top: 10.0,
                        ),
                      ),
                      Center(
                        child: InkWell(
                          child: Text(
                            'Resend Confirmation Code',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                          onTap: () {
                            _resendConfirmation(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )),
    );
  }
}
