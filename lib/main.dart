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
import 'profile.dart';
import 'auth.dart';
import 'add.dart';
import 'detail.dart';
import 'map.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          '/profile': (context) => ProfilePage(),
          '/map': (context) => MapPage(),
          //'/home' : (context) => MyHomePage(),
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
  int _cIndex = 0;

  void _incrementTab(index) {
    setState(() {
      _cIndex = index;
      print(_cIndex);
      
      if (_cIndex == 0) {
        //Navigator.pushNamed(context, '/');
      } else if (_cIndex == 1) {
        Navigator.pushNamed(context, '/map');
      } else if (_cIndex == 2) {
        //Navigator.pushNamed(context, '/home');
      } else if (_cIndex == 3) {
        Navigator.pushNamed(context, '/profile');
      }
      _cIndex = 0;
    });
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
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

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
        title: Text('Cafe App'),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _cIndex,
        type: BottomNavigationBarType.fixed,// this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color.fromARGB(255, 0, 0, 0)),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, color: Color.fromARGB(255, 0, 0, 0)),
            title: Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Color.fromARGB(255, 0, 0, 0)),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0)),
            title: Text('Profile'),
          ),
        ],
        onTap: (index) {
          _incrementTab(index);
        },
        /*
        onTap: (int currentIndex){
          if (currentIndex == 0){
            print("0");
            Navigator.pushNamed(context, '/home');
            print("0!");
          }
          else if (currentIndex == 1){
            print("1");
            Navigator.pushNamed(context, '/map');
            return MapPage();
            print("1!");
          }
          else if (currentIndex == 2){
            print("current Index == 2");

          }
          else{
            print("3");
            Navigator.pushNamed(context, '/profile');
            print("3!");
          }
        },
        */
      ),

      floatingActionButton: FloatingActionButton(
        child:Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddCafePage()));
        }
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('cafe').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return Center(
            child: GridView.count(
              crossAxisCount: 1,
              padding: EdgeInsets.all(16.0),
              childAspectRatio: 7.5 / 9.0,
              children: _buildGridCards(context, snapshot.data.documents),
            ),
          );
        }
      ),
    );
  }
}

class Record {
  final String name;
  final String image;
  final String description;
  final String location;
  final String open;
  final String close;
  final String phone;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['image'] != null),
        assert(map['description'] != null),
        assert(map['location'] != null),
        assert(map['open'] != null),
        assert(map['close'] != null),
        assert(map['phone'] != null),
        name = map['name'],
        image = map['image'],
        description = map['description'],
        location = map['location'],
        open = map['open'],
        close = map['close'],
        phone = map['phone'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$image:$location:$phone:$open:$close:$description>";
}