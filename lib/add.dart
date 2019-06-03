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
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';


class AddUserPage extends StatefulWidget {
  AddUserPage({ Key key, this.uid,}) : super(key: key);
  final uid;
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  File _image;
  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    Future getImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _image = image;
        print('Image Path $_image');
      });
    }

    Future uploadPic(BuildContext context, AsyncSnapshot snapshot) async {
      String filename = basename(_image.path);
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(filename);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);

      var downurl = await (await uploadTask.onComplete).ref.getDownloadURL();
      String url = downurl.toString();

      setState(() {
        if (_nameController.text.isNotEmpty &&
            _genderController.text.isNotEmpty &&
            _nicknameController.text.isNotEmpty &&
            url != null) {
          Firestore.instance.collection('user').document(widget.uid).setData({
            "name": _nameController.text,
            "gender": _genderController.text,
            "nickname": _nicknameController.text,
            "likedCafe": [],
            "image": url,
          }).then((result) =>
          {
          Navigator.pop(context),
          _nameController.clear(),
          _genderController.clear(),
          _nicknameController.clear(),
          }).catchError((err) => print(err));
        } else {
          print('error');
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(child: Text('Add')),
            ),
            Expanded(
              flex: 1,
              child: StreamBuilder(
                stream: authService.user,
                builder: (context, snapshot) {
                  return FlatButton(
                    onPressed: () {
                      uploadPic(context, snapshot);
                    },
                    child: Text('Save'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: authService.user,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(0),
                          margin: EdgeInsets.all(0),
                          child: Center(
                            child: (_image != null) ? Image.file(_image, width: 300, height: 300, fit: BoxFit.contain,) :
                            Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/cafeappproject.appspot.com/o/noimage.jpg?alt=media&token=38594644-3fd9-4a35-ab6b-e29b66932c04',
                              width: 300,
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
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
                            getImage();
                          },
                        ),
                      ),
                    ),
                    SizedBox(height:20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              labelText: 'User Name',
                            ),
                            controller: _nameController,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              labelText: 'Gender',
                            ),
                            controller: _genderController,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              labelText: 'Nickname',
                            ),
                            controller: _nicknameController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}

class AddCafePage extends StatefulWidget {
  AddCafePage({ Key key, this.uid,}) : super(key: key);
  final uid;
  @override
  _AddCafePageState createState() => _AddCafePageState();
}

class _AddCafePageState extends State<AddCafePage> {
  File _image;
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _openController = TextEditingController();
  final _closeController = TextEditingController();

  String _openValue = "0";
  String _closeValue = "0";
  var _checkFlag = [false, false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    String owner = widget.uid;

    String getTime(String value) {
      String result = "00:00";
      if (value == "1") {
        result = "01:00";
      } else if (value == "2") {
        result = "02:00";
      } else if (value == "3") {
        result = "03:00";
      } else if (value == "4") {
        result = "04:00";
      } else if (value == "5") {
        result = "05:00";
      } else if (value == "6") {
        result = "06:00";
      } else if (value == "7") {
        result = "07:00";
      } else if (value == "8") {
        result = "08:00";
      } else if (value == "9") {
        result = "09:00";
      } else if (value == "10") {
        result = "10:00";
      } else if (value == "11") {
        result = "11:00";
      } else if (value == "12") {
        result = "12:00";
      } else if (value == "13") {
        result = "13:00";
      } else if (value == "14") {
        result = "14:00";
      } else if (value == "15") {
        result = "15:00";
      } else if (value == "16") {
        result = "16:00";
      } else if (value == "17") {
        result = "17:00";
      } else if (value == "18") {
        result = "18:00";
      } else if (value == "19") {
        result = "19:00";
      } else if (value == "20") {
        result = "20:00";
      } else if (value == "21") {
        result = "21:00";
      } else if (value == "22") {
        result = "22:00";
      } else if (value == "23") {
        result = "23:00";
      } else if (value == "24") {
        result = "24:00";
      }

      return result;
    }

    List<DropdownMenuItem<String>> timeDropdown() {
      return [
        DropdownMenuItem<String>(
          value: "0",
          child: Text("00:00"),
        ),
        DropdownMenuItem<String>(
          value: "1",
          child: Text("01:00"),
        ),
        DropdownMenuItem<String>(
          value: "2",
          child: Text("02:00"),
        ),
        DropdownMenuItem<String>(
          value: "3",
          child: Text("03:00"),
        ),
        DropdownMenuItem<String>(
          value: "4",
          child: Text("04:00"),
        ),
        DropdownMenuItem<String>(
          value: "5",
          child: Text("05:00"),
        ),
        DropdownMenuItem<String>(
          value: "6",
          child: Text("06:00"),
        ),
        DropdownMenuItem<String>(
          value: "7",
          child: Text("07:00"),
        ),
        DropdownMenuItem<String>(
          value: "8",
          child: Text("08:00"),
        ),
        DropdownMenuItem<String>(
          value: "9",
          child: Text("09:00"),
        ),
        DropdownMenuItem<String>(
          value: "10",
          child: Text("10:00"),
        ),
        DropdownMenuItem<String>(
          value: "11",
          child: Text("11:00"),
        ),
        DropdownMenuItem<String>(
          value: "12",
          child: Text("12:00"),
        ),
        DropdownMenuItem<String>(
          value: "13",
          child: Text("13:00"),
        ),
        DropdownMenuItem<String>(
          value: "14",
          child: Text("14:00"),
        ),
        DropdownMenuItem<String>(
          value: "15",
          child: Text("15:00"),
        ),
        DropdownMenuItem<String>(
          value: "16",
          child: Text("16:00"),
        ),
        DropdownMenuItem<String>(
          value: "17",
          child: Text("17:00"),
        ),
        DropdownMenuItem<String>(
          value: "18",
          child: Text("18:00"),
        ),
        DropdownMenuItem<String>(
          value: "19",
          child: Text("19:00"),
        ),
        DropdownMenuItem<String>(
          value: "20",
          child: Text("20:00"),
        ),
        DropdownMenuItem<String>(
          value: "21",
          child: Text("21:00"),
        ),
        DropdownMenuItem<String>(
          value: "22",
          child: Text("22:00"),
        ),
        DropdownMenuItem<String>(
          value: "23",
          child: Text("23:00"),
        ),
        DropdownMenuItem<String>(
          value: "24",
          child: Text("24:00"),
        ),
      ];
    }

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
          count = count + 1;
        }
      });
      return temp;
    }

    Future getImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _image = image;
        print('Image Path $_image');
      });
    }

    Future uploadPic(BuildContext context, AsyncSnapshot snapshot) async {
      String filename = basename(_image.path);
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(filename);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);

      var downurl = await (await uploadTask.onComplete).ref.getDownloadURL();
      String url = downurl.toString();

      setState(() {
        if (_nameController.text.isNotEmpty &&
            _locationController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty &&
            _openValue.isNotEmpty &&
            _closeValue.isNotEmpty &&
            url != null) {
          Firestore.instance.collection('cafe').add({
            "name": _nameController.text,
            "location": _locationController.text,
            "description": _descriptionController.text,
            "phone": _phoneController.text,
            "open": getTime(_openValue),
            "close": getTime(_closeValue),
            "owner": owner,
            "image": url,
            "beans": getBeans(),
            "likedUsers": [],
          }).then((result) =>
          {
          Navigator.pop(context),
          _nameController.clear(),
          _locationController.clear(),
          _descriptionController.clear(),
          _phoneController.clear(),
          _openController.clear(),
          _closeController.clear(),
          }).catchError((err) => print(err));
        } else {
          print('error');
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(child: Text('Add')),
            ),
            Expanded(
              flex: 1,
              child: StreamBuilder(
                stream: authService.user,
                builder: (context, snapshot) {
                  return FlatButton(
                    onPressed: () {
                      uploadPic(context, snapshot);
                    },
                    child: Text('Save'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    child: Center(
                      child: (_image != null) ? Image.file(_image, width: 300, height: 300, fit: BoxFit.contain,) :
                      Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/cafeappproject.appspot.com/o/noimage.jpg?alt=media&token=38594644-3fd9-4a35-ab6b-e29b66932c04',
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
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
                      getImage();
                    },
                  ),
                ),
              ),
              SizedBox(height:20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        labelText: 'Cafe Name',
                      ),
                      controller: _nameController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        labelText: 'Location',
                      ),
                      controller: _locationController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        labelText: 'Description',
                      ),
                      controller: _descriptionController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        labelText: 'Phone Number',
                      ),
                      controller: _phoneController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  /*
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        labelText: 'Open Time',
                      ),
                      controller: _openController,
                    ),
                  ),*/
                  Text('Open Time: '),
                  DropdownButton<String>(
                    items: timeDropdown(),
                    onChanged: (value) {
                      setState(() {
                        _openValue = value;
                      });
                    },
                    value: _openValue,
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('Close Time: '),
                  DropdownButton<String>(
                    items: timeDropdown(),
                    onChanged: (value) {
                      setState(() {
                        _closeValue = value;
                      });
                    },
                    value: _closeValue,
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Divider(height: 1.0, color: Colors.white),
              SizedBox(height: 20.0),
              Text("원두 종류"),
              SizedBox(height: 20.0),
              Divider(height: 1.0, color: Colors.white),
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
            ],
          ),
        ),
      ),
    );
  }
}