import 'package:flutter/material.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_bloc.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_event.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_state.dart';
import 'package:touring_game/services/game/game_repository.dart';
import 'package:touring_game/utilities/dialogs/logout_dialog.dart';
import 'package:touring_game/utilities/menu_actions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/views/auth/profile_info_view.dart';
import 'package:touring_game/views/game/activities/activities_map.dart';
import 'package:touring_game/views/game/places/places_list_view.dart';

class AppMenuView extends StatelessWidget {
  const AppMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CatalogBloc(context.read<CatalogRepository>()),
      child: const MenuView(),
    );
  }
}

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuView();
}

class _MenuView extends State<MenuView> {
  int _selectedIndex = 0;
  String _scaffoldText = 'Places list';

  @override
  void initState() {
    context.read<CatalogBloc>().add(const CatalogLoadRequested());
    super.initState();
  }

  void _onMenuItemTapped(int index) {
    switch (index) {
      case 0:
        _scaffoldText = 'Places list';
      case 1:
        _scaffoldText = 'Activities map';
      case 2:
        _scaffoldText = 'Profile';
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget bottomNavigationWidgets({String? activitiesDone}) {
    switch (_selectedIndex) {
      case 0:
        return const PlacesList();
      case 1:
        return const ActivitiesMapProvider();
      case 2:
        return ProfileInfoView(activitiesDone: activitiesDone);
      default:
        return const Center(child: Text('Page unavailable'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        Widget bottomNavigation;
        final activities = state.activities;
        if (activities.isNotEmpty) {
          String doneActivities = activities
              .where((element) => element.isDone)
              .length
              .toString();
          bottomNavigation = bottomNavigationWidgets(
            activitiesDone: '$doneActivities/${activities.length}',
          );
        } else {
          bottomNavigation = bottomNavigationWidgets();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_scaffoldText),
            actions: [
              PopupMenuButton<MenuAction>(
                onSelected: (value) async {
                  switch (value) {
                    case MenuAction.logout:
                      final shouldLogout = await showLogoutDialog(
                        context: context,
                        title: 'Log Out',
                        text: 'Are you sure you want to log out?',
                      );
                      if (shouldLogout == true) {
                        if (!context.mounted) {
                          return;
                        }
                        context.read<AuthBloc>().add(const AuthEventLogOut());
                      }
                      break;

                    case MenuAction.about:
                      showAboutDialog(
                        context: context,
                        applicationName: 'Touring App',
                        applicationIcon: SizedBox(
                          height: MediaQuery.of(context).size.height / 8,
                          width: MediaQuery.of(context).size.height / 8,
                          child: Image.asset('lib/images/app_icon.png'),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<MenuAction>(
                      value: MenuAction.about,
                      child: Text('About'),
                    ),
                    const PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Text('Log out'),
                    ),
                  ];
                },
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'List',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onMenuItemTapped,
          ),
          body: bottomNavigation,
        );
      },
    );
  }
}
