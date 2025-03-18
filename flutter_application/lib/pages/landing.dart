import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 24, 24, 24),
              Color.fromARGB(255, 16, 16, 16),
            ],
          ),
          image: DecorationImage(
            image: AssetImage('assets/images/shapes.png'),
            opacity: 0.15,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo and app name
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Enhanced logo with stylistic elements
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer decorative element - hexagon shape
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  width: 1.5,
                                ),
                              ),
                            ),

                            // Inner decorative element - rotated square for 3D effect
                            Transform.rotate(
                              angle: 0.2, // Slight rotation for 3D effect
                              child: Container(
                                height: 54,
                                width: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            // The actual logo
                            Image.asset(
                              'assets/images/logos/synapse_no_bg.png',
                              height: 30,
                              width: 30,
                            ),
                          ],
                        ),

                        const SizedBox(width: 15),

                        // App name with enhanced styling
                        Text(
                          "Synapse",
                          style: GoogleFonts.crimsonPro(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Expand your knowledge with interactive quizzes",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                // App features
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.topic_outlined,
                        title: "Multiple Topics",
                        description:
                            "Explore various subjects and expand your knowledge",
                      ),
                      const SizedBox(height: 15),
                      _buildFeatureItem(
                        icon: Icons.question_answer_outlined,
                        title: "Interactive Quizzes",
                        description:
                            "Test your understanding with engaging questions",
                      ),
                      const SizedBox(height: 15),
                      _buildFeatureItem(
                        icon: Icons.insights_outlined,
                        title: "Track Progress",
                        description:
                            "Monitor your learning journey and improvement",
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                // Action buttons
                Column(
                  children: [
                    GradientButton(
                      text: "Get Started",
                      gradient: const LinearGradient(
                        colors: [purpleAccent, darkPurpleAccent],
                      ),
                      textColor: Colors.white,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      width: double.infinity,
                      height: 50,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 15),
                    GradientButton(
                      text: "I Already Have an Account",
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.075),
                          Colors.white.withValues(alpha: 0.075),
                        ],
                      ),
                      textColor: Colors.white,
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      width: double.infinity,
                      height: 50,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      showBorder: true,
                      borderColor: Colors.white.withValues(alpha: 0.3),
                    ),
                  ],
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: purpleAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: purpleAccent,
            size: 22,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
