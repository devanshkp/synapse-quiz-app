import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';

class SessionHistoryPopup extends StatefulWidget {
  const SessionHistoryPopup({
    super.key,
  });

  @override
  SessionHistoryPopupState createState() => SessionHistoryPopupState();
}

class SessionHistoryPopupState extends State<SessionHistoryPopup> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Custom dark theme colors
    const surfaceColor = backgroundPageColor;
    const headerColor = Color.fromARGB(255, 28, 28, 28);
    const unselectedBorderColor = Color(0xFF3A3A3A);
    const textColor = Color(0xFFE0E0E0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    decoration: const BoxDecoration(
                      color: headerColor,
                      border: Border(
                        bottom: BorderSide(
                          color: unselectedBorderColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "To be added....",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
