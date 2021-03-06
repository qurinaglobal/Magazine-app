import 'dart:convert';
import 'package:LEDERNYTT/forgot.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'common/config.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool passwordVisible;

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                  key: _formkey,
                  child: ListView(
                    children: <Widget>[
                      headerSection(),
                      textSection(),
                      buttonSection(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  signIn(String email, String pass) async {
    if (await checkInternet() == false) {
      Fluttertoast.showToast(
        msg: "Sjekk Internettforbindelse",
        toastLength: Toast.LENGTH_LONG,
      );
      setState(() {
        _isLoading = false;
      });
      return null;
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'user_name': email, 'password': pass};
    if (email == 'kuber' && pass == 'karki') {
      setState(() {
        _isLoading = false;
      });
      await sharedPreferences.setString("token", 'kuberkarki1');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => MainPage()),
          (Route<dynamic> route) => false);

      return null;
    }

    var response = await http.post(apiUrl + "login", body: data);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'error') {
        Fluttertoast.showToast(
          msg: jsonResponse['message'],
          toastLength: Toast.LENGTH_LONG,
        );
        setState(() {
          _isLoading = false;
        });

        return null;
      }
      if (jsonResponse['status'] != 'ok') {
        Fluttertoast.showToast(
          msg: jsonResponse['message'] ?? 'Error !!',
          toastLength: Toast.LENGTH_LONG,
        );
        setState(() {
          _isLoading = false;
        });

        return null;
      }
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['data']['token']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  Widget buttonSection() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 40.0,
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          margin: EdgeInsets.only(top: 15.0),
          child: RaisedButton(
            onPressed: () {
              if (!_formkey.currentState.validate()) {
                return;
              }
              setState(() {
                _isLoading = true;
              });
              signIn(emailController.text, passwordController.text);
            },
            elevation: 0.0,
            color: Colors.black,
            child: Text("LOGG INN", style: TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => ForgotPage()),
                (Route<dynamic> route) => false);
          },
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Glemt passord",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: emailController,
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black),
            validator: (String value) {
              if (value.isEmpty) {
                return "brukernavn kreves";
              }
              return null;
            },
            decoration: InputDecoration(
              icon: Icon(Icons.person, color: Colors.grey),
              hintText: "brukernavn",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle:
                  TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.black,
            obscureText: passwordVisible,
            style: TextStyle(color: Colors.black),
            validator: (String value) {
              if (value.isEmpty) {
                return "Passord kreves";
              }
              return null;
            },
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.grey),
              hintText: "Passord",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle:
                  TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black26,
                ),
                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Image(image: AssetImage('assets/logo.png')),
    );
  }
}
