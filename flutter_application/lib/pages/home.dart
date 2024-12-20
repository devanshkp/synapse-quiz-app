import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utility/constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<List<Map<String, String>>> rows = [
      [
        {"title": "Daily Task", "icon": "assets/icons/task.svg"}
      ], // Row with 1 tile
      [
        {"title": "Choose Categories", "icon": "assets/icons/Edit.svg"},
        {"title": "Session History", "icon": "assets/icons/History.svg"},
      ], // Row with 2 tiles
      [
        {"title": "Quick Play", "icon": "assets/icons/Play.svg"}
      ],
    ];

    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(top: 45, left: 20, right: 20, bottom: 45),
        child: Column(
          children: [topPortion(), middlePortion()],
        ),
      ),
    );
  }

  Row topPortion() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          // Ensure the Column takes the available space
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Text
              Text(
                'Hi, Devansh',
                style: TextStyle(
                  color: Colors.white70, // Subdued color for greeting
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                'Let’s play!',
                style: TextStyle(
                  color: Colors.white, // Bright color for emphasis
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20), // Space between greeting and content
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: GestureDetector(
              onTap: () => (print("Notification button pressed")),
              child: SvgPicture.asset('assets/icons/home/Bolt.svg')),
        )
      ],
    );
  }

  Widget middlePortion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Ensures space between the text and icon
          children: [
            Expanded(
              flex: 3,
              child: categoriesButton(),
            ),
            const SizedBox(width: 10), // Space between the two columns
            Expanded(
              flex: 4,
              child: historyButton(),
            ),
          ],
        ),
      ],
    );
  }

  Container historyButton() {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 13, left: 13, right: 11, bottom: 5),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: buttonStrokeColor),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Space between text and icon
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text on the left
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Explore your most recent gameplay sessions.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Icon on the right
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: SvgPicture.asset('assets/icons/home/History.svg',
                color: Colors.white, width: 25, height: 25),
          ),
        ],
      ),
    );
  }

  Container categoriesButton() {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 13, left: 13, right: 11),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: buttonStrokeColor),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Space between text and icon
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text on the left
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'Select Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Icon on the right
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: SvgPicture.asset(
              'assets/icons/home/Edit.svg',
              height: 15,
              width: 15,
            ),
          ),
        ],
      ),
    );
  }
}
