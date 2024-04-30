import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latihan/screen_page/page_login_api.dart';
import '../model/model_pegawai.dart';
import '../utils/session_manager.dart';

class PageEditKaryawan extends StatefulWidget {
  final Datum data;

  const PageEditKaryawan({Key? key, required this.data}) : super(key: key);

  @override
  State<PageEditKaryawan> createState() => _PageEditKaryawanState();
}

class _PageEditKaryawanState extends State<PageEditKaryawan> {
  late TextEditingController txtNamaLengkap;
  late TextEditingController txtEmail;
  late TextEditingController txtNoBP;
  late TextEditingController txtNoHP;
  GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    txtNamaLengkap = TextEditingController(text: widget.data.nama);
    txtEmail = TextEditingController(text: widget.data.email);
    txtNoBP = TextEditingController(text: widget.data.nobp);
    txtNoHP = TextEditingController(text: widget.data.nohp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Data Pegawai',
          style: TextStyle(
            color: Colors.white, // Ubah warna teks menjadi putih
          ),),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white, // Ubah warna ikon back menjadi putih
        ),
        actions: [
          TextButton(onPressed: () {}, child: Text('Hi ... ${session.userName}')),
          // Logout
          IconButton(
            onPressed: () {
              // Clear session
              setState(() {
                session.clearSession();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => PageLoginApi()),
                      (route) => false,
                );
              });
            },
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
            tooltip: 'Logout',
          )
        ],
      ),
      body: Form(
        key: keyForm,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                TextFormField(
                  controller: txtNamaLengkap,
                  decoration: InputDecoration(
                    hintText: 'Nama Lengkap',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: txtNoBP,
                  decoration: InputDecoration(
                    hintText: 'No BP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: txtEmail,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: txtNoHP,
                  decoration: InputDecoration(
                    hintText: 'No HP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (keyForm.currentState?.validate() == true) {
                      // Kirim data perubahan ke server
                      http.post(
                        Uri.parse('http://192.168.61.97/edukasi_server/updatePegawai.php'),
                        body: {
                          'id': widget.data.id.toString(),
                          'nama': txtNamaLengkap.text,
                          'nobp': txtNoBP.text,
                          'email': txtEmail.text,
                          'nohp': txtNoHP.text,
                        },
                      ).then((response) {
                        if (response.statusCode == 200) {
                          var jsonResponse = json.decode(response.body);
                          if (jsonResponse['is_success'] == true) {
                            // Jika pembaruan berhasil, kembalikan data yang diperbarui ke halaman sebelumnya
                            Datum updatedData = Datum(
                              id: widget.data.id,
                              nama: txtNamaLengkap.text,
                              nobp: txtNoBP.text,
                              email: txtEmail.text,
                              nohp: txtNoHP.text,
                              tanggalInput: widget.data.tanggalInput,
                            );
                            Navigator.pop(context, updatedData);
                          } else {
                            // Jika pembaruan gagal, tampilkan pesan kesalahan
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Gagal"),
                                  content: Text("Terjadi kesalahan: ${jsonResponse['message']}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          // Jika respons server tidak berhasil, tampilkan pesan kesalahan umum
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Gagal"),
                                content: Text("Terjadi kesalahan saat mengirim data ke server"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }).catchError((error) {
                        // Tangani kesalahan koneksi atau lainnya
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Gagal"),
                              content: Text("Terjadi kesalahan: $error"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      });
                    }
                  },
                  child: const Text("SIMPAN"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Pastikan untuk membersihkan controller
    txtNamaLengkap.dispose();
    txtEmail.dispose();
    txtNoBP.dispose();
    txtNoHP.dispose();
    super.dispose();
  }
}