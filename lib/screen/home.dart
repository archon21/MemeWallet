import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meme/screen/auth/auth.dart';
import 'package:meme/screen/auth/auth_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:meme/screen/exchange/session.dart';

class HomePage extends StatefulWidget {
  const HomePage({this.onSignedOut});
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String session;

  dynamic searchingSessions = false;

  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  Future _createSession(context) async {
    var uuid = new Uuid();
    var id = uuid.v1();
    final BaseAuth auth = AuthProvider.of(context).auth;
    final user = await auth.currentUser();
    final CollectionReference sessions =
        Firestore.instance.collection('sessions');
    await sessions
        .document(id)
        .setData({'id': id, 'hostid': user, 'name': 'Ryan', 'hostimage': '', 'guestimage': ''});
    var route = new MaterialPageRoute(
        builder: (BuildContext context) => new Session( sessionId: id, isHost: true));
    Navigator.of(context).push(route);
  }

  _selectSession(session) {
    var route = new MaterialPageRoute(
        builder: (BuildContext context) => new Session( sessionId: session['id'], isHost: false));
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    if ( !searchingSessions) {
      return new Scaffold(
          appBar: AppBar(
            title: Text('Welcome'),
            actions: <Widget>[
              FlatButton(
                child: Text('Logout',
                    style: TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () => _signOut(context),
              )
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
          body: Container(
              child: Column(children: <Widget>[
            RaisedButton(
                child: Text('Create Session'),
                onPressed: () => _createSession(context)),
            RaisedButton(
                child: Text('Find Session'),
                onPressed: () {
                  setState(() {
                    searchingSessions = true;
                  });
                })
          ])));
    } else {
      return new Scaffold(
        body: new StreamBuilder(
          stream: Firestore.instance.collection('sessions').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading');
            return ListView.builder(
                itemExtent: 80.0,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) =>
                    _buildListItem(context, snapshot.data.documents[index]));
          },
        ),
      );
    }
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot session) {
    return (ListTile(
      title: RaisedButton(
        child: Text(session['name']),
        onPressed: () => _selectSession(session),
      ),
    ));
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,

      items: [
        _buildItem(icon: Icons.adjust, tabItem: 'Home'),
        _buildItem(icon: Icons.clear_all, tabItem: 'Exchange'),
        _buildItem(icon: Icons.arrow_downward, tabItem: 'Wallet'),
        _buildItem(icon: Icons.settings_input_component, tabItem: 'Profile'),
      ],
      // onTap: _onSelectTab,
    );
  }

  BottomNavigationBarItem _buildItem({IconData icon, tabItem}) {
    String text = 'red';
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: Colors.grey[850],
      ),
      title: Text(
        text,
        style: TextStyle(
          color: Colors.grey[850],
        ),
      ),
    );
  }

}
