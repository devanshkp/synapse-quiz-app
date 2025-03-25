import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/services/restart_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================== EMAIL (VERIFICATION/RESET) ==================

  // Check if the user's email is verified
  Future<bool> checkEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        final freshUser = _auth.currentUser;
        return freshUser?.emailVerified ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking email verification status: $e');
      return false;
    }
  }

  // Send a verification email
  Future<String?> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return null;
      }
      return 'User is already verified';
    } catch (e) {
      debugPrint('Error sending verification email: $e');
      return 'Error sending verification email: $e';
    }
  }

  // Send password reset email
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);

      return 'Password reset link sent!';
    } on FirebaseAuthException catch (e) {
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

      return errorMessage;
    } catch (e) {
      debugPrint('General exception in sendPasswordResetEmail: $e');

      return 'Error: ${e.toString()}';
    }
  }

  // ================== USERNAME ==================

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

      return true;
    }
  }

  // Set username for Third-Party Sign-In
  Future<String?> setUsername(String username) async {
    try {
      // Check if username is unique
      bool isUnique = await isUsernameUnique(username);
      if (!isUnique) {
        return 'Username is already taken. Please choose another.';
      }

      // Get current user
      final User? user = _auth.currentUser;
      if (user == null) {
        return 'No authenticated user found.';
      }

      // Use the stored full name if available, otherwise fall back to display name
      String fullName = user.displayName ?? 'User';

      // Create user profile in Firestore
      await _userService.createUserProfile(
        user: user,
        userName: username,
        fullName: fullName,
        avatarUrl: user.photoURL,
      );

      return null;
    } catch (e) {
      return 'Error setting username: ${e.toString()}';
    }
  }

  // ================== VALIDATION ==================

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

  // ================== LOGIN/REGISTRATION ==================

  Future<String?> register(
      {required String email,
      required String password,
      required String confirmPassword,
      required String fullName}) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Update the user's display name
        await user.updateDisplayName(fullName);

        // Send email verification
        await user.sendEmailVerification();

        return null;
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'Registration failed: ${e.message}';
      }
    } catch (e) {
      debugPrint('Error registering user: $e');
      return 'Error registering user: ${e.toString()}';
    }
    return null;
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await Future.delayed(const Duration(seconds: 1));

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'Incorrect email or password.';
      }
    } catch (e) {
      return 'Error signing in. Please try again.';
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      // Sign out first to force the account picker to show
      await _googleSignIn.signOut();

      // Set additional parameters to force account selection
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
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
      return null;
    } catch (e) {
      return 'Error signing in with Google: $e';
    }
  }

  Future<String?> signInWithGithub() async {
    try {
      final GithubAuthProvider githubAuth = GithubAuthProvider();

      githubAuth.addScope('read:user');
      githubAuth.addScope('user:email');

      // Sign in with GitHub
      final UserCredential userCredential =
          await _auth.signInWithProvider(githubAuth);
      final User? user = userCredential.user;

      if (user != null) {
        return null;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials.';
        case 'popup-closed-by-user':
          return 'Sign-in was cancelled by the user.';
        case 'popup-blocked':
          return 'The sign-in popup was blocked by the browser.';
        case 'web-storage-unsupported':
          return 'Web storage is not supported or is disabled.';
        default:
          return 'Error signing in with GitHub: ${e.message}';
      }
    } catch (e) {
      debugPrint('General Exception: $e');
      return 'Error signing in with GitHub: $e';
    }
    return null;
  }

  // ================== SIGN OUT/DELETE ==================

  Future<void> signOut(BuildContext context) async {
    try {
      RestartService.cleanUpProviders(context);

      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        RestartService.restartApp(context);
      }

      debugPrint("Signed out successfully");
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      RestartService.cleanUpProviders(context);

      await user.delete();

      if (context.mounted) {
        RestartService.restartApp(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (context.mounted) {
          floatingSnackBar(
              message:
                  'Re-authentication required. Please re-login and try deleting again.',
              context: context);
        }
      } else {
        debugPrint('Error deleting account: ${e.toString()}');
        if (context.mounted) {
          floatingSnackBar(
              message: 'Error deleting account, please try again later.',
              context: context);
        }
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }
}
