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
import 'auth.dart';
import 'profile.dart';
import 'add.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                SizedBox(height: 16.0),
                Text('CAFE APP'),
              ],
            ),
            SizedBox(height: 120.0),
            StreamBuilder(
              stream: authService.user,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Navigator.pop(context);
                  return MaterialButton(
                    onPressed: () => authService.signOut(),
                    color: Colors.red,
                    textColor: Colors.white,
                    child: Text('Signout'),
                  );
                } else {
                  return MaterialButton(
                    onPressed: () => authService.googleSignIn(),
                    color: Colors.white,
                    textColor: Colors.black,
                    child: Text('Login with Google'),
                  );
                }
              }
            ),
            RaisedButton(
              child: Text('Guest'),
              onPressed: () {
                FirebaseAuth.instance
                    .signInAnonymously()
                    .then((FirebaseUser user){
                }).catchError((e) {
                  print(e);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

