import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/services/restart_service.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/services/user_service.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if username is unique
  Future<bool> isUsernameUnique(String username) async {
    try {
      debugPrint('Checking if username "$username" is unique...');

      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('userName', isEqualTo: username)
          .limit(1)
          .get();

      bool isUnique = result.docs.isEmpty;
      debugPrint(
          'Username "$username" is ${isUnique ? "unique" : "already taken"}. Found ${result.docs.length} documents.');

      return isUnique;
    } catch (e) {
      debugPrint('Error checking username uniqueness: $e');
      // Return true on error to allow the user to proceed
      // The server-side validation will catch duplicates if they exist
      return true;
    }
  }

  // Validate password
  String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!hasDigits) {
      return 'Password must contain at least one number';
    }

    if (!hasSpecialCharacters) {
      return 'Password must contain at least one special character';
    }

    return null; // Password is valid
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(
      BuildContext context, String email) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CustomCircularProgressIndicator()),
      );

      // Validate email
      if (email.isEmpty) {
        if (context.mounted) {
          Navigator.pop(context); // Hide loading
          floatingSnackBar(
              message: 'Please enter your email address', context: context);
        }
        return;
      }

      if (!isValidEmail(email)) {
        if (context.mounted) {
          Navigator.pop(context); // Hide loading
          floatingSnackBar(
              message: 'Please enter a valid email address', context: context);
        }
        return;
      }

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);

      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        floatingSnackBar(
          message: 'Password reset email sent. Please check your inbox.',
          context: context,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        String errorMessage;

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email address.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'Error sending password reset email: ${e.message}';
        }

        floatingSnackBar(message: errorMessage, context: context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        floatingSnackBar(message: 'Error: ${e.toString()}', context: context);
      }
    }
  }

  Future<void> registerUser(
      {required BuildContext context,
      required String email,
      required String password,
      required String confirmPassword,
      required String userName,
      required String fullName}) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CustomCircularProgressIndicator()),
      );

      // Validate inputs
      if (email.isEmpty ||
          password.isEmpty ||
          userName.isEmpty ||
          fullName.isEmpty) {
        Navigator.pop(context); // Hide loading
        floatingSnackBar(
            message: 'Please fill in all fields.', context: context);
        return;
      }

      // Validate email format
      if (!isValidEmail(email)) {
        Navigator.pop(context); // Hide loading
        floatingSnackBar(
            message: 'Please enter a valid email address.', context: context);
        return;
      }

      // Check password strength
      String? passwordError = validatePassword(password);
      if (passwordError != null) {
        Navigator.pop(context); // Hide loading
        floatingSnackBar(message: passwordError, context: context);
        return;
      }

      if (password != confirmPassword) {
        Navigator.pop(context); // Hide loading
        floatingSnackBar(message: 'Passwords do not match.', context: context);
        return;
      }

      // Check if username is unique
      bool isUnique = await isUsernameUnique(userName);
      if (!isUnique) {
        Navigator.pop(context); // Hide loading
        floatingSnackBar(
            message: 'Username is already taken. Please choose another.',
            context: context);
        return;
      }

      // Create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        // Store user details in Firestore
        await _userService.createUserProfile(
            user: user, userName: userName, fullName: fullName);

        // Navigate to the email verification screen
        if (context.mounted) {
          Navigator.pop(context); // Hide loading
          Navigator.pushReplacementNamed(context, '/email-verification');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        String errorMessage;

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage =
                'This email is already registered. Please use another email or sign in.';
            break;
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'Registration failed: ${e.message}';
        }

        floatingSnackBar(message: errorMessage, context: context);
      }
    } catch (e) {
      debugPrint('Error registering user: $e');
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        floatingSnackBar(message: 'Error: ${e.toString()}', context: context);
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      showDialog(
        context: context,
        builder: (context) =>
            const Center(child: CustomCircularProgressIndicator()),
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (context.mounted) Navigator.pop(context); // Hide loading
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (context.mounted) {
          // First dismiss the loading dialog
          Navigator.pop(context); // Hide loading

          // Then handle navigation with microtask
          Future.microtask(() {
            if (context.mounted) {
              if (!userDoc.exists) {
                _showUsernameDialog(context, user);
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }
            }
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        floatingSnackBar(
            message: 'Error signing in with Google: $e', context: context);
      }
    }
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CustomCircularProgressIndicator()),
      );

      if (email.isEmpty || password.isEmpty) {
        if (context.mounted) {
          Navigator.pop(context); // Hide loading
          floatingSnackBar(
              message: 'Please fill in all fields', context: context);
        }
        return;
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (context.mounted) {
        // First dismiss the loading dialog
        Navigator.pop(context); // Hide loading

        // Then navigate using microtask to ensure dialog is fully dismissed
        Future.microtask(() {
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        String errorMessage;

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'Login failed: ${e.message}';
        }

        floatingSnackBar(message: errorMessage, context: context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        floatingSnackBar(message: 'Error signing in: $e', context: context);
      }
    }
  }

  void _showUsernameDialog(BuildContext context, User user) {
    if (!context.mounted) return;
    final TextEditingController usernameController = TextEditingController();
    bool isChecking = false;
    bool isUnique = true;
    String errorMessage = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Choose a Username'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your username',
                      errorText: !isUnique ? errorMessage : null,
                    ),
                    onChanged: (value) async {
                      if (value.length > 3) {
                        setState(() {
                          isChecking = true;
                          errorMessage = '';
                        });

                        try {
                          bool unique = await isUsernameUnique(value);

                          if (context.mounted) {
                            setState(() {
                              isUnique = unique;
                              isChecking = false;
                              errorMessage =
                                  unique ? '' : 'Username already taken';
                            });
                          }
                        } catch (e) {
                          debugPrint('Error checking username in dialog: $e');
                          if (context.mounted) {
                            setState(() {
                              isUnique = true; // Assume unique on error
                              isChecking = false;
                              errorMessage = '';
                            });
                          }
                        }
                      }
                    },
                  ),
                  if (isChecking)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('Checking username availability...'),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isChecking
                      ? null
                      : () async {
                          final userName = usernameController.text.trim();
                          if (userName.isEmpty) {
                            setState(() {
                              errorMessage = 'Username cannot be empty';
                              isUnique = false;
                            });
                            return;
                          }

                          if (userName.length < 4) {
                            setState(() {
                              errorMessage =
                                  'Username must be at least 4 characters';
                              isUnique = false;
                            });
                            return;
                          }

                          setState(() {
                            isChecking = true;
                          });

                          try {
                            bool unique = await isUsernameUnique(userName);

                            if (!unique) {
                              if (context.mounted) {
                                setState(() {
                                  isUnique = false;
                                  isChecking = false;
                                  errorMessage = 'Username already taken';
                                });
                              }
                              return;
                            }

                            // Show loading
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                    child: CustomCircularProgressIndicator()),
                              );
                            }

                            await _userService.createUserProfile(
                                user: user, userName: userName);

                            if (context.mounted) {
                              Navigator.pop(context); // Hide loading
                              Navigator.pop(
                                  dialogContext); // Close username dialog

                              // Use microtask for navigation
                              Future.microtask(() {
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/');
                                }
                              });
                            }
                          } catch (e) {
                            debugPrint('Error in username dialog submit: $e');
                            if (context.mounted) {
                              setState(() {
                                isChecking = false;
                                // Allow proceeding even on error
                                isUnique = true;
                              });

                              // Show loading
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                    child: CustomCircularProgressIndicator()),
                              );

                              try {
                                await _userService.createUserProfile(
                                    user: user, userName: userName);

                                if (context.mounted) {
                                  Navigator.pop(context); // Hide loading
                                  Navigator.pop(
                                      dialogContext); // Close username dialog

                                  // Use microtask for navigation
                                  Future.microtask(() {
                                    if (context.mounted) {
                                      Navigator.pushReplacementNamed(
                                          context, '/');
                                    }
                                  });
                                }
                              } catch (e2) {
                                if (context.mounted) {
                                  Navigator.pop(context); // Hide loading
                                  floatingSnackBar(
                                      message: 'Error creating profile: $e2',
                                      context: context);
                                }
                              }
                            }
                          }
                        },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> signOut(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CustomCircularProgressIndicator()),
      );

      Provider.of<UserProvider>(context, listen: false).disposeListeners();
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        RestartService.restartApp(context);
      }
      debugPrint("Signed out successfully");
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        floatingSnackBar(message: 'Error signing out: $e', context: context);
      }
      debugPrint("Error signing out: $e");
    }
  }
}
