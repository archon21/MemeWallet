// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   State createState() => new LoginPageState();
// }

// class LoginPageState extends State<LoginPage> {

//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       backgroundColor: Colors.red,
//       // body: StreamBuilder(
//       //   stream: Firestore.instance.collection('users').snapshots(),
//       //   builder: (context, snapshot) {
//       //     if (!snapshot.hasData) return const Text('Loading');
//       //     return new Column(
//       //       children: <Widget>[
//       //         new Text(snapshot.data.documents[0]['fname']),
//       //       ],
//       //     );
//       //   },
//       // ));
//       body: new Stack(
//         children: <Widget>[
//           new Form(
//             child: new Theme(
//               data: new ThemeData(
//                   brightness: Brightness.dark,
//                   primarySwatch: Colors.red,
//                   inputDecorationTheme: new InputDecorationTheme(
//                       labelStyle:
//                           new TextStyle(color: Colors.red, fontSize: 20.0))),
//               child: new Container(
//                 padding: const EdgeInsets.all(40.0),
//                 child: new Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     new Image(
//                       image: new AssetImage('assets/wallet.png'),
//                       fit: BoxFit.cover,
//                       width: 200.0,
//                     ),
//                     new TextFormField(
//                       decoration: new InputDecoration(hintText: 'Email'),
//                       keyboardType: TextInputType.emailAddress,
//                     ),
//                     new TextFormField(
//                       decoration: new InputDecoration(hintText: 'Password'),
//                       keyboardType: TextInputType.text,
//                       obscureText: true,
//                     ),
//                     new Padding(
//                       padding: const EdgeInsets.only(top: 20.0),
//                     ),
//                     new MaterialButton(
//                       color: Colors.black12,
//                       textColor: Colors.white,
//                       child: new Text('Login'),
//                       onPressed: () => {},
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:meme/screen/auth/auth.dart';
import 'package:meme/screen/auth/auth_provider.dart';

class EmailFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Email can\'t be empty' : null;
  }
}

class PasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Password can\'t be empty' : null;
  }
}

class NameFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Name can\'t be empty' : null;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({this.onSignedIn});
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

enum FormType {
  login,
  register,
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  String _fname;
  String _lname;
  FormType _formType = FormType.login;

  bool validateAndSave() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        final BaseAuth auth = AuthProvider.of(context).auth;
        if (_formType == FormType.login) {
          final String userId =
              await auth.signInWithEmailAndPassword(_email, _password);
          print('Signed in: $userId');
        } else {
          final String userId = await auth.createUserWithEmailAndPassword(
              _email, _password, _fname, _lname);
          print('Registered user: $userId');
        }
        widget.onSignedIn();
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome to Meme Wallet',
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.deepPurpleAccent[100],
        child: Form(
          key: formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children:
                  buildIcon() + buildInputs(_formType) + buildSubmitButtons()),
        ),
      ),
    );
  }

  List<Widget> buildIcon() {
    return <Widget>[
      Image(
        image: new AssetImage('assets/wallet.png'),
        fit: BoxFit.cover,
        width: 150.0,
      )
    ];
  }

  List<Widget> buildInputs(formType) {
    print(formType);
    if (formType == FormType.login) {
      return <Widget>[
        TextFormField(
          key: Key('email'),
          decoration: InputDecoration(labelText: 'Email'),
          validator: EmailFieldValidator.validate,
          onSaved: (String value) => _email = value,
        ),
        TextFormField(
          key: Key('password'),
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: PasswordFieldValidator.validate,
          onSaved: (String value) => _password = value,
        )
      ];
    } else {
      return <Widget>[
        TextFormField(
          key: Key('email'),
          decoration: InputDecoration(labelText: 'Email'),
          validator: EmailFieldValidator.validate,
          onSaved: (String value) => _email = value,
        ),
        TextFormField(
          key: Key('password'),
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: PasswordFieldValidator.validate,
          onSaved: (String value) => _password = value,
        ),
        TextFormField(
          key: Key('fname'),
          decoration: InputDecoration(labelText: 'First Name'),
          validator: NameFieldValidator.validate,
          onSaved: (String value) => _fname = value,
        ),
        TextFormField(
          key: Key('lname'),
          decoration: InputDecoration(labelText: 'Last Name'),
          validator: NameFieldValidator.validate,
          onSaved: (String value) => _lname = value,
        ),
      ];
    }
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return <Widget>[
        RaisedButton(
          key: Key('signIn'),
          color: Colors.grey[850],
          child: Text('Login',
              style: TextStyle(color: Colors.white, fontSize: 20.0)),
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child: Text('Create an account', style: TextStyle(fontSize: 20.0)),
          onPressed: moveToRegister,
        ),
      ];
    } else {
      return <Widget>[
        RaisedButton(
          child: Text('Create an account', style: TextStyle(fontSize: 20.0)),
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child:
              Text('Have an account? Login', style: TextStyle(fontSize: 20.0)),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
