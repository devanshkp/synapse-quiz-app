import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';

class TopicColorUtil {
  // Method to get the color based on the topic
  static Color getTopicColor(String topic) {
    switch (topic) {
      case 'machine_learning':
        return macLearningColor;
      case 'computer_network':
        return compNetworkColor;
      case 'data_science':
        return dataSciColor;
      case 'probability_&_statistics':
        return probStatColor;
      case 'data_structures':
        return dataStructColor;
      case 'cloud_computing':
        return cloudCompColor;
      case 'database':
        return databaseColor;
      case 'algorithms':
        return algorithmsColor;
      case 'SWE_fundamentals':
        return sweFundColor;
      case 'discrete_math':
        return discMathColor;
      case 'cyber_security':
        return const Color.fromARGB(255, 114, 126, 106);
      case 'artificial_intelligence':
        return artificialIntelColor;
      default:
        return Colors.grey;
    }
  }
}
