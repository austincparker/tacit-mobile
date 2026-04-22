import 'package:flutter/material.dart';

mixin Navigation<T extends StatefulWidget> on State<T> {
  /// Pushes the given widget onto the navigation stack.
  ///
  /// {@macro flutter.widgets.navigator.pushNamed.returnValue}
  ///
  /// {@tool snippet}
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// void _openPage() {
  ///   pushScreen(const MyScreen());
  /// }
  /// ```
  /// {@end-tool}
  Future<E?> pushScreen<E extends Object?>(Widget screen) {
    return Navigator.of(context).push<E>(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Pushes the given widget onto the navigation stack and then removes all the previous widgets.
  ///
  /// {@macro flutter.widgets.navigator.pushNamed.returnValue}
  ///
  /// {@tool snippet}
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// void _resetAndOpenPage() {
  ///   popAllAndPush(const MyScreen());
  /// }
  /// ```
  /// {@end-tool}
  Future<E?> popAllAndPush<E extends Object?>(Widget screen) {
    return Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (_) => false,
    );
  }

  /// Pops the top-most route off the navigator.
  ///
  /// {@macro flutter.widgets.navigator.pop}
  ///
  /// {@tool snippet}
  ///
  /// Typical usage for closing a route is as follows:
  ///
  /// ```dart
  /// void _handleClose() {
  ///   popScreen();
  /// }
  /// ```
  /// {@end-tool}
  /// {@tool snippet}
  ///
  /// A dialog box might be closed with a result:
  ///
  /// ```dart
  /// void _handleAccept() {
  ///   popScreen(true); // dialog returns true
  /// }
  /// ```
  /// {@end-tool}
  void popScreen<E extends Object?>([E? result]) {
    return Navigator.of(context).pop<E>(result);
  }
}
