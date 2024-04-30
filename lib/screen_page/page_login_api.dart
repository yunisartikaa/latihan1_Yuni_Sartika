
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latihan/screen_page/page_bottom_navigation.dart';
import 'package:latihan/screen_page/page_register_api.dart';

import '../Model/Model_Login.dart';
import '../utils/session_manager.dart';

class PageLoginApi extends StatefulWidget {
  const PageLoginApi({Key? key});

  @override
  State<PageLoginApi> createState() => _PageLoginApiState();
}

class _PageLoginApiState extends State<PageLoginApi> {
  TextEditingController txtUsername = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  bool isLoading = false;

  Future<ModelLogin?> registerAccount() async {
    try {
      setState(() {
        isLoading = true;
      });
      http.Response response = await http.post(
        Uri.parse('http://192.168.61.97/edukasi_server/login.php'),
        body: {
          "username": txtUsername.text,
          "password": txtPassword.text,
        },
      );
      ModelLogin data = modelLoginFromJson(response.body);
      if (data.value == 1) {
        setState(() {
          isLoading = false;
          session.saveSession(data.value ?? 0, data.id ?? "", data.username ?? "");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${data.message}')));

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder:(context) => PageBottomNavigationBar()),
                (route) => false,
          );
        });
      } else {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${data.message}')));
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Form  Login',
          style: TextStyle(
            color: Colors.white, // Ubah warna teks menjadi putih
          ),
        ),
      ),
      body: Form(
        key: keyForm,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20,),
                // Username field with icon
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.person), // Username icon
                    ),
                    Expanded(
                      child: TextFormField(
                        validator: (val){
                          return val!.isEmpty ? "Tidak boleh kosong " : null;
                        },
                        controller: txtUsername,
                        decoration: InputDecoration(
                          hintText: 'Input Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8,),
                // Password field with icon
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.lock), // Password icon
                    ),
                    Expanded(
                      child: TextFormField(
                        validator: (val){
                          return val!.isEmpty ? "Tidak boleh kosong " : null;
                        },
                        controller: txtPassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Input Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                Center(
                  child: isLoading ? Center(
                    child: CircularProgressIndicator(),
                  ) : MaterialButton(
                    onPressed: (){
                      if(keyForm.currentState?.validate() == true){
                        setState(() {
                          registerAccount();
                        });
                      }
                    },
                    child: Text('Login'),
                    color: Colors.green,
                    textColor: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10),
        child: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 1, color: Colors.green),
          ),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageRegisterApi()));
          },
          child: Text('Anda belum punya account? Silakan Register'),
        ),
      ),
    );
  }
}