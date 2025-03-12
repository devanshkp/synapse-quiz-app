import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/services/restart_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/services/user_service.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    forceCodeForRefreshToken: true,
  );
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

  String? validateUsername(String username) {
    if (username.length < 4) {
      return 'Username must be at least 4 characters';
    }
    if (username.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Username cannot contain special characters';
    }
    return null;
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
      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);

      if (context.mounted) {
        floatingSnackBar(
          message:
              'If this email is registered, a password reset link will be sent to your inbox.',
          context: context,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
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
      debugPrint('General exception in sendPasswordResetEmail: $e');

      if (context.mounted) {
        floatingSnackBar(message: 'Error: ${e.toString()}', context: context);
      }
    }
  }

  Future<void> register(
      {required BuildContext context,
      required String email,
      required String password,
      required String confirmPassword,
      required String userName,
      required String fullName}) async {
    try {
      // Check if username is unique
      bool isUnique = await isUsernameUnique(userName);
      if (!isUnique) {
        if (context.mounted) {
          floatingSnackBar(
              message: 'Username is already taken. Please choose another.',
              context: context);
        }
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

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/email-verification');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        String errorMessage;

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'An account with this email already exists.';
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
        floatingSnackBar(message: 'Error: ${e.toString()}', context: context);
      }
    }
  }

  Future<void> signIn(
      BuildContext context, String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await Future.delayed(const Duration(seconds: 1));
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
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
            errorMessage = 'Error signing in. Please try again.';
        }
        floatingSnackBar(message: errorMessage, context: context);
      }
    } catch (e) {
      if (context.mounted) {
        floatingSnackBar(
            message: 'Error signing in. Please try again.', context: context);
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Sign out first to force the account picker to show
      await _googleSignIn.signOut();

      // Set additional parameters to force account selection
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        await Future.delayed(const Duration(seconds: 1));
        return;
      }

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await _auth.signInWithCredential(credential);
    } catch (e) {
      if (context.mounted) {
        floatingSnackBar(
            message: 'Error signing in with Google: $e', context: context);
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      Provider.of<UserProvider>(context, listen: false).disposeListeners();
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        RestartService.restartApp(context);
      }
      debugPrint("Signed out successfully");
    } catch (e) {
      if (context.mounted) {
        floatingSnackBar(message: 'Error signing out: $e', context: context);
      }
      debugPrint("Error signing out: $e");
    }
  }

  // Set username for Third-Party Sign-In
  Future<void> setUsername(BuildContext context, String username) async {
    try {
      // Check if username is unique
      bool isUnique = await isUsernameUnique(username);
      if (!isUnique) {
        if (context.mounted) {
          floatingSnackBar(
              message: 'Username is already taken. Please choose another.',
              context: context);
        }
        return;
      }

      // Get current user
      final User? user = _auth.currentUser;
      if (user == null) {
        if (context.mounted) {
          floatingSnackBar(
              message: 'No authenticated user found.', context: context);
        }
        return;
      }

      // Create user profile in Firestore
      await _userService.createUserProfile(
        user: user,
        userName: username,
        fullName: user.displayName,
        avatarUrl: user.photoURL,
      );

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      debugPrint('Error setting username: $e');
      if (context.mounted) {
        floatingSnackBar(message: 'Error: ${e.toString()}', context: context);
      }
    }
  }
}
