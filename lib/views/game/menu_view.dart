import 'package:flutter/material.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/game/bloc/game_bloc.dart';
import 'package:touring_game/services/game/bloc/game_event.dart';
import 'package:touring_game/services/game/bloc/game_state.dart';
import 'package:touring_game/services/game/game_provider.dart';
import 'package:touring_game/services/game/game_service.dart';
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
      create: (context) => GameBloc(
          FirebaseCloudGameService(provider: FirebaseCloudGameProvider())),
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
  bool themeSwitch = true;

  @override
  void initState() {
    context.read<GameBloc>().add(
          const GameEventLoadPlaces(),
        );
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
        return const Center(child: Text('TODO'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        Widget bottomNawigation;
        if (state is GameStateLoadedPlaces) {
          String doneActivities = state.activitiesList
              .where((element) => element.isDone)
              .length
              .toString();
          bottomNawigation = bottomNavigationWidgets(
              activitiesDone: '$doneActivities/${state.activitiesList.length}');
        } else {
          bottomNawigation = bottomNavigationWidgets();
        }

        return Scaffold(
            appBar: AppBar(
              title: Text(
                _scaffoldText,
              ),
              actions: [
                PopupMenuButton<MenuAction>(
                  onSelected: (value) async {
                    switch (value) {
                      case MenuAction.logout:
                        final shouldLogout = await showLogoutDialog(
                            context: context,
                            title: 'Log Out',
                            text: 'Are you sure you want to log out?');
                        if (shouldLogout!) {
                          // ignore: use_build_context_synchronously
                          context.read<AuthBloc>().add(
                                const AuthEventLogOut(),
                              );
                        }
                        break;

                      case MenuAction.about:
                        showAboutDialog(
                          context: context,
                          applicationName: 'Touring App',
                          applicationIcon: SizedBox(
                              height: MediaQuery.of(context).size.height / 8,
                              width: MediaQuery.of(context).size.height / 8,
                              child: Image.asset('lib/images/app_icon.png')),
                        );
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<MenuAction>(
                          value: MenuAction.about, child: Text('About')),
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
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onMenuItemTapped,
            ),
            body: bottomNawigation);
      },
    );
  }
}
