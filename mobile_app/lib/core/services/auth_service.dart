import 'dart:developer';
// import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // final _auth = FirebaseAuth.instance;
  final supabase = Supabase.instance.client;
  // final GoogleSignIn googleSignIn = GoogleSignIn();

  // Sign in with Google
  // Future<User?> signInWithGoogle() async {
  //   try {
  //     // Trigger the authentication flow
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //     if (googleUser == null) {
  //       // User canceled the sign-in flow
  //       return null;
  //     }
  //     // Obtain the auth details from the request
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     // Create a new credential
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     // Sign in to Firebase with the credential
  //     final UserCredential userCredential = await _auth.signInWithCredential(credential);
  //     final User? user = userCredential.user;
  //       // Store the credentials
  //       if (googleAuth.accessToken != null) {
  //         final prefs = await SharedPreferences.getInstance();
  //         await prefs.setString('google_access_token', googleAuth.accessToken!);
  //         if (googleAuth.idToken != null) {
  //           await prefs.setString('google_id_token', googleAuth.idToken!);
  //         }
  //       }
  //     if (user != null) {
  //       // Save username to SharedPreferences if needed
  //       if (user.displayName != null) {
  //         await _saveUsername(user.displayName!);
  //       }
  //       log('Google Sign in successful: ${user.email}');
  //       return user;
  //     }
  //     return null;
  //   } on FirebaseAuthException catch (e) {
  //     switch (e.code) {
  //       case 'account-exists-with-different-credential':
  //         throw Exception('You already have an account with this email. Use other login method.');
  //       case 'invalid-credential':
  //         throw Exception('Invalid credentials provided.');
  //       case 'user-disabled':
  //         throw Exception('This account has been disabled.');
  //       case 'user-not-found':
  //         throw Exception('No user found for this email.');
  //       default:
  //         throw Exception(e.message ?? 'Google sign in failed');
  //     }
  //   } catch (e) {
  //     throw Exception('Google sign in failed: $e');
  //   }
  // }

 Future<Object?> signInWithGoogle() async {
   try {
     if (kIsWeb) {
       return await supabase.auth.signInWithOAuth(
         OAuthProvider.google,
         redirectTo: null,
         authScreenLaunchMode: LaunchMode.platformDefault,
       );
     } else {
       const webClientId = '115772554125-fipp548as487m2od95bsjbfmphhv6tnr.apps.googleusercontent.com';
       const iosClientId = '115772554125-4esanb0d5h63uuodkd07vrj7vk9q1934.apps.googleusercontent.com'; 
       const androidClientId = '115772554125-aekcl8upfv0fdfm33mh7p3rnm03imtjb.apps.googleusercontent.com';
       
       final GoogleSignIn googleSignIn = GoogleSignIn(
         clientId: Platform.isIOS ? iosClientId : androidClientId,
         serverClientId: webClientId,
       );
       
       final googleUser = await googleSignIn.signIn();
       if (googleUser == null) return null;
       
       final googleAuth = await googleUser.authentication;
       final accessToken = googleAuth.accessToken;
       final idToken = googleAuth.idToken;
       
       if (accessToken == null) throw 'No Access Token found.';
       if (idToken == null) throw 'No ID Token found.';
       
       return await supabase.auth.signInWithIdToken(
         provider: OAuthProvider.google,
         idToken: idToken,
         accessToken: accessToken,
       );
     }
   } catch (e) {
     throw Exception('Google sign in failed: $e');
   }
 }

  // Your existing email/password sign in method
  // Future<User?> signInWithEmailAndPassword(
  //     {required String email, required String password, required String username}) async {
  //   try {
  //     final credentials = await _auth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //     if (credentials.user != null) {
  //       await credentials.user?.updateDisplayName(username);
  //       await _saveUsername(username);
  //       log('User created: ${credentials.user}');
  //       return credentials.user;
  //     } else {
  //       log('User creation failed');
  //       return null;
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     switch (e.code) {
  //       case 'weak-password':
  //         throw Exception('The password provided is too weak.');
  //       case 'email-already-in-use':
  //         throw Exception('An account already exists for that email.');
  //       case 'invalid-email':
  //         throw Exception('The email address is not valid.');
  //       default:
  //         throw Exception(e.message ?? 'Sign up failed');
  //     }
  //   } catch (e) {
  //     throw Exception('Sign up failed: $e');
  //   }
  // }

  Future<AuthResponse?> signInWithEmailAndPassword(
      {required String email,
      required String password,
      required String username}) async {
    try {
      final AuthResponse res = await supabase.auth.signUp(
          email: email, password: password, data: {'full_name': username});

      if (res.user != null) {
        await _saveUsername(username);
        log('User created: ${res.user}');
        return res;
      }
      return null;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Your existing login method
  // Future<User?> loginWithEmailAndPassword(
  //     {required String email, required String password}) async {
  //   try {
  //     final credentials = await _auth.signInWithEmailAndPassword(
  //         email: email, password: password);
  //     log('User credentials: ${credentials.user}');
  //     log('User email: ${credentials.user?.email}');
  //     log('User display name: ${credentials.user?.displayName}');
  //     if (credentials.user?.displayName != null) {
  //       await _saveUsername(credentials.user!.displayName!);
  //     }
  //     return credentials.user;
  //   } on FirebaseAuthException catch (e) {
  //     switch (e.code) {
  //       case 'user-not-found':
  //         throw Exception('No user found for that email.');
  //       case 'wrong-password':
  //         throw Exception('Wrong password provided.');
  //       case 'user-disabled':
  //         throw Exception('This account has been disabled.');
  //       default:
  //         throw Exception(e.message ?? 'Login failed');
  //     }
  //   } catch (e) {
  //     throw Exception('Login failed: $e');
  //   }
  // }

  Future<AuthResponse?> loginWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user?.userMetadata?['full_name'] != null) {
        await _saveUsername(res.user!.userMetadata!['full_name']);
      }
      return res;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  // Your existing helper methods
  // Future<void> logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('auth_token');
  //   try {
  //     await googleSignIn.signOut(); // Sign out from Google
  //     await _auth.signOut(); // Sign out from Firebase
  //   } catch (e) {
  //     throw Exception('Logout failed: $e');
  //   }
  // }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  // Future<String?> getUsername() async {
  //   String? username = _auth.currentUser?.displayName;
  //   if (username == null) {
  //     final prefs = await SharedPreferences.getInstance();
  //     username = prefs.getString('username');
  //   }
  //   return username;
  // }

  Future<String?> getUsername() async {
    final user = supabase.auth.currentUser;
    String? username = user?.userMetadata?['full_name'];

    if (username == null) {
      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString('username');
    }

    return username;
  }

  Future<Map<String, String?>> getGoogleCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'accessToken': prefs.getString('google_access_token'),
      'idToken': prefs.getString('google_id_token'),
    };
  }

  // bool isLoggedIn() {
  //   return _auth.currentUser != null;
  // }

  bool isLoggedIn() { 
    return supabase.auth.currentUser != null;
  }

  Session? getCurrentSession() {
    return supabase.auth.currentSession;
  }
  // User? getCurrentUser() {
  //   return _auth.currentUser;
  // }
}
