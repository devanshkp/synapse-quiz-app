import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';

class OfflinePage extends StatefulWidget {
  const OfflinePage({super.key});

  @override
  OfflinePageState createState() => OfflinePageState();
}

class OfflinePageState extends State<OfflinePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();

    // Setup animation for the floating cloud
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: backgroundPageColor,
          image: DecorationImage(
            image: AssetImage('assets/images/shapes.png'),
            opacity: 0.2,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: Stack(children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated cloud and signal icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _animation.value),
                                child: Icon(
                                  Icons.cloud,
                                  size: 200,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              );
                            }),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: lightPurpleAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wifi_off,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Main message
                    const Text(
                      "You're Offline",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Detailed message
                    const Text(
                      "It seems you've lost your internet connection. Please check your settings and try again.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: TextButton.icon(
                onPressed: () {
                  // Show offline usage tips
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: backgroundPageColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const OfflineTips(),
                  );
                },
                icon: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                ),
                label: const Text(
                  "Need help?",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class OfflineTips extends StatelessWidget {
  const OfflineTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Troubleshooting Tips",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 30),
          const TipItem(
            icon: Icons.network_wifi,
            title: "Check your Wi-Fi",
            description: "Make sure your Wi-Fi is turned on and connected",
          ),
          const TipItem(
            icon: Icons.signal_cellular_alt,
            title: "Check mobile data",
            description: "Ensure your mobile data is enabled",
          ),
          const TipItem(
            icon: Icons.airplanemode_active,
            title: "Airplane mode",
            description: "Check if airplane mode is turned off",
          ),
          const TipItem(
            icon: Icons.refresh,
            title: "Restart device",
            description: "Try restarting your device",
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: lightPurpleAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }
}

class TipItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const TipItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: lightPurpleAccent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
