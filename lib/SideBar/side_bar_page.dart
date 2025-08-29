import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shareanything/Modules/file_share.dart';
import 'package:shareanything/Modules/home_module.dart';
import 'package:shareanything/Modules/lost_found.dart';
import 'package:shareanything/Modules/private_messaegs.dart';
import 'package:shareanything/Modules/public_messages.dart';
import 'package:shareanything/Provider/side_bar_provide.dart';

class SideBarPage extends StatefulWidget {
  const SideBarPage({super.key});

  @override
  State<SideBarPage> createState() => _SideBarPageState();
}

class _SideBarPageState extends State<SideBarPage> {
  final List<Map<String, dynamic>> _sideBarList = [
    {"icon": Icons.home, "title": "Home"},
    {"icon": Icons.public, "title": "Public Messages"},
    {"icon": Icons.lock, "title": "Private Messages"},
    {"icon": Icons.file_copy, "title": "File Share"},
    {"icon": Icons.search, "title": "Lost and Found"},
  ];

  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<SideBarProvider>(
      builder: (ctx, provider, __) {
        return Scaffold(
          body: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.grey[200],
                  child: ListView.builder(
                    itemCount: sideBarList.length,
                    itemBuilder: (context, index) {
                      final item = sideBarList[index];
                      final isSelected = provider.getIndex() == index;
                      return ListTile(
                        leading: Icon(
                          item.icon,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.black,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        tileColor: isSelected ? Colors.white : null,
                        onTap: () {
                          context.read<SideBarProvider>().changeIndex(index);
                        },
                      );
                    },
                  ),
                ),
              ),

              Expanded(
                flex: 8,
                child: Builder(
                  builder: (_) {
                    switch (provider.getIndex()) {
                      case 0:
                        return HomePage(size.width);
                      case 1:
                        return PublicMessagesPage();
                      case 2:
                        return FileSharePage();
                      case 3:
                        return LostAndFoundPage();
                      case 4:
                        return PrivateMessagesPage();
                      default:
                        return Center(child: Text("Select a Module"));
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SideBarItem {
  final IconData icon;
  final String title;

  SideBarItem({required this.icon, required this.title});
}

final List<SideBarItem> sideBarList = [
  SideBarItem(icon: Icons.home, title: "Home"),
  SideBarItem(icon: Icons.public, title: "Public Messages"),
  SideBarItem(icon: Icons.file_copy, title: "File Share"),
  SideBarItem(icon: Icons.search, title: "Lost and Found"),
  SideBarItem(icon: Icons.lock, title: "Private Messages"),
];
