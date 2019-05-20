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
import 'package:cloud_firestore/cloud_firestore.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              semanticLabel: 'exit',
            ),
            onPressed: () {
              authService.signOut();
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.black),
        child: Center(
          child: StreamBuilder(
              stream: authService.user,
              builder: (context, user) {
                if (user.hasData) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: Firestore.instance.collection('user').document(user.data.uid).snapshots(),
                    builder: (context, userData) {
                      final record = UserRecord.fromSnapshot(userData.data);
                      return Column(
                        children: <Widget>[
                          Image.network(
                            record.image,
                            width: 300,
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 60),
                          Text(
                            record.nickname,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            record.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          Divider(height: 1.0, color: Colors.white),
                          SizedBox(height: 20),
                          Text(
                            user.data.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    }
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/my-app-b8a9c.appspot.com/o/noimage.jpg?alt=media&token=3f8568d1-9f1c-40cb-b541-ffcfd1652979',
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 60),
                      Text(
                        'anonymous uid',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Divider(height: 1.0, color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'anonymous',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                }
              }
          ),
        ),
      ),
    );
  }
}

class UserRecord {
  final String name;
  final String nickname;
  final String gender;
  final String image;
  final DocumentReference reference;

  UserRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['nickname'] != null),
        assert(map['gender'] != null),
        assert(map['image'] != null),
        name = map['name'],
        nickname = map['nickname'],
        gender = map['gender'],
        image = map['image'];

  UserRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);


  @override
  String toString() => "UserRecord<$name:$nickname:$gender:$image>";
}
