import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

final uuid = new Uuid();

class Session extends StatefulWidget {
  final String sessionId;
  final String userId;
  bool isHost;

  Session({Key key, this.sessionId, this.isHost, this.userId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SessionState();
}

class SessionState extends State<Session> {
  String _selectedImage;
  String sessionName;

  Future _handleOpenGallery() async {
    File image;
    dynamic imageId = uuid.v1();
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(imageId);
    final StorageUploadTask task = firebaseStorageRef.putFile(image);
    StorageTaskSnapshot storageTaskSnapshot = await task.onComplete;

    final CollectionReference sessions =
        Firestore.instance.collection('sessions');
    final path = await storageTaskSnapshot.ref.getDownloadURL();
   var updateData = widget.isHost ? {'guestimage': path} : {'hostimage': path};
    sessions.document(widget.sessionId).updateData(updateData);
  }

    Future _handleRemoveImage() async {
    var updateData = widget.isHost ? {'guestimage': ''} : {'hostimage': ''};
    final CollectionReference sessions =
        Firestore.instance.collection('sessions');
    sessions.document(widget.sessionId).updateData(updateData);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.sessionId);
    return new Scaffold(
        appBar: AppBar(
          title: Text("$sessionName's session"),
        ),
        bottomNavigationBar: BottomAppBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: _handleOpenGallery,
        ),
        body: new StreamBuilder(
            stream: Firestore.instance
                .collection('sessions')
                .document(widget.sessionId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Text('Loading');
              else {
                try {
                  String  image = widget.isHost ?   snapshot.data['guestimage'] :snapshot.data['hostimage'];
                  return Column(children: <Widget>[
                    Image.network(image),
                    RaisedButton(child:Text('Remove Image'), onPressed: _handleRemoveImage,)
                  ]);
                } catch (err) {
                  return Text('Nothing here yet...');
                }
              }

              // return new Image.network(sessionData['image']);
            }));
  }
}
