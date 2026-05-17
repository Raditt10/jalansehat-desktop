import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/models.dart';

/// State autentikasi
class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Provider autentikasi menggunakan Notifier (Riverpod v3)
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Cek status login saat startup
  Future<void> checkAuth() async {  
    state = state.copyWith(isLoading: true);
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc = await _firestore
            .collection(AppConstants.colUsers)
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final user = UserModel.fromFirestore(userDoc);
          state = AuthState(isLoggedIn: true, user: user);
          return;
        }
      }
      state = const AuthState(isLoggedIn: false);
    } catch (e) {
      state = AuthState(isLoggedIn: false, error: 'Gagal memeriksa status login: $e');
    }
  }

  /// Login dengan email dan password
  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = credential.user!.uid;

      final userDoc = await _firestore.collection(AppConstants.colUsers).doc(uid).get();

      if (!userDoc.exists) {
        // Otomatis buat document user di Firestore jika belum ada
        final newUser = UserModel(
          id: uid,
          name: credential.user!.email?.split('@').first ?? 'User',
          email: credential.user!.email ?? email,
          role: AppConstants.roleAdmin,
          createdAt: DateTime.now(),
        );
        await _firestore.collection(AppConstants.colUsers).doc(uid).set(newUser.toFirestore());

        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', email);
        }
        state = AuthState(isLoggedIn: true, user: newUser);
        return true;
      }

      final user = UserModel.fromFirestore(userDoc);

      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', email);
      }

      state = AuthState(isLoggedIn: true, user: user);
      return true;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found': message = 'Email tidak terdaftar.';
        case 'wrong-password': message = 'Password salah.';
        case 'invalid-credential': message = 'Email atau password salah.';
        case 'invalid-email': message = 'Format email tidak valid.';
        case 'user-disabled': message = 'Akun telah dinonaktifkan.';
        case 'too-many-requests': message = 'Terlalu banyak percobaan. Coba lagi nanti.';
        default: message = 'Login gagal: ${e.message}';
      }
      state = state.copyWith(isLoading: false, error: message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
      return false;
    }
  }

  /// Login dengan Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      final userDoc = await _firestore.collection(AppConstants.colUsers).doc(uid).get();

      if (!userDoc.exists) {
        final newUser = UserModel(
          id: uid,
          name: userCredential.user!.displayName ?? 'User',
          email: userCredential.user!.email ?? '',
          role: AppConstants.roleAdmin,
          createdAt: DateTime.now(),
        );
        await _firestore.collection(AppConstants.colUsers).doc(uid).set(newUser.toFirestore());
        state = AuthState(isLoggedIn: true, user: newUser);
      } else {
        final user = UserModel.fromFirestore(userDoc);
        state = AuthState(isLoggedIn: true, user: user);
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal login dengan Google: $e');
      return false;
    }
  }

  /// Register user baru
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = UserModel(id: credential.user!.uid, name: name, email: email, role: role, createdAt: DateTime.now());
      await _firestore.collection(AppConstants.colUsers).doc(user.id).set(user.toFirestore());
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: 'Registrasi gagal: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    state = const AuthState(isLoggedIn: false);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider global untuk auth
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
