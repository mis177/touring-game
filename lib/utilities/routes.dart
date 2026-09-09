import 'package:touring_game/models/activity.dart';

const homeRoute = '/';
const activitiesListRoute = '/activities';
const activityDetailsRoute = '/activity-details';
const userNotesRoute = '/user-notes';

class ActivitiesListArguments {
  const ActivitiesListArguments({
    required this.activities,
    required this.onChanged,
  });

  final List<DatabaseActivity> activities;
  final void Function() onChanged;
}

class ActivityDetailsArguments {
  const ActivityDetailsArguments({
    required this.activity,
    required this.onChanged,
  });

  final DatabaseActivity activity;
  final void Function(DatabaseActivity activity) onChanged;
}

class UserNotesArguments {
  const UserNotesArguments({required this.activity});

  final DatabaseActivity activity;
}
