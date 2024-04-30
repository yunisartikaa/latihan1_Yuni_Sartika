import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latihan/screen_page/page_bottom_navigation.dart';
import 'package:latihan/screen_page/page_edit_pegawai.dart';
import 'package:latihan/screen_page/page_login_api.dart';
import '../model/model_pegawai.dart';
import '../utils/session_manager.dart';

class PageKaryawan extends StatefulWidget {
  @override
  State<PageKaryawan> createState() => _PageKaryawanState();
}

class _PageKaryawanState extends State<PageKaryawan> {
  List<Datum> pegawaiList = [];
  List<Datum> filteredPegawaiList = [];
  TextEditingController txtCari = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
          Uri.parse("http://192.168.61.97/edukasi_server/getPegawai.php"));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['isSuccess'] == true) {
          setState(() {
            pegawaiList = List<Datum>.from(
                jsonResponse['data'].map((x) => Datum.fromJson(x)));
            filteredPegawaiList = List<Datum>.from(pegawaiList);
          });
        } else {
          throw Exception('Failed to load data: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  void filterPegawaiList(String keyword) {
    setState(() {
      filteredPegawaiList = pegawaiList
          .where((pegawai) =>
      pegawai.nama.toLowerCase().contains(keyword.toLowerCase()) ||
          pegawai.nobp.toLowerCase().contains(keyword.toLowerCase()) ||
          pegawai.email.toLowerCase().contains(keyword.toLowerCase()) ||
          pegawai.nohp.toLowerCase().contains(keyword.toLowerCase()) ||
          (pegawai.tanggalInput != null &&
              pegawai.tanggalInput
                  .toString()
                  .toLowerCase()
                  .contains(keyword.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Pegawai',
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
            tooltip: 'Logout',
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: txtCari,
              decoration: InputDecoration(
                hintText: 'Cari Pegawai...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                filterPegawaiList(value);
              },
            ),
          ),
          Expanded(
            child: filteredPegawaiList.isEmpty
                ? Center(
              child: Text('Data tidak ditemukan'),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Nama',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'Nama',
                  ),
                  DataColumn(
                    label: Text(
                      'No BP',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'No BP',
                  ),
                  DataColumn(
                    label: Text(
                      'Email',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'Email',
                  ),
                  DataColumn(
                    label: Text(
                      'No. HP',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'No. HP',
                  ),
                  DataColumn(
                    label: Text(
                      'Tanggal Daftar',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'Tanggal Daftar',
                  ),
                  DataColumn(
                    label: Text(
                      'Aksi',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    tooltip: 'Aksi',
                  ),
                ],
                rows: filteredPegawaiList
                    .asMap()
                    .entries
                    .map(
                      (entry) => DataRow(
                    cells: [
                      DataCell(Text(entry.value.nama)),
                      DataCell(Text(entry.value.nobp)),
                      DataCell(Text(entry.value.email)),
                      DataCell(Text(entry.value.nohp)),
                      DataCell(
                        Text(
                          entry.value.tanggalInput != null
                              ? entry.value.tanggalInput.toString()
                              : '',
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Hapus data karyawan
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Konfirmasi Hapus'),
                                    content: Text('Apakah Anda yakin ingin menghapus data ini?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false); // Tutup dialog
                                        },
                                        child: Text('Tidak'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Kirim request untuk menghapus data karyawan
                                          http.post(
                                            Uri.parse('http://192.168.61.97/edukasi_server/deletePegawai.php'),
                                            body: {'id': entry.value.id.toString()}, // Kirim ID karyawan yang akan dihapus
                                          ).then((response) {
                                            // Memeriksa respons dari server
                                            if (response.statusCode == 200) {
                                              var jsonResponse = json.decode(response.body);
                                              if (jsonResponse['isSuccess'] == true) {
                                                // Jika penghapusan berhasil, hapus data dari daftar
                                                setState(() {
                                                  filteredPegawaiList.removeAt(entry.key);
                                                });
                                              } else {
                                                // Jika penghapusan gagal, tampilkan pesan kesalahan
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text("Berhasil"),
                                                      content: Text("${jsonResponse['message']}"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => PageBottomNavigationBar()),
                                                                  (route) => false, // Hapus semua halaman yang ada di dalam stack navigasi
                                                            );
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
                                          Navigator.of(context).pop(true); // Tutup dialog
                                        },
                                        child: Text('Ya'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(Icons.delete),
                            ),
                            IconButton(
                              onPressed: () {
                                // Edit data karyawan
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PageEditKaryawan( data: entry.value),
                                  ),
                                ).then((updatedData) {
                                  if (updatedData != null) {
                                    // Perbarui data karyawan yang ada dengan data yang telah diubah
                                    setState(() {
                                      // Cari indeks data karyawan yang diperbarui
                                      int dataIndex = filteredPegawaiList.indexWhere((pegawai) => pegawai.id == updatedData.id);
                                      if (dataIndex != -1) {
                                        filteredPegawaiList[dataIndex] = updatedData;
                                      }
                                    });
                                  }
                                });
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PageTambahKaryawan()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class PageTambahKaryawan extends StatefulWidget {
  const PageTambahKaryawan({Key? key});

  @override
  State<PageTambahKaryawan> createState() => _PageTambahKaryawanState();
}

class _PageTambahKaryawanState extends State<PageTambahKaryawan> {
  TextEditingController txtNamaLengkap = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtNoBP = TextEditingController();
  TextEditingController txtNoHP = TextEditingController();
  GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Data Pegawai',
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
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
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
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
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
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
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
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
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
                      // Membuat objek data karyawan dari input pengguna
                      var dataKaryawan = {
                        'nama': txtNamaLengkap.text,
                        'nobp': txtNoBP.text,
                        'email': txtEmail.text,
                        'nohp': txtNoHP.text,
                      };

                      // Mengirim data ke server
                      http.post(
                        Uri.parse('http://192.168.61.97/edukasi_server/simpanPegawai.php'),
                        body: dataKaryawan,
                      ).then((response) {
                        // Memeriksa respons dari server
                        if (response.statusCode == 200) {
                          var jsonResponse = json.decode(response.body);
                          if (jsonResponse['isSuccess'] == true) {
                            // Jika penyimpanan berhasil, berikan respons kepada pengguna
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Sukses"),
                                  content: Text("Data karyawan berhasil disimpan"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        // Kembali ke halaman sebelumnya sampai dengan halaman PageKaryawan
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (context) => PageBottomNavigationBar()),
                                              (route) => false, // Hapus semua halaman yang ada di dalam stack navigasi
                                        );
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Jika penyimpanan gagal, tampilkan pesan kesalahan
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
}