import 'package:flutter/material.dart';
import 'package:flutter_application/utils/text_formatter.dart';

class OptionButton extends StatefulWidget {
  final String option;
  final bool isCorrectOption;
  final bool isSelected;
  final Color? buttonColor;
  final VoidCallback? onPressed;

  const OptionButton({
    super.key,
    required this.option,
    required this.isCorrectOption,
    required this.isSelected,
    required this.buttonColor,
    this.onPressed,
  });

  @override
  State<OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // Start glow animation if this is a selected answer
    if (widget.isSelected ||
        (widget.isCorrectOption && widget.onPressed == null)) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(OptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle animation state changes when props update
    if ((widget.isSelected ||
            (widget.isCorrectOption && widget.onPressed == null)) &&
        !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!(widget.isSelected ||
            (widget.isCorrectOption && widget.onPressed == null)) &&
        _glowController.isAnimating) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnswered = widget.onPressed == null;
    final bool showGlow =
        widget.isSelected || (widget.isCorrectOption && isAnswered);
    final Color glowColor =
        widget.isCorrectOption ? Colors.green.shade400 : Colors.red.shade400;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Stack(
          children: [
            // Glow effect
            if (showGlow)
              Positioned.fill(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor
                              .withOpacity(0.5 * _glowAnimation.value / 1.8),
                          blurRadius: 16 * _glowAnimation.value,
                          spreadRadius: 2 * _glowAnimation.value,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Button
            MouseRegion(
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                transform: Matrix4.identity()
                  ..scale(_isHovering && !isAnswered ? 1.02 : 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: widget.onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.buttonColor,
                      disabledBackgroundColor: widget.buttonColor,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: showGlow
                              ? glowColor.withOpacity(0.8)
                              : const Color(0xff444444),
                          width: showGlow ? 2 : 1,
                        ),
                      ),
                      elevation: _isHovering && !isAnswered ? 6 : 4,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: TextFormatter.formatText(
                              widget.option,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 0.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (isAnswered &&
                            (widget.isCorrectOption || widget.isSelected))
                          Positioned(
                            right: 8,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: 1.0,
                                child: widget.isCorrectOption
                                    ? Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.white.withOpacity(0.4),
                                        size: 20,
                                      )
                                    : widget.isSelected
                                        ? Icon(
                                            Icons.cancel_outlined,
                                            color:
                                                Colors.white.withOpacity(0.4),
                                            size: 20,
                                          )
                                        : const SizedBox(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
