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

  @override
  Widget build(BuildContext context) {
    String owner = widget.uid;

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
            _openController.text.isNotEmpty &&
            _closeController.text.isNotEmpty &&
            url != null) {
          Firestore.instance.collection('cafe').add({
            "name": _nameController.text,
            "location": _locationController.text,
            "description": _descriptionController.text,
            "phone": _phoneController.text,
            "open": _openController.text,
            "close": _closeController.text,
            "owner": owner,
            "image": url,
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
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        labelText: 'Open Time',
                      ),
                      controller: _openController,
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
                        labelText: 'Close Time',
                      ),
                      controller: _closeController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}