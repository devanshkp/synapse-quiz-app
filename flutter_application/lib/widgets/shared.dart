import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';

class CustomHorizontalDivider extends StatelessWidget {
  final double padding;
  final Color color;
  final double thickness;

  const CustomHorizontalDivider({
    super.key,
    required this.padding,
    this.color = Colors.white24,
    this.thickness = 1.25,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
      child: Divider(color: color, thickness: thickness),
    );
  }
}

class CustomVerticalDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double width;

  const CustomVerticalDivider({
    super.key,
    this.color = Colors.white30,
    this.height = double.infinity,
    this.width = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: color,
    );
  }
}

class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final double horizontalPadding;
  final EdgeInsets indicatorPadding;
  final double textSize;
  final double tabHeight;
  final TabController controller;
  final Color indicatorColor;
  final Color labelColor;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    this.horizontalPadding = 60.0,
    this.indicatorPadding = const EdgeInsets.all(3),
    this.textSize = 14.0,
    this.tabHeight = 45.0,
    this.indicatorColor = backgroundPageColor,
    this.labelColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 44, 44, 44),
        ),
        child: TabBar(
          controller: controller,
          tabs: tabs
              .map((tab) => Tab(
                    text: tab,
                    height: tabHeight,
                  ))
              .toList(),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontSize: textSize,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontFamily: 'Poppins',
            fontSize: textSize,
          ),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: indicatorPadding,
          labelColor: labelColor,
          unselectedLabelColor: Colors.white70,
          indicator: BoxDecoration(
            boxShadow: [buttonDropShadow],
            color: indicatorColor,
            borderRadius: const BorderRadius.all(Radius.circular(18)),
          ),
        ),
      ),
    );
  }
}

class AvatarImage extends StatelessWidget {
  final String? avatarUrl;
  final double avatarRadius;
  const AvatarImage(
      {super.key, required this.avatarUrl, required this.avatarRadius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: avatarRadius,
      backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
          ? NetworkImage(avatarUrl!)
          : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
    );
  }
}

class HorizontalDividerWithText extends StatelessWidget {
  final String text;
  final double dividerPadding;
  final Color dividerColor;
  final double dividerThickness;
  final TextStyle textStyle;

  const HorizontalDividerWithText({
    super.key,
    required this.text,
    this.dividerPadding = 5.0,
    this.dividerColor = Colors.white70,
    this.dividerThickness = 0.5,
    this.textStyle = const TextStyle(color: Colors.white70, fontSize: 13),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomHorizontalDivider(
            padding: dividerPadding,
            color: dividerColor,
            thickness: dividerThickness,
          ),
        ),
        Text(
          text,
          style: textStyle,
        ),
        Expanded(
          child: CustomHorizontalDivider(
            padding: dividerPadding,
            color: dividerColor,
            thickness: dividerThickness,
          ),
        ),
      ],
    );
  }
}
