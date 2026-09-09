import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_bloc.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_event.dart';
import 'package:touring_game/services/game/bloc/catalog/catalog_state.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/dialogs/error_snack_bar.dart';
import 'package:touring_game/utilities/routes.dart';

class PlacesList extends StatefulWidget {
  const PlacesList({super.key});

  @override
  State<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends State<PlacesList> {
  void reloadList() {
    context.read<CatalogBloc>().add(const CatalogLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CatalogBloc, CatalogState>(
      listener: (context, state) {
        if (state.exception != null) {
          showErrorSnackBar(context, state.exception!);
        }
      },
      builder: (context, state) {
        final places = state.places;
        final activities = state.activities;
        if (state.isLoading || places.isNotEmpty) {
          final suggestedActivities = state.suggestedActivities;

          return LoadingOverlay(
            isLoading: state.isLoading,
            text: 'Loading places',
            child: Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 20.0,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onChanged: (value) {
                        context.read<CatalogBloc>().add(
                          CatalogSearchChanged(value),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ListView.builder(
                        itemCount: places.length,
                        itemBuilder: (ctx, index) {
                          var placeActivities = activities.where(
                            (element) => element.placeId == places[index].id,
                          );
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.place_outlined),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    places[index].name,
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${placeActivities.where((element) => element.isDone == true).length}/${placeActivities.length}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                ),
                                child: Icon(
                                  Icons.navigate_next_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                ),
                              ),
                              onTap: () {
                                final selectedActivities = activities
                                    .where(
                                      (activity) =>
                                          activity.placeId == places[index].id,
                                    )
                                    .toList(growable: false);
                                context.push(
                                  activitiesListRoute,
                                  extra: ActivitiesListArguments(
                                    activities: selectedActivities,
                                    onChanged: reloadList,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                          top: 20.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your random',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                  Text(
                                    'activities',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.run_circle, size: 70),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: suggestedActivities.length,
                          itemBuilder: (ctx, index) {
                            return Card(
                              child: SizedBox(
                                width: 200,
                                child: Center(
                                  child: ListTile(
                                    leading: const Icon(Icons.attractions),
                                    title: Text(
                                      suggestedActivities[index].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${suggestedActivities[index].coords.latitude.toStringAsFixed(3)} ${suggestedActivities[index].coords.longitude.toStringAsFixed(3)}",
                                    ),
                                    onTap: () {
                                      context.push(
                                        activityDetailsRoute,
                                        extra: ActivityDetailsArguments(
                                          activity: suggestedActivities[index],
                                          onChanged: (_) => reloadList(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(width: 10);
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          final hasQuery = state.query.trim().isNotEmpty;
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.exception == null
                          ? Icons.travel_explore
                          : Icons.cloud_off,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.exception != null
                          ? 'Could not load places.'
                          : hasQuery
                          ? 'No places match your search.'
                          : 'No places are available yet.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (state.exception != null) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: reloadList,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
