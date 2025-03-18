import 'package:flutter/material.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:provider/provider.dart';

class RestartService extends StatefulWidget {
  final Widget child;

  const RestartService({super.key, required this.child});

  static void restartApp(BuildContext context) {
    final RestartServiceState? state =
        context.findAncestorStateOfType<RestartServiceState>();
    state?.restartApp();
  }

  static void cleanUpProviders(context) {
    Provider.of<UserProvider>(context, listen: false).disposeListeners();
    Provider.of<TriviaProvider>(context, listen: false).cancelFetchOperations();
  }

  @override
  RestartServiceState createState() => RestartServiceState();
}

class RestartServiceState extends State<RestartService> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
