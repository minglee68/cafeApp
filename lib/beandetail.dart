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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'package:charts_flutter/flutter.dart';

class BeanDetailPage extends StatefulWidget {
  BeanDetailPage({ Key key, this.name,}) : super(key: key);
  final name;
  @override
  _BeanDetailPageState createState() => _BeanDetailPageState();
}

class _BeanDetailPageState extends State<BeanDetailPage> {

  List<Series<BeanStatus, String>> _createData(BeanRecord temp) {

    final data = [
      new BeanStatus('향', temp.aroma),
      new BeanStatus('산도', temp.acidity),
      new BeanStatus('단맛', temp.sweetness),
      new BeanStatus('쓴맛', temp.bitterness),
      new BeanStatus('바디', temp.body),
    ];

    return [
      new Series<BeanStatus, String>(
        id: 'Sales',
        colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
        domainFn: (BeanStatus status, _) => status.name,
        measureFn: (BeanStatus status, _) => status.status,
        data: data,
      )
    ];
  }

  BeanRecord _beanInfo(BuildContext context, List<DocumentSnapshot> snapshot, String name) {
    BeanRecord temp;
    snapshot.map((data) {
      final record = BeanRecord.fromSnapshot(data);
      if (record.name.compareTo(name) == 0)
        temp = record;
    }).toList();

    return temp;
  }

  @override
  Widget build(BuildContext context) {

    Future<void> _showResult(BuildContext context) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('원두는 이렇게 봅니다!'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text('향(Aroma)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Divider(height: 1.0, color: Colors.white),
                  Text('커피 추출시 발산되는 가스, 커피의 향기를 의미합니다'),
                  SizedBox(height: 40),
                  Text('산도(Acidity)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Divider(height: 1.0, color: Colors.white),
                  Text('커피의 산뜻함과 풍미를 결정지으며, 신맛의 정도입니다'),
                  SizedBox(height: 40),
                  Text('단맛(Sweetness)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Divider(height: 1.0, color: Colors.white),
                  Text('원두의 달달한 맛을 의미합니다'),
                  SizedBox(height: 40),
                  Text('쓴맛(Bitterness)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Divider(height: 1.0, color: Colors.white),
                  Text('원두의 약간 쓰거나 불맛나는 향을 의미합니다'),
                  SizedBox(height: 40),
                  Text('바디(Body)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Divider(height: 1.0, color: Colors.white),
                  Text('커피를 입에 머금었을 때 느껴지는 밀도와 무게감을 뜻합니다'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('돌아가기'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }

    return StreamBuilder(
      stream: authService.user,
      builder: (context, snapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('beans').snapshots(),
          builder: (context, product) {
            if (!product.hasData) return LinearProgressIndicator();
            BeanRecord record = _beanInfo(context, product.data.documents, widget.name);
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.name),
              ),
              body: Center(
                child: ListView(
                  children: [
                    Image.network(
                      record.image,
                      width: 400,
                      height: 400,
                    ),
                    Container(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 40),
                          Text(record.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          SizedBox(height: 40),
                          Divider(height: 1.0, color: Colors.white),
                          SizedBox(height: 20),
                          Text(record.description),
                          SizedBox(height: 20),
                          Padding(
                              padding: EdgeInsets.all(32.0),
                              child: SizedBox(
                                height: 200,
                                child: BarChart(
                                  _createData(record),
                                  domainAxis: OrdinalAxisSpec(
                                    renderSpec: SmallTickRendererSpec(
                                      labelStyle: TextStyleSpec(
                                        fontSize: 18,
                                        color: MaterialPalette.white,
                                      ),
                                      lineStyle: LineStyleSpec(
                                        color: MaterialPalette.white,
                                      ),
                                    ),
                                  ),
                                  primaryMeasureAxis: NumericAxisSpec(
                                    tickProviderSpec: BasicNumericTickProviderSpec(desiredTickCount: 6),
                                    renderSpec: GridlineRendererSpec(
                                      labelStyle: TextStyleSpec(
                                        fontSize: 16,
                                        color: MaterialPalette.white,
                                      ),
                                      lineStyle: LineStyleSpec(
                                        color: MaterialPalette.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          ),
                          FlatButton(
                            child: Text("원두의 맛은 어떻게 보나요?"),
                            onPressed: () {
                              _showResult(context);
                            },
                          )
                        ],
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

class BeanStatus {
  final String name;
  final int status;

  BeanStatus(this.name, this.status);
}

class BeanRecord {
  final String name;
  final int acidity;
  final int aroma;
  final int bitterness;
  final int body;
  final int sweetness;
  final String description;
  final String image;
  final DocumentReference reference;

  BeanRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['acidity'] != null),
        assert(map['aroma'] != null),
        assert(map['bitterness'] != null),
        assert(map['body'] != null),
        assert(map['sweetness'] != null),
        assert(map['description'] != null),
        assert(map['image'] != null),
        name = map['name'],
        acidity = map['acidity'],
        aroma = map['aroma'],
        bitterness = map['bitterness'],
        body = map['body'],
        sweetness = map['sweetness'],
        description = map['description'],
        image = map['image'];

  BeanRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);


  @override
  String toString() => "BeanRecord<$name:$acidity:$aroma:$bitterness:$body:$sweetness:$description:$image>";
}