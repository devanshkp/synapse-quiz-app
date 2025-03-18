import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application/widgets/auth/auth_widgets.dart';

class LabeledField extends StatelessWidget {
  final String label;
  final Widget field;

  const LabeledField({
    super.key,
    required this.label,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: field),
      ],
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isLoading = false;
  bool _isFormValid = false;
  bool _hasChanges = false;
  String? _avatarUrl;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String _originalFirstName = '';
  String _originalLastName = '';

  @override
  void initState() {
    super.initState();
    // Add listeners to update form validity when text changes
    _firstNameController.addListener(_onTextChanged);
    _lastNameController.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers
    _firstNameController.removeListener(_onTextChanged);
    _lastNameController.removeListener(_onTextChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // Called when text changes in any field
  void _onTextChanged() {
    _updateFormValidity();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userProfile = userProvider.userProfile;

    if (userProfile != null) {
      // Extract first and last name from fullName
      final nameParts = userProfile.fullName.split(' ');
      _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
      _lastNameController.text =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      _avatarUrl = userProfile.avatarUrl;

      // Store original values
      _originalFirstName = _firstNameController.text;
      _originalLastName = _lastNameController.text;

      // Explicitly set _hasChanges to false after loading data
      setState(() {
        _hasChanges = false;
      });

      // Validate the form and update button state
      Future.microtask(() {
        if (mounted) {
          _formKey.currentState?.validate();
          _updateFormValidity();
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _hasChanges = true;
          _updateFormValidity();
        });
      }
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
          context: context,
          message: 'Error picking image: $e',
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || !_hasChanges) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Upload image if a new one was selected
      String? newAvatarUrl = _avatarUrl;
      if (_imageFile != null) {
        newAvatarUrl = await userProvider.uploadProfileImage(_imageFile!);
        if (newAvatarUrl == null) {
          throw Exception('Failed to upload profile image');
        }
      }

      // Create the full name by combining first and last name
      final fullName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

      // Update the user profile in Firestore
      await userProvider.updateUserProfileInFirestore(
        fullName: fullName,
        avatarUrl: newAvatarUrl != _avatarUrl ? newAvatarUrl : null,
      );

      if (mounted) {
        floatingSnackBar(
          context: context,
          message: 'Profile updated successfully!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
          context: context,
          message: 'Error updating profile: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateFormValidity() {
    final isValid = _formKey.currentState?.validate() ?? false;
    final hasTextChanges = _firstNameController.text != _originalFirstName ||
        _lastNameController.text != _originalLastName;
    final hasImageChanges = _imageFile != null;
    final hasChanges = hasTextChanges || hasImageChanges;

    if (_isFormValid != isValid || _hasChanges != hasChanges) {
      setState(() {
        _isFormValid = isValid;
        _hasChanges = hasChanges;
      });
    }
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (value.trim().length > 15) {
      return 'First name must be less than 15 characters';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null) return null;
    if (value.trim().length > 15) {
      return 'Last name must be less than 15 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPageColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final userProfile = userProvider.userProfile;

          if (userProfile == null) {
            return const Center(child: CustomCircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              onChanged: _updateFormValidity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  // Profile Image with edit capability
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  width: 1.5,
                                  color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: _imageFile != null
                                  ? CircleAvatar(
                                      radius: 55,
                                      backgroundImage: FileImage(_imageFile!),
                                    )
                                  : UserAvatar(
                                      avatarUrl: userProfile.avatarUrl,
                                      avatarRadius: 55,
                                    ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_imageFile != null) {
                                // If an image is selected, clear it
                                setState(() {
                                  _imageFile = null;
                                  _updateFormValidity();
                                });
                              } else {
                                // If no image is selected, pick a new one
                                _pickImage();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    _imageFile != null ? Colors.red : appColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _imageFile != null
                                    ? Icons.close
                                    : Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Preview indicator text
                      if (_imageFile != null)
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Preview - Click Save to apply changes',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  LabeledField(
                    label: 'Username',
                    field: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            userProfile.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.lock_outline,
                            color: Colors.white30,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // First Name
                  LabeledField(
                    label: 'First Name',
                    field: CustomTextFormField(
                      controller: _firstNameController,
                      labelText: '',
                      validator: _validateFirstName,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Last Name
                  LabeledField(
                    label: 'Last Name',
                    field: CustomTextFormField(
                      controller: _lastNameController,
                      labelText: '',
                      validator: _validateLastName,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save Button
                  LoadingStateButton(
                    label: 'Save Changes',
                    onPressed: _saveProfile,
                    isEnabled: (_formKey.currentState?.validate() == true &&
                        _hasChanges == true &&
                        _isLoading == false),
                    backgroundColor: purpleAccent,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
