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
import 'main.dart';
import 'detail.dart';


class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  String _name = "";

  Future<void> _showSearchCafe(BuildContext context) async {
    final _nameController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('카페 이름으로 검색하세요'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    labelText: '카페 이름으로 검색',
                  ),
                  controller: _nameController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('검색'),
              onPressed: () {
                _name = _nameController.text;
                print(_name);
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

  Future<void> _showSearchBean(BuildContext context) async {
    final _nameController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('카페 이름으로 검색하세요'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    labelText: '카페 이름으로 검색',
                  ),
                  controller: _nameController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('검색'),
              onPressed: () {
                _name = _nameController.text;
                print(_name);
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

  List<Widget> _buildButtons(BuildContext context) {
    return [Row(
      children: <Widget>[
        Expanded(child: FlatButton(child: Text('카페 이름으로 찾기'), onPressed: () {_showSearchCafe(context);},)),
        Expanded(child: FlatButton(child: Text('원두 종류로 찾기'), onPressed: () {_showSearchBean(context);},)),
      ],
    )];
  }

  List<Widget> _buildGridCards(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<Widget> temp = [];
    snapshot.map((data) {
      temp.add(_buildListItem(context, data));
    }).toList();

    return temp;
  }

  Card _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 18.0 / 11.0,
            child: (record.image != null) ? Image.network(record.image, fit:BoxFit.fill) :
            Image.network(
              'https://firebasestorage.googleapis.com/v0/b/cafeappproject.appspot.com/o/noimage.jpg?alt=media&token=38594644-3fd9-4a35-ab6b-e29b66932c04',
              width: 400,
              height: 400,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    record.name,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    record.location,
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: <Widget>[
                      Text(
                        "OPEN: ",
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      Text(
                        record.open,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "CLOSE: ",
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      Text(
                        record.close,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    record.description,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.all(0.0),
                    padding: EdgeInsets.all(0.0),
                    child: FlatButton(
                      child: Text(
                        'More',
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(data: data)));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('cafe').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return Center(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: EdgeInsets.all(1.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(_buildButtons(context)),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(16.0),
                  sliver: SliverGrid.count(
                    crossAxisCount: 1,
                    childAspectRatio: 7.5 / 9.0,
                    children: _buildGridCards(context, snapshot.data.documents),
                  ),
                ),
              ],
            ),
            /*
            child: GridView.count(
              crossAxisCount: 1,
              padding: EdgeInsets.all(16.0),
              childAspectRatio: 7.5 / 9.0,
              children: _buildGridCards(context, snapshot.data.documents),
            ),
            */
          );
        }
      ),
    );
  }
}