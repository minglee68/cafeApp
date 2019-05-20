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

class DetailPage extends StatefulWidget {
  DetailPage({ Key key, this.data,}) : super(key: key);
  final data;
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

    return StreamBuilder(
        stream: authService.user,
        builder: (context, snapshot) {
          return StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance.collection('cafe').document(widget.data.documentID).snapshots(),
              builder: (context, product) {
                if (!product.hasData) return LinearProgressIndicator();
                var record = Record.fromSnapshot(product.data);
                return Scaffold(
                  key: _scaffoldKey,
                  appBar: AppBar(
                    title: Text("Detail"),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.create,
                          semanticLabel: 'create',
                        ),
                        onPressed: () {
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          semanticLabel: 'delete',
                        ),
                        onPressed: () {
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
                                flex: 4,
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
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                        icon: Icon(Icons.thumb_up),
                                        onPressed: () {
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
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }
}
