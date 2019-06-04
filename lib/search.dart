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
  bool _cafeName = false;
  bool _beanName = false;
  bool _sflag = true;
  var _checkFlag = [false, false, false, false, false, false, false];

  String getBeanName(int num) {
    String name;
    if (num == 0) {
      name = "인도네시아 만델링";
    } else if (num == 1) {
      name = "콜롬비아 슈프리모";
    } else if (num == 2) {
      name = "브라질 산토스";
    } else if (num == 3) {
      name = "과테말라 안티구아";
    } else if (num == 4) {
      name = "에디오피아 예가체프";
    } else if (num == 5) {
      name = "케냐 AA";
    } else if (num == 6) {
      name = "에디오피아 시다모";
    }

    return name;
  }

  List<dynamic> getBeans() {
    List<dynamic> temp = [];
    int count = 0;
    _checkFlag.forEach((element) {
      if (element) {
        temp.add(getBeanName(count));
      }
      count = count + 1;
    });
    return temp;
  }

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
                _cafeName = true;
                _beanName = false;
                _sflag = true;
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
    void onSubmit(List<dynamic> newlist) {
      setState(() {
        int count = 0;
        while (count < 7) {
          _checkFlag[count] = newlist[count];
          count = count + 1;
        }
        _cafeName = false;
        _beanName = true;
        _sflag = true;
      });
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => SearchForm(onSubmit: onSubmit),
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
    List<dynamic> check = [];
    snapshot.map((data) {
      final record = Record.fromSnapshot(data);

      if (_cafeName) {
        if (record.name.contains(_name)) {
          temp.add(_buildListItem(context, data));
        }
      } else if (_beanName) {
        List<dynamic> beans = getBeans();
        beans.forEach((element) {
          if (record.beans.contains(element) && !check.contains(record.name)) {
            print(record.name);
            check.add(record.name);
            temp.add(_buildListItem(context, data));
          }
        });
      } else {
        temp.add(_buildListItem(context, data));
      }
    }).toList();

    _sflag = false;

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
    print('build');
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
          );
        }
      ),
    );
  }
}

class SearchForm extends StatefulWidget {
  SearchForm({this.onSubmit});
  final onSubmit;

  @override
  SearchFormState createState() => SearchFormState();
}

class SearchFormState extends State<SearchForm> {
  var _checkFlag = [false, false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('카페 이름으로 검색하세요'),
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              CheckboxListTile(
                title: const Text('인도네시아 만델링'),
                value: _checkFlag[0],
                onChanged: (bool value) {
                  setState(() { _checkFlag[0] = value; });
                },
              ),
              CheckboxListTile(
                title: const Text('콜롬비아 슈프리모'),
                value: _checkFlag[1],
                onChanged: (bool value) {
                  setState(() { _checkFlag[1] = value; });
                },
              ),
              CheckboxListTile(
                title: const Text('브라질 산토스'),
                value: _checkFlag[2],
                onChanged: (bool value) {
                  setState(() { _checkFlag[2] = value; });
                },
              ),
              CheckboxListTile(
                title: const Text('과테말라 안티구아'),
                value: _checkFlag[3],
                onChanged: (bool value) {
                  setState(() { _checkFlag[3] = value; });
                },
              ),
              CheckboxListTile(
                title: const Text('에디오피아 예가체프'),
                value: _checkFlag[4],
                onChanged: (bool value) {
                  setState(() { _checkFlag[4] = value; });
                },
              ),
              CheckboxListTile(
                title: const Text('케냐 AA'),
                value: _checkFlag[5],
                onChanged: (bool value) {
                  setState(() { _checkFlag[5] = value; });
                },
              ),
              CheckboxListTile(
                title: const Text('에디오피아 시다모'),
                value: _checkFlag[6],
                onChanged: (bool value) {
                  setState(() { _checkFlag[6] = value; });
                },
              ),
              FlatButton(
                child: Text('검색'),
                onPressed: () {
                  widget.onSubmit(_checkFlag);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}