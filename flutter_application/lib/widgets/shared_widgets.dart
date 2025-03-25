import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/pages/secondary/topic.dart';
import 'package:flutter_application/utils/text_formatter.dart';
import 'package:flutter_application/widgets/home/home_widgets.dart';

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
          color: const Color.fromARGB(255, 32, 32, 32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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

class TopicButton extends StatelessWidget {
  final String title;
  final String iconName;
  final double iconSize;
  final Color color;
  final double titleFontSize;
  final String buttonType;
  final double? borderRadius;
  final double? buttonWidth;
  final double? buttonHeight;
  final double? bottomOffset;
  final double? rightOffset;
  final String? section;

  const TopicButton({
    super.key,
    required this.title,
    required this.iconName,
    required this.iconSize,
    required this.color,
    required this.titleFontSize,
    required this.buttonType,
    this.borderRadius = 10.0,
    this.buttonWidth,
    this.buttonHeight,
    this.bottomOffset,
    this.rightOffset,
    this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius!),
      elevation: 4, // This gives you the shadow effect
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius!),
            gradient: createGradientFromColor(color),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius!),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      TopicDetailsPage(
                    topicName: title,
                    iconName: iconName,
                    topicColor: color,
                    buttonType: buttonType,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            child: SizedBox(
              width: buttonWidth ?? double.infinity,
              height: buttonHeight ?? double.infinity,
              child: Stack(
                children: [
                  // Positioned image for bottom-right corner
                  Positioned(
                    bottom: bottomOffset ?? -10,
                    right: rightOffset ?? -10,
                    child: Transform.rotate(
                      angle: 0.3,
                      child: Image.asset(
                        'assets/images/topics/$iconName',
                        width: iconSize,
                        height: iconSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Positioned text for top-left corner
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: Colors.transparent,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: (buttonType == 'search')
                                    ? constraints.maxWidth * 0.7
                                    : constraints.maxWidth,
                              ),
                              child: Text(
                                TextFormatter.formatTitlePreservingCase(title),
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double avatarRadius;
  const UserAvatar(
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
          color: Colors.white.withValues(alpha: 0.1),
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

class DeveloperAvatar extends StatefulWidget {
  final String imageUrl;
  final double size;
  final VoidCallback? onTap;

  const DeveloperAvatar({
    super.key,
    required this.imageUrl,
    this.size = 80.0,
    this.onTap,
  });

  @override
  State<DeveloperAvatar> createState() => _DeveloperAvatarState();
}

class _DeveloperAvatarState extends State<DeveloperAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Define rainbow colors
  final List<Color> rainbowColors = const [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Get current color based on animation value
  Color getCurrentGlowColor(double animValue) {
    // Calculate which segment of the rainbow we're in
    final int colorIndex = (animValue * (rainbowColors.length - 1)).floor();
    final double colorPosition =
        (animValue * (rainbowColors.length - 1)) - colorIndex;

    // Interpolate between current and next color
    if (colorIndex < rainbowColors.length - 1) {
      return Color.lerp(
        rainbowColors[colorIndex],
        rainbowColors[colorIndex + 1],
        colorPosition,
      )!;
    } else {
      return rainbowColors.last;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Get current glow color based on animation
          final glowColor = getCurrentGlowColor(_controller.value);

          return Container(
            width: widget.size * 2 + 12,
            height: widget.size * 2 + 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: glowColor,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.7),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.3),
                  blurRadius: 18,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: ClipOval(
                child: Container(
                  width: widget.size * 2,
                  height: widget.size * 2,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: widget.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          },
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HorizontalDividerWithText extends StatelessWidget {
  final String text;
  final double textPadding;
  final double dividerPadding;
  final Color dividerColor;
  final double dividerThickness;
  final TextStyle textStyle;

  const HorizontalDividerWithText({
    super.key,
    required this.text,
    this.dividerPadding = 5.0,
    this.textPadding = 16.0,
    this.dividerColor = Colors.white70,
    this.dividerThickness = 0.5,
    this.textStyle = const TextStyle(
      color: Colors.white70,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: textPadding),
          child: Text(
            text,
            style: textStyle,
          ),
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
        color: Color.fromARGB(255, 58, 58, 58),
      ),
      padding: const EdgeInsets.all(6),
      child: const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Colors.white,
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final IconData? trailingIcon;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const CustomCard({
    super.key,
    required this.icon,
    required this.text,
    this.subtitle,
    required this.color,
    required this.onTap,
    this.trailingIcon,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  trailingIcon,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmationButtonText;
  final String cancelButtonText;
  final bool isConfirmationButtonEnabled;
  final VoidCallback onPressed;
  const CustomAlertDialog(
      {super.key,
      required this.title,
      required this.content,
      required this.confirmationButtonText,
      required this.cancelButtonText,
      required this.onPressed,
      this.isConfirmationButtonEnabled = true});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      content: Text(
        content,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelButtonText,
            style: TextStyle(color: Colors.blue[200]),
          ),
        ),
        if (isConfirmationButtonEnabled) ...[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onPressed();
            },
            child: Text(
              confirmationButtonText,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ],
    );
  }
}

class GradientButton extends StatelessWidget {
  final IconData? icon;
  final String text;
  final LinearGradient gradient;
  final Color textColor;
  final VoidCallback onPressed;

  // Core styling
  final double? width;
  final double? height;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry padding;

  // Typography
  final double fontSize;
  final FontWeight fontWeight;

  // Layout options
  final bool fullWidth;
  final bool showBorder;
  final Color? borderColor;
  final Size minimumSize;

  // Animation
  final bool enableScale;
  final Duration animationDuration;

  const GradientButton({
    super.key,
    this.icon,
    required this.text,
    required this.gradient,
    required this.textColor,
    required this.onPressed,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.elevation = 3.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w600,
    this.fullWidth = false,
    this.showBorder = false,
    this.borderColor,
    this.enableScale = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.minimumSize = const Size(0, 0),
  });

  @override
  Widget build(BuildContext context) {
    return _ButtonScaleWrapper(
      duration: animationDuration,
      onPressed: onPressed,
      enabled: enableScale,
      child: PhysicalModel(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: elevation,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(borderRadius),
                border: showBorder
                    ? Border.all(
                        color: borderColor ?? textColor.withValues(alpha: 0.5),
                        width: 1)
                    : null,
              ),
              child: Container(
                width: fullWidth ? double.infinity : width,
                height: height,
                padding: padding,
                constraints: BoxConstraints(
                  minWidth: minimumSize.width,
                  minHeight: minimumSize.height,
                ),
                child: Row(
                  mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: fontSize * 1.5, color: textColor),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;
  final bool enabled;

  const _ButtonScaleWrapper({
    required this.child,
    required this.onPressed,
    required this.duration,
    required this.enabled,
  });

  @override
  _ButtonScaleWrapperState createState() => _ButtonScaleWrapperState();
}

class _ButtonScaleWrapperState extends State<_ButtonScaleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class DeleteAccountDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const DeleteAccountDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isConfirmEnabled = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  void _validateInput() {
    if (mounted) {
      setState(() {
        _isConfirmEnabled = _confirmController.text == 'Delete Account';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      title: const Text(
        'Delete Account',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action cannot be undone. All your data will be permanently deleted.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          const Text(
            'Type "Delete Account" to confirm:',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _confirmController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Delete Account',
              hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.blue[200]),
          ),
        ),
        TextButton(
          onPressed: _isConfirmEnabled
              ? () {
                  widget.onConfirm();
                }
              : null,
          child: Text(
            'Delete Account',
            style: TextStyle(
              color: _isConfirmEnabled
                  ? Colors.red
                  : Colors.red.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingStateButton extends StatefulWidget {
  final String label;
  final Future<void> Function() onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isEnabled;
  final bool showBorder;
  final Color borderColor;
  final double width;

  const LoadingStateButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.isEnabled = true,
    this.showBorder = false,
    this.borderColor = Colors.transparent,
    this.width = double.infinity,
  });

  @override
  State<LoadingStateButton> createState() => _LoadingStateButtonState();
}

class _LoadingStateButtonState extends State<LoadingStateButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = widget.isEnabled && !_isLoading;

    return ElevatedButton(
      onPressed: isButtonEnabled
          ? () async {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }

              try {
                await widget.onPressed();
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(widget.width, 50),
        backgroundColor: isButtonEnabled
            ? widget.backgroundColor
            : widget.backgroundColor.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: widget.showBorder
              ? BorderSide(color: widget.borderColor, width: 1)
              : BorderSide.none,
        ),
        disabledBackgroundColor: widget.backgroundColor.withValues(alpha: 0.5),
        disabledForegroundColor: widget.textColor.withValues(alpha: 0.5),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(widget.textColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.textColor,
                      ),
                    ),
                  ],
                )
              : Text(
                  widget.label,
                  style: TextStyle(
                    color: isButtonEnabled
                        ? widget.textColor
                        : widget.textColor.withValues(alpha: 0.5),
                  ),
                ),
        ),
      ),
    );
  }
}

class AlertBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Duration duration;
  final bool isError;

  const AlertBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.duration = const Duration(seconds: 3),
    this.isError = true,
  });

  @override
  Widget build(BuildContext context) {
    Future.delayed(duration, () {
      if (context.mounted) {
        onDismiss?.call();
      }
    });
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.green.shade800.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isError ? Colors.red.shade800 : Colors.green.shade800),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(
                Icons.close,
                color: Colors.white70,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
