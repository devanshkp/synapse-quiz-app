import 'package:flutter/material.dart';

class RestartService extends StatefulWidget {
  final Widget child;

  const RestartService({super.key, required this.child});

  static void restartApp(BuildContext context) {
    final RestartServiceState? state =
        context.findAncestorStateOfType<RestartServiceState>();
    state?.restartApp();
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
