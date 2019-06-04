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
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'main.dart';
import 'profile.dart';
import 'edit.dart';
import 'beandetail.dart';
import 'map.dart';

class DetailPage extends StatefulWidget {
  DetailPage({ Key key, this.data,}) : super(key: key);
  final data;
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

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

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

    Color getColor(bool flag) {
      if (flag) {
        return Colors.red;
      } else {
        return Colors.grey;
      }
    }

    List<Widget> _buildBeanList(List<dynamic> beans) {
      List<Widget> temp = [];
      beans.forEach((element) {
        temp.add(ListTile(
          title: Text(element),
          trailing: FlatButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BeanDetailPage(name: element)));
            },
            child: Icon(Icons.add_circle, color: Colors.brown),
          ),
        ));
      });

      return temp;
    }

    return StreamBuilder(
        stream: authService.user,
        builder: (context, snapshot) {
          return StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance.collection('cafe').document(widget.data.documentID).snapshots(),
              builder: (context, product) {
                if (!product.hasData) return LinearProgressIndicator();
                var record = Record.fromSnapshot(product.data);
                return StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('user').snapshots(),
                  builder: (context, userData) {
                    if (!userData.hasData) return LinearProgressIndicator();
                    bool flag = _checkUserExist(context, userData.data.documents, snapshot.data.uid);
                    UserRecord userRecord;
                    if (flag) {
                      DocumentSnapshot snapTemp = _getUserExist(context, userData.data.documents, snapshot.data.uid);
                      userRecord = UserRecord.fromSnapshot(snapTemp);
                    }
                    return Scaffold(
                      key: _scaffoldKey,
                      appBar: AppBar(
                        title: Text(record.name),
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.create,
                              semanticLabel: 'edit',
                            ),
                            onPressed: () {
                              if (snapshot.data.uid == record.owner) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditCafePage(uid: snapshot.data.uid, record: record, rid: widget.data.documentID)));
                              } else {
                                print("you are not owner");
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              semanticLabel: 'delete',
                            ),
                            onPressed: () {
                              if (snapshot.data.uid == record.owner) {
                                Firestore.instance.collection('cafe').document(widget.data.documentID).delete().catchError((err) => print(err));
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                      body: Center(
                        child: ListView(
                          children: [
                            Image.network(
                              record.image,
                              width: 600,
                              height: 240,
                              fit: BoxFit.cover,
                            ),
                            Divider(height: 1.0, color: Colors.black),
                            Container(
                              padding: const EdgeInsets.all(32.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    //flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            record.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    //flex: 1,
                                    child: Row(
                                      children: <Widget>[
                                        IconButton(
                                            icon: Icon(Icons.map, color: Colors.brown),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => MapPage()),
                                              );
                                            }
                                        ),
                                        IconButton(
                                            icon: Icon(Icons.favorite, color: getColor(record.likedUsers.contains(snapshot.data.uid))),
                                            onPressed: () {
                                              final snackBar1 = SnackBar(
                                                content: Text('I LIKE IT!'),
                                                action: SnackBarAction(
                                                  label: 'Undo',
                                                  onPressed: () {
                                                    List<dynamic> temp = [];
                                                    record.likedUsers.forEach((element) {
                                                      if (element != snapshot.data.uid)
                                                        temp.add(element);
                                                    });

                                                    Firestore.instance.collection('cafe').document(widget.data.documentID).updateData({
                                                      "likedUsers": temp,
                                                    }).then((result) => {}).catchError((err) => print(err));

                                                    if (flag) {
                                                      List<dynamic> userTemp = [];

                                                      userRecord.likedCafe.forEach((element) {
                                                        if (element != widget.data.documentID)
                                                          userTemp.add(element);
                                                      });

                                                      Firestore.instance.collection('user').document(snapshot.data.uid).updateData({
                                                        "likedCafe": userTemp,
                                                      }).then((result) => {}).catchError((err) => print(err));
                                                    }
                                                  },
                                                ),
                                              );
                                              final snackBar2 = SnackBar(
                                                content: Text('You can only do it once!!'),
                                                action: SnackBarAction(
                                                  label: 'Undo',
                                                  onPressed: () {
                                                    List<dynamic> temp = [];
                                                    record.likedUsers.forEach((element) {
                                                      if (element != snapshot.data.uid)
                                                        temp.add(element);
                                                    });

                                                    Firestore.instance.collection('cafe').document(widget.data.documentID).updateData({
                                                      "likedUsers": temp,
                                                    }).then((result) => {}).catchError((err) => print(err));

                                                    if (flag) {
                                                      List<dynamic> userTemp = [];

                                                      userRecord.likedCafe.forEach((element) {
                                                        if (element != widget.data.documentID)
                                                          userTemp.add(element);
                                                      });

                                                      Firestore.instance.collection('user').document(snapshot.data.uid).updateData({
                                                        "likedCafe": userTemp,
                                                      }).then((result) => {}).catchError((err) => print(err));
                                                    }
                                                  },
                                                ),
                                              );
                                              if (snapshot.hasData) {
                                                if (!record.likedUsers.contains(snapshot.data.uid)) {
                                                  List<dynamic> temp = [];
                                                  record.likedUsers.forEach((element) {
                                                    temp.add(element);
                                                  });
                                                  temp.add(snapshot.data.uid);

                                                  Firestore.instance.collection('cafe').document(widget.data.documentID).updateData({
                                                    "likedUsers": temp,
                                                  }).then((result) => {}).catchError((err) => print(err));

                                                  if (flag) {
                                                    List<dynamic> userTemp = [];

                                                    userRecord.likedCafe.forEach((element) {
                                                      if (element != widget.data.documentID)
                                                        userTemp.add(element);
                                                    });
                                                    userTemp.add(widget.data.documentID);

                                                    Firestore.instance.collection('user').document(snapshot.data.uid).updateData({
                                                      "likedCafe": userTemp,
                                                    }).then((result) => {}).catchError((err) => print(err));
                                                  }

                                                  _scaffoldKey.currentState.showSnackBar(snackBar1);
                                                } else {
                                                  _scaffoldKey.currentState.showSnackBar(snackBar2);
                                                }
                                              }
                                            }
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1.0, color: Colors.black),
                            Container(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0),
                                      child: Text(record.description),
                                    ),
                                  ]
                              ),
                            ),
                            Divider(height: 1.0, color: Colors.black),
                            Container(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildBeanList(record.beans),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                );
              }
          );
        }
    );
  }
}
