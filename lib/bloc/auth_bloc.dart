import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_app_base/api/direct_uploads_api.dart';
import 'package:flutter_app_base/api/passwords_api.dart';
import 'package:flutter_app_base/api/registrations_api.dart';
import 'package:flutter_app_base/api/sessions_api.dart';
import 'package:flutter_app_base/bloc/config_bloc.dart';
import 'package:flutter_app_base/bloc/notification_bloc.dart';
import 'package:flutter_app_base/firebase_options.dart';
import 'package:flutter_app_base/mixins/logger.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:flutter_app_base/model/user.dart';
import 'package:rxdart/rxdart.dart';

class AuthBloc with Logger {
  static AuthBloc? _instance;

  factory AuthBloc() {
    return _instance ??= AuthBloc._();
  }

  static Future<AuthBloc> reset({
    SessionsApi? sessionsApi,
    RegistrationsApi? registrationsApi,
    PasswordsApi? passwordsApi,
    DirectUploadsApi? directUploadsApi,
    FirebaseCrashlytics? firebaseCrashlytics,
    FirebaseAnalytics? firebaseAnalytics,
  }) async {
    await _instance?._dispose();
    return _instance = AuthBloc._(
      sessionsApi,
      registrationsApi,
      passwordsApi,
      directUploadsApi,
      firebaseCrashlytics,
      firebaseAnalytics,
    );
  }

  AuthBloc._([
    SessionsApi? sessionsApi,
    RegistrationsApi? registrationsApi,
    PasswordsApi? passwordsApi,
    DirectUploadsApi? directUploadsApi,
    FirebaseCrashlytics? firebaseCrashlytics,
    FirebaseAnalytics? firebaseAnalytics,
  ])  : _sessionsApi = sessionsApi ?? SessionsApi(),
        _registrationsApi = registrationsApi ?? RegistrationsApi(),
        _passwordsApi = passwordsApi ?? PasswordsApi(),
        _directUploadsApi = directUploadsApi ?? DirectUploadsApi(),
        _firebaseCrashlytics = firebaseCrashlytics ??
            (DefaultFirebaseOptions.isConfigured
                ? FirebaseCrashlytics.instance
                : null),
        _firebaseAnalytics = firebaseAnalytics ??
            (DefaultFirebaseOptions.isConfigured
                ? FirebaseAnalytics.instance
                : null) {
    _userSubscription = currentUserStream.listen((User? user) {
      if (DefaultFirebaseOptions.isConfigured) {
        _firebaseCrashlytics?.setUserIdentifier(user?.id ?? '');
        _firebaseAnalytics?.setUserId(id: user?.id ?? '');
      }
    });
  }

  final FirebaseCrashlytics? _firebaseCrashlytics;
  final FirebaseAnalytics? _firebaseAnalytics;

  final SessionsApi _sessionsApi;
  final RegistrationsApi _registrationsApi;
  final PasswordsApi _passwordsApi;
  final DirectUploadsApi _directUploadsApi;

  StreamSubscription<User?>? _userSubscription;

  final BehaviorSubject<User?> _userSubject =
      BehaviorSubject<User?>.seeded(null);
  Stream<User?> get currentUserStream => _userSubject.stream;
  User? get currentUser => _userSubject.value;

  Future<void> _dispose() async {
    _instance = null;
    // Cancel before closing: closing _userSubject would emit a done event
    // that could fire _userSubscription's callback before it is cancelled.
    await _userSubscription?.cancel();
    await _userSubject.close();
  }

  Future<User> login(String email, String password) {
    final trimmedEmail = email.trim();
    log.finest('login($trimmedEmail)');
    return _sessionsApi.login(trimmedEmail, password).then((response) async {
      final authResponse = response.data!;
      final user = authResponse.user;

      await ConfigBloc().setAuthCredentials(
        email: user.email,
        token: authResponse.authenticationToken,
        userId: user.id,
      );

      _userSubject.add(user);
      return user;
    }).catchError((err) {
      if (err is ApiResponse) {
        log.finest('ApiError: ${err.error?.message}');
      } else {
        log.finest('Unknown error: $err');
      }
      return Future<User>.error(err);
    });
  }

  Future<void> logout() async {
    log.finest('logout()');

    // Fire-and-forget: unregister device and sign out from backend
    // These should not block logout even if they fail
    if (DefaultFirebaseOptions.isConfigured) {
      NotificationBloc().unregisterDevice().catchError((e) {
        log.warning('Failed to unregister device: $e');
      });
    }

    _sessionsApi.logout().catchError((e) {
      log.warning('Failed to sign out from server: $e');
    });

    // Always clear local state
    await ConfigBloc().clearAuthCredentials();

    _userSubject.add(null);
  }

  Future<User> register({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    final trimmedEmail = email.trim();
    log.finest('register($trimmedEmail)');
    return _registrationsApi
        .register(
      email: trimmedEmail,
      password: password,
      passwordConfirmation: passwordConfirmation,
    )
        .then((response) async {
      final authResponse = response.data!;
      final user = authResponse.user;

      await ConfigBloc().setAuthCredentials(
        email: user.email,
        token: authResponse.authenticationToken,
        userId: user.id,
      );

      _userSubject.add(user);
      return user;
    }).catchError((err) {
      if (err is ApiResponse) {
        log.finest('ApiError: ${err.error?.message}');
      } else {
        log.finest('Unknown error: $err');
      }
      return Future<User>.error(err);
    });
  }

  Future<User> fetchCurrentUser() async {
    log.finest('fetchCurrentUser()');

    return _sessionsApi.fetchCurrentUser().then((response) {
      _userSubject.add(response.data!);
      return response.data!;
    }).catchError((err) {
      if (err is SocketException) {
        log.warning('SocketException: ${err.message}');
      } else if (err is ApiResponse) {
        log.finest('ApiError: ${err.error?.message}');
      } else {
        log.finest('Unknown error: $err');
      }
      return Future<User>.error(err);
    });
  }

  Future<void> requestPasswordReset(String email) async {
    final trimmedEmail = email.trim();
    log.finest('requestPasswordReset($trimmedEmail)');
    await _passwordsApi.requestReset(trimmedEmail);
  }

  Future<User> updateProfile({
    required String email,
    String? firstName,
    String? lastName,
    File? avatar,
  }) async {
    final trimmedEmail = email.trim();
    log.finest('updateProfile($trimmedEmail)');

    String? avatarSignedId;
    if (avatar != null) {
      avatarSignedId = await _directUploadsApi.uploadFile(
        file: avatar,
        contentType: 'image/${avatar.path.split('.').last}',
      );
    }

    final response = await _registrationsApi.updateProfile(
      email: trimmedEmail,
      firstName: firstName?.trim(),
      lastName: lastName?.trim(),
      avatarSignedId: avatarSignedId,
    );

    final user = response.data!;
    await ConfigBloc().addToStream(ConfigBloc.kAuthEmail, user.email);
    _userSubject.add(user);
    return user;
  }

  Future<User> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    log.finest('updatePassword()');

    final response = await _registrationsApi.updatePassword(
      currentPassword: currentPassword,
      password: newPassword,
      passwordConfirmation: confirmPassword,
    );

    final user = response.data!;
    _userSubject.add(user);
    return user;
  }

  Future<void> deleteAccount() async {
    log.finest('deleteAccount()');
    await _registrationsApi.deleteAccount();

    // Clear local state after successful deletion
    await ConfigBloc().clearAuthCredentials();

    _userSubject.add(null);
  }
}
