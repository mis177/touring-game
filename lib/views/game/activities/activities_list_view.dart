import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/services/game/bloc/activities/activities_cubit.dart';
import 'package:touring_game/utilities/map/activities_filter_button.dart';
import 'package:touring_game/utilities/routes.dart';

class ActivitiesListProvider extends StatelessWidget {
  const ActivitiesListProvider({super.key, required this.arguments});

  final ActivitiesListArguments arguments;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivitiesCubit(arguments.activities),
      child: ActivitiesList(onChanged: arguments.onChanged),
    );
  }
}

class ActivitiesList extends StatelessWidget {
  const ActivitiesList({super.key, required this.onChanged});

  final VoidCallback onChanged;

  void _updateActivity(BuildContext context, DatabaseActivity updatedActivity) {
    context.read<ActivitiesCubit>().replace(updatedActivity);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesCubit, ActivitiesState>(
      builder: (context, state) {
        final finishedSelected = state.filter == ActivityStatusFilter.finished;
        final unfinishedSelected =
            state.filter == ActivityStatusFilter.unfinished;
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Activities list',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onChanged: context.read<ActivitiesCubit>().search,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: getFilterButton(
                          clickedThis: unfinishedSelected,
                          clickedOther: finishedSelected,
                          function: () => context
                              .read<ActivitiesCubit>()
                              .toggleFilter(ActivityStatusFilter.unfinished),
                          text: 'Unfinished',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: getFilterButton(
                          clickedThis: finishedSelected,
                          clickedOther: unfinishedSelected,
                          function: () => context
                              .read<ActivitiesCubit>()
                              .toggleFilter(ActivityStatusFilter.finished),
                          text: 'Finished',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.activities.length,
                    itemBuilder: (context, index) {
                      final activity = state.activities[index];
                      final color = activity.isDone
                          ? Colors.green
                          : Theme.of(context).colorScheme.onSurface;
                      return Card(
                        shadowColor: color,
                        child: ListTile(
                          leading: const Icon(Icons.attractions),
                          title: Text(
                            activity.name,
                            style: TextStyle(color: color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => context.push(
                            activityDetailsRoute,
                            extra: ActivityDetailsArguments(
                              activity: activity,
                              onChanged: (updated) =>
                                  _updateActivity(context, updated),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
