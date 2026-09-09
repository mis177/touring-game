import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:touring_game/services/game/bloc/activity_details/activity_details_cubit.dart';
import 'package:touring_game/services/game/game_repository.dart';
import 'package:touring_game/services/navigation/external_url_repository.dart';
import 'package:touring_game/utilities/dialogs/error_snack_bar.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/routes.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ActivityDetailsProvider extends StatelessWidget {
  const ActivityDetailsProvider({super.key, required this.arguments});

  final ActivityDetailsArguments arguments;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivityDetailsCubit(
        context.read<ActivityProgressRepository>(),
        arguments.activity,
      ),
      child: ActivityDetailsView(arguments: arguments),
    );
  }
}

class ActivityDetailsView extends StatefulWidget {
  const ActivityDetailsView({super.key, required this.arguments});

  final ActivityDetailsArguments arguments;

  @override
  State<ActivityDetailsView> createState() => _ActivityDetailsViewState();
}

class _ActivityDetailsViewState extends State<ActivityDetailsView> {
  WebViewController? _webController;
  Uri? _pageUri;
  String? _pageError;
  var _isPageLoading = true;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.arguments.activity.webUrl);
    if (uri == null ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty) {
      _pageError = 'The activity page address is invalid.';
      _isPageLoading = false;
      return;
    }
    _pageUri = uri;
    _webController = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isPageLoading = true;
                _pageError = null;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isPageLoading = false);
            }
          },
          onWebResourceError: (error) {
            if (mounted && error.isForMainFrame == true) {
              setState(() {
                _isPageLoading = false;
                _pageError = 'Could not load the activity page.';
              });
            }
          },
        ),
      )
      ..loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityDetailsCubit, ActivityDetailsState>(
      listener: (context, state) {
        if (state.exception != null) {
          showErrorSnackBar(context, state.exception!);
        }
      },
      builder: (context, state) {
        final activity = state.activity;
        return PopScope(
          canPop: !state.isSaving,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              widget.arguments.onChanged(activity);
            }
          },
          child: LoadingOverlay(
            isLoading: state.isSaving,
            text: 'Updating activity',
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  activity.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(activity.name, overflow: TextOverflow.ellipsis),
                          Checkbox(
                            value: activity.isDone,
                            onChanged: state.isSaving
                                ? null
                                : (value) {
                                    if (value != null) {
                                      context
                                          .read<ActivityDetailsCubit>()
                                          .updateDone(value);
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(child: _buildWebContent()),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => context.push(
                  userNotesRoute,
                  extra: UserNotesArguments(activity: activity),
                ),
                child: const Icon(Icons.menu_book),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebContent() {
    final controller = _webController;
    final error = _pageError;
    if (controller == null || error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public_off, size: 56),
              const SizedBox(height: 12),
              Text(error ?? 'The activity page is unavailable.'),
              if (controller != null) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => controller.reload(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
              if (_pageUri case final uri?) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    try {
                      await context.read<ExternalUrlRepository>().open(uri);
                    } on Exception catch (error) {
                      if (mounted) {
                        showErrorSnackBar(context, error);
                      }
                    }
                  },
                  child: const Text('Open in browser'),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (_isPageLoading) const LinearProgressIndicator(),
      ],
    );
  }
}
