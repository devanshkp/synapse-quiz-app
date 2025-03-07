import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';

class SessionHistoryPage extends StatefulWidget {
  const SessionHistoryPage({
    super.key,
  });

  @override
  SessionHistoryPageState createState() => SessionHistoryPageState();
}

class SessionHistoryPageState extends State<SessionHistoryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: backgroundPageColor,
      body: Container(
        decoration: const BoxDecoration(
          color: backgroundPageColor,
          image: DecorationImage(
            image: AssetImage('assets/images/shapes.png'),
            opacity: 0.2,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: const Center(
            child: Text(
          "Coming soon!",
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 24, color: Colors.white),
        )),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        "Topic Selection",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Divider(
          color: Colors.white12,
          height: 1,
        ),
      ),
    );
  }
}
