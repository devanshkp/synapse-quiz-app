import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:provider/provider.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_application/widgets/auth/auth_widgets.dart';

// Reusable widget for labeled fields
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
  String? _avatarUrl;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
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

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _avatarUrl;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUserId;

      final fileName = path.basename(_imageFile!.path);
      final destination = 'profile_images/$userId/$fileName';

      final ref = FirebaseStorage.instance.ref().child(destination);
      final uploadTask = ref.putFile(_imageFile!);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
          context: context,
          message: 'Error uploading image: $e',
        );
      }
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userProfile = userProvider.userProfile;

      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      // Upload image if a new one was selected
      String? newAvatarUrl = _avatarUrl;
      if (_imageFile != null) {
        newAvatarUrl = await _uploadImage();
        if (newAvatarUrl == null) {
          throw Exception('Failed to upload profile image');
        }
      }

      // Update user profile in Firestore
      final Map<String, dynamic> updateData = {
        'fullName':
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      };

      // Only update avatarUrl if it changed
      if (newAvatarUrl != userProfile.avatarUrl) {
        updateData['avatarUrl'] = newAvatarUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userProvider.currentUserId)
          .update(updateData);

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  // Profile Image with edit capability
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                width: 1.5,
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: _imageFile != null
                                ? CircleAvatar(
                                    radius: 55,
                                    backgroundImage: FileImage(_imageFile!),
                                  )
                                : AvatarImage(
                                    avatarUrl: userProfile.avatarUrl,
                                    avatarRadius: 55,
                                  ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: appColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Username (non-editable)
                  LabeledField(
                    label: 'Username',
                    field: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
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
                    field: CustomTextField(
                      controller: _firstNameController,
                      labelText: '',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Last Name
                  LabeledField(
                    label: 'Last Name',
                    field: CustomTextField(
                      controller: _lastNameController,
                      labelText: '',
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CustomCircularProgressIndicator(),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
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
