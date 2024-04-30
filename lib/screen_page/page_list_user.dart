import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latihan/Model/Model_user.dart';


class PageListUsers extends StatefulWidget {
  const PageListUsers({super.key});

  @override
  State<PageListUsers> createState() => _PageListUsersState();
}

class _PageListUsersState extends State<PageListUsers> {

  bool isLoading = false;
  List<ModelUsers> listUser = [];

  //method untuk get data dari api
  Future getUser() async{
    try{
      setState((){
        isLoading = true;
      });
      http.Response response = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/users"));
      var data = jsonDecode(response.body);
      setState(() {
        for(Map<String, dynamic> i in data){
          listUser.add(ModelUsers.fromJson(i));
        }
      });
    }catch(e){
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()))
        );
      });
    }
  }

  @override
  void initState(){
    //TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List Users Api"),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
          itemCount: listUser.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, left: 8,
                  right: 8),
              child: Card(
                child: ListTile(
                  title: Text(
                    listUser[index].name ?? "",
                    style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(listUser[index].email ?? ""),
                      Text(listUser[index].address?.city ??
                          ""),
                      Text(listUser[index].company?.name ??
                          ""),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}