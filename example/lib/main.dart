import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'confirmation.dart';
import 'signup.dart';
import 'secure_counter.dart';

// Setup AWS User Pool Id & Client Id settings here:
const _awsUserPoolId = 'eu-west-2_lfmWRh89O';
// const _awsUserPoolId = 'eu-west-2_Vxra6zbFN'; // sms
const _awsClientId = '5117gmquafg4temi7r9664mdh';

final userPool = CognitoUserPool(_awsUserPoolId, _awsClientId);

void main() => runApp(SecureCounterApp());

class SecureCounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('IN SecureCounterApp class build()');
    return MaterialApp(
      title: 'Cognito on Flutter',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomePage(title: 'Cognito on Flutter'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    print('IN HomePage class build()');
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              width: screenSize.width,
              child: RaisedButton(
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                color: Colors.blue,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              width: screenSize.width,
              child: RaisedButton(
                child: Text(
                  'Confirm Account',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConfirmationScreen(
                              userPool: userPool,
                            )),
                  );
                },
                color: Colors.blue,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              width: screenSize.width,
              child: RaisedButton(
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginScreen(
                              userPool: userPool,
                            )),
                  );
                },
                color: Colors.blue,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              width: screenSize.width,
              child: RaisedButton(
                child: Text(
                  'Secure Counter',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SecureCounterScreen(
                              userPool: userPool,
                            )),
                  );
                },
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
