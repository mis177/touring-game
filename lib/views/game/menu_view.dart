import 'package:flutter/material.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/utilities/dialogs/logout_dialog.dart';
import 'package:touring_game/utilities/menu_actions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/views/game/game_list_view.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _FirstScreemState();
}

class _FirstScreemState extends State<MenuView> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget scaffoldBody() {
    switch (_selectedIndex) {
      case 0:
        return PlacesList();
        break;
      default:
        return Text('a');
      //  case 1:
      // // return mapa
      //  break;
      //  case 2:
      // // return profil
      //  break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogoutDialog(
                        context: context,
                        title: 'Log Out',
                        text: 'Are you sure ypou want to log out?');
                    if (shouldLogout!) {
                      // ignore: use_build_context_synchronously
                      context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
                          );
                    }
                    break;
                  case MenuAction.changeLaguage:
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<MenuAction>(
                      value: MenuAction.logout, child: Text('Log out'))
                ];
              },
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'List',
              backgroundColor: Colors.red,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Colors.purple,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
        body: scaffoldBody());
  }
}
