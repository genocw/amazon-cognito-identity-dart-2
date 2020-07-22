import 'package:flutter/material.dart';
import 'user.dart';
import 'counter.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'login.dart';

// Setup endpoints here:
const _region = 'eu-west-2';
const _endpoint = 'https://staging-api.sustainably.co/';

class SecureCounterScreen extends StatefulWidget {
  final CognitoUserPool userPool;

  SecureCounterScreen({this.userPool});

  @override
  _SecureCounterScreenState createState() => _SecureCounterScreenState();
}

class _SecureCounterScreenState extends State<SecureCounterScreen> {
  UserService _userService;
  CounterService _counterService;
  AwsSigV4Client _awsSigV4Client;
  User _user = User();
  Counter _counter = Counter(0);
  bool _isAuthenticated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userService = UserService(widget.userPool);
  }

  void _incrementCounter() async {
    print('IN SecureCounterScreen class _incrementCounter()');
    final counter = await _counterService.incrementCounter();
    setState(() {
      _counter = counter;
    });
  }

  Future<UserService> _getValues(BuildContext context) async {
    print('IN SecureCounterScreen class _getValues()');
    try {
      await _userService.init();
      _isAuthenticated = await _userService.checkAuthenticated();
      if (_isAuthenticated) {
        // get user attributes from cognito
        _user = await _userService.getCurrentUser();

        // get session credentials
        final credentials = await _userService.getCredentials();
        _awsSigV4Client = AwsSigV4Client(
            credentials.accessKeyId, credentials.secretAccessKey, _endpoint,
            region: _region, sessionToken: credentials.sessionToken);

        // get previous count
        _counterService = CounterService(_awsSigV4Client);
        _counter = await _counterService.getCounter();
      }
      return _userService;
    } on CognitoClientException catch (e) {
      if (e.code == 'NotAuthorizedException') {
        await _userService.signOut();
        Navigator.pop(context);
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('IN SecureCounterScreen class build()');
    return FutureBuilder(
        future: _getValues(context),
        builder: (context, AsyncSnapshot<UserService> snapshot) {
          if (snapshot.hasData) {
            if (!_isAuthenticated) {
              return LoginScreen();
            }

            return Scaffold(
              appBar: AppBar(
                title: Text('Secure Counter'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Welcome ${_user.name}!',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Divider(),
                    Text(
                      'You have pushed the button this many times:',
                    ),
                    Text(
                      '${_counter.count}',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Divider(),
                    Center(
                      child: InkWell(
                        child: Text(
                          'Logout',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                        onTap: () {
                          _userService.signOut();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (snapshot.hasData) {
                    _incrementCounter();
                  }
                },
                tooltip: 'Increment',
                child: Icon(Icons.add),
              ),
            );
          }
          return Scaffold(appBar: AppBar(title: Text('Loading...')));
        });
  }
}
