
import 'package:flutter/material.dart';
import 'package:latihan/screen_page/page_list_berita.dart';
import 'package:latihan/screen_page/page_list_pegawai.dart';
import 'package:latihan/screen_page/page_profil_user.dart';
import '../../utils/session_manager.dart';


class PageBottomNavigationBar extends StatefulWidget {
  const PageBottomNavigationBar({Key? key});

  @override
  State<PageBottomNavigationBar> createState() =>
      _PageBottomNavigationBarState();
}

class _PageBottomNavigationBarState extends State<PageBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  Color? containerColor;
  late SessionManager sessionManager;

  @override
  void initState() {
    super.initState();
    sessionManager = SessionManager();
    sessionManager.getSession();
    tabController = TabController(length: 3, vsync: this);
    containerColor = Colors.transparent;
    tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {
      containerColor = Colors.blue;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            containerColor = Colors.blue;
          });
        },
        child: TabBarView(
          controller: tabController,
          children: [
            // content
            PageKaryawan(),
            PageListBerita(),
            PageProfileUser()
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TabBar(
            controller: tabController,
            labelColor: Colors.blue,
            tabs: const [
              Tab(
                text: "Pegawai",
                icon: Icon(Icons.search),
              ),
              Tab(
                text: "Berita",
                icon: Icon(Icons.person_add),
              ),
              Tab(
                text: "Profil",
                icon: Icon(Icons.person),
              ),
            ],
          ),
        ),
      ),
    );
  }
}