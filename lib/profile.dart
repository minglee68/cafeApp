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
import 'add.dart';
import 'main.dart';
import 'profiletodetail.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  List<Widget> _buildList(BuildContext context, List<DocumentSnapshot> snapshot, List<dynamic> likedCafe, String user) {

    List<Widget> temp = [];

    snapshot.map((data) {
      final record = Record.fromSnapshot(data);

      if (likedCafe.contains(data.documentID)) {
        temp.add(ListTile(
            title: FlatButton(
              child: Text(record.name, style: TextStyle(color: Colors.white, fontSize: 20)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(data: data, user: user)));
              },
            ),
            trailing: FlatButton(
              onPressed: () {
                List<dynamic> likedList = [];
                likedCafe.forEach((element) {
                  if (element != data.documentID)
                    likedList.add(element);
                });

                Firestore.instance.collection('user').document(user).updateData({
                  "likedCafe": likedList,
                }).then((result) => {}).catchError((err) => print(err));

                likedList = [];
                record.likedUsers.forEach((element) {
                  if (element != user)
                    likedList.add(element);
                });

                Firestore.instance.collection('cafe').document(data.documentID).updateData({
                  "likedUsers": likedList,
                }).then((result) => {}).catchError((err) => print(err));
              },
              child: Icon(Icons.favorite, color: Colors.red),
            ),
          ));
        temp.add(SizedBox(height: 20));
        temp.add(Divider(height: 1.0, color: Colors.white));
        temp.add(SizedBox(height: 20));
      }
    }).toList();

    return temp;
  }

  bool _checkUserExist(BuildContext context, List<DocumentSnapshot> snapshot, String uid) {
    List user_list = snapshot.map((data) {return data.documentID;}).toList();
    bool flag = false;

    user_list.forEach((element) {
      if (element.toString().compareTo(uid) == 0) {
        flag = true;
      }
    });
    return flag;
  }

  DocumentSnapshot _getUserExist(BuildContext context, List<DocumentSnapshot> snapshot, String uid) {
    List user_list = snapshot.map((data) {return data;}).toList();
    DocumentSnapshot user;

    user_list.forEach((element) {
      if (element.documentID.compareTo(uid) == 0) {
        user = element;
      }
    });
    return user;
  }

  Future<void> _showEditUsername(BuildContext context, String uid, String name) async {
    final _nameController = TextEditingController();
    _nameController.text = name;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Username 변경'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('변경'),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  Firestore.instance.collection('user').document(uid).updateData({
                    "nickname": _nameController.text,
                  }).then((result) =>
                  {
                  Navigator.pop(context),
                  _nameController.clear(),
                  }).catchError((err) => print(err));
                } else {
                  print('error');
                }
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('돌아가기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future getImage(String uid) async {
    File _image;
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    _image = image;

    String filename = basename(_image.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(filename);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);

    var downurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = downurl.toString();

    Firestore.instance.collection('user').document(uid).updateData({
      "image": url,
    }).then((result) => {}).catchError((err) => print(err));

    setState(() {
      print('Image Path $_image');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
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
      body: StreamBuilder(
        stream: authService.user,
        builder: (context, user) {
          if (user.hasData && !authService.guest) {
            return StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('user').snapshots(),
              builder: (context, userData) {
                //final record = UserRecord.fromSnapshot(userData.data);
                if (!userData.hasData) return LinearProgressIndicator();
                if (_checkUserExist(context, userData.data.documents, user.data.uid)) {
                  DocumentSnapshot temp = _getUserExist(context, userData.data.documents, user.data.uid);
                  final record = UserRecord.fromSnapshot(temp);
                  return StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection('cafe').snapshots(),
                    builder: (context, cafeSnapshots) {
                      if (!cafeSnapshots.hasData) return LinearProgressIndicator();
                      return Container(
                        child: CustomScrollView(
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildListDelegate([
                                Column(
                                  children: <Widget>[
                                    Image.network(
                                      record.image,
                                      width: 300,
                                      height: 300,
                                      fit: BoxFit.contain,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(top:0),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.photo_camera,
                                            size: 30.0,
                                          ),
                                          onPressed: (){
                                            getImage(user.data.uid);
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      record.nickname,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        //color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      record.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        //color: Colors.white,
                                      ),
                                    ),
                                    //SizedBox(height: 20),
                                    //Divider(height: 1.0, color: Colors.white),
                                    SizedBox(height: 20),
                                    Text(
                                      user.data.email,
                                      style: TextStyle(
                                        fontSize: 16,
                                        //color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 40),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        FlatButton(
                                          child: Text(
                                            '카페 추가',
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => AddCafePage(uid: user.data.uid)));
                                          },
                                          color: Colors.brown,
                                        ),
                                        FlatButton(
                                          child: Text(
                                            'Edit Username',
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                          onPressed: () {
                                            _showEditUsername(context, user.data.uid, record.nickname);
                                          },
                                          color: Colors.brown,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Divider(height: 1.0, color: Colors.white),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ]),
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate(_buildList(context, cafeSnapshots.data.documents, record.likedCafe, user.data.uid)),
                            ),
                          ],
                        ),
                      );
                    }
                  );
                } else {
                  return Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          "댓글을 달거나 카페를 추가하기 위해선 사용자 등록을 해주세요",
                        ),
                        FlatButton(
                          child: Text(
                            "Add User",
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                          color: Colors.blue,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AddUserPage(uid: user.data.uid, name: user.data.displayName)));
                          },
                        )
                      ],
                    ),
                  );
                }
              }
            );
          } else {
            return Center(
              child: Column(
                children: <Widget>[
                  Text(
                    "구글 로그인이 필요합니다.",
                  ),
                  FlatButton(
                    child: Text(
                      "Google Login",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.brown,
                    onPressed: () {
                      authService.signOut();
                      authService.googleSignIn();
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => AddUserPage(uid: user.data.uid)));
                    },
                  )
                ],
              ),
            );
          }
        }
      ),
    );
  }
}

class UserRecord {
  final String name;
  final String nickname;
  final String gender;
  final String image;
  final List<dynamic> likedCafe;
  final DocumentReference reference;

  UserRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['nickname'] != null),
        assert(map['gender'] != null),
        assert(map['image'] != null),
        assert(map['likedCafe'] != null),
        name = map['name'],
        nickname = map['nickname'],
        gender = map['gender'],
        image = map['image'],
        likedCafe = map['likedCafe'];

  UserRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);


  @override
  String toString() => "UserRecord<$name:$nickname:$gender:$image:$likedCafe>";
}
