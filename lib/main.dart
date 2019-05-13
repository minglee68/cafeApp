// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'login.dart';
import 'auth.dart';

void main() => runApp(HomePage());

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'home',
        home: MyHomePage(),
        initialRoute: '/login',
        onGenerateRoute: _getRoute,
        routes: {
        }
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => LoginPage(),
      fullscreenDialog: true,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cafe App'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              semanticLabel: 'exit',
            ),
            onPressed: () {
              authService.signOut();
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Cafe App'),
      ),
    );
  }
}