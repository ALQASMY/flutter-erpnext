import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spackerpnext/components/my_button.dart';
import 'package:spackerpnext/components/my_textfield.dart';
import 'package:spackerpnext/pages/supplier_reports.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPACK Login',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<String?>(
        future: getHeader(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return snapshot.data != null ? RepSupplierBalanceFdtd() : MyHomePage(title: 'Login');
            }
          }
        },
      ),
    );
  }

  Future<String?> getHeader() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('header');
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = 'خطاء في ادخال المستخدم او كلمة السر';

  Future<String> loginAndGetHeader() async {
    var baseUrl = "http://192.168.56.101:8000";
    var response = await http.get(
      Uri.parse(baseUrl + "/api/method/login?usr=" + _usernameController.text + "&pwd=" + _passwordController.text),
    );
    if (response.statusCode == 200) {
      String header = response.headers['set-cookie'] ?? '';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('header', header);
      return header;
    } else {
      print('Login request failed with status: ${response.statusCode}.');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('lib/images/spack.png'),
            Text(
              'اهلا بك في اس باك يرجي ادخال المستخدم وكلمة السر',
              style: TextStyle(
                color: Colors.lightGreen,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            // username textfield
            MyTextField(
              controller: _usernameController,
              hintText: 'Username',
              obscureText: false,
            ),
            const SizedBox(height: 10),
            // password textfield
            MyTextField(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                String header = await loginAndGetHeader();
                if (header.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RepSupplierBalanceFdtd()),
                  );
                } else {
                  setState(() {
                    _errorMessage = 'خطأ في اسم المستخدم أو كلمة المرور';
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "تسجيل دخول",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
