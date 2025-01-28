import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionForm extends StatefulWidget {
  final Function() onQuestionAdded;

  const AddQuestionForm({super.key, required this.onQuestionAdded});

  @override
  State<AddQuestionForm> createState() => _AddQuestionFormState();
}

class _AddQuestionFormState extends State<AddQuestionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _optionsController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    "neural_networks",
    "foundational_math",
    "sorting_algorithms",
    "machine_learning",
    "data_structures",
    "programming_basics",
    "popular_algorithms",
    "database_systems",
    "swe_fundamentals"
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _hintController.dispose();
    _answerController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  Future<void> _addQuestionToFirestore() async {
    if (_formKey.currentState?.validate() ?? false) {
      final question = {
        'title': _titleController.text,
        'category': _selectedCategory,
        'hint': _hintController.text,
        'answer': _answerController.text,
        'options':
            _optionsController.text.split(',').map((e) => e.trim()).toList(),
      };

      try {
        await FirebaseFirestore.instance.collection('questions').add(question);

        // Check if the widget is still mounted
        if (mounted) {
          // Notify the parent widget that the question was added
          widget.onQuestionAdded();

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Question added successfully!')),
          );

          // Close the dialog
          Navigator.pop(context);
        }
      } catch (e) {
        // Check if the widget is still mounted before showing the error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding question: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: const Text(
        'Add New Question',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter the question title',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Category',
                items: _categories,
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) =>
                    value == null ? 'Category is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _hintController,
                label: 'Hint',
                hint: 'Provide a hint for the question',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Hint is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _answerController,
                label: 'Answer',
                hint: 'Enter the correct answer',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Answer is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _optionsController,
                label: 'Options',
                hint: 'Enter comma-separated options',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Options are required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: _addQuestionToFirestore,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: const Text(
            'Add',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(
            category,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      dropdownColor: Colors.grey[900],
      style: const TextStyle(color: Colors.white),
    );
  }
}
