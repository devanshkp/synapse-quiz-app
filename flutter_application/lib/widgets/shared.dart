import 'package:cached_network_image/cached_network_image.dart';
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
          color: const Color.fromARGB(255, 34, 34, 34),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
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
          : const AssetImage('assets/images/avatar.jpg'),
    );
  }
}

class UserAvatarImage extends StatelessWidget {
  final String? avatarUrl;
  final double avatarRadius;
  const UserAvatarImage(
      {super.key, required this.avatarUrl, required this.avatarRadius});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return CircleAvatar(
        radius: avatarRadius,
        backgroundImage: const AssetImage('assets/images/avatar.jpg'),
      );
    }

    return CachedNetworkImage(
      memCacheWidth: 250,
      memCacheHeight: 250,
      maxHeightDiskCache: 500,
      maxWidthDiskCache: 500,
      imageUrl: avatarUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: avatarRadius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => Container(
        width: avatarRadius * 2,
        height: avatarRadius * 2,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: avatarRadius,
        backgroundImage: const AssetImage('assets/images/avatar.jpg'),
      ),
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

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
        shape: CircleBorder(),
        color: Color(0xFF2C2C2C),
      ),
      padding: const EdgeInsets.all(5),
      child: const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  const CustomCard({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black45,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.085),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
