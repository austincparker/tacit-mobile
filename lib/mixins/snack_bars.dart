import 'package:flutter/material.dart';

mixin SnackBars<T extends StatefulWidget> on State<T> {
  /// {@template twinsun.mixins.snackBars.showSnackBar}
  /// Shows a [SnackBar] across all registered [Scaffold]s. Scaffolds register
  /// to receive snack bars from their closest [ScaffoldMessenger] ancestor.
  /// If there are several registered scaffolds the snack bar is shown
  /// simultaneously on all of them.
  ///
  /// A scaffold can show at most one snack bar at a time. If this function is
  /// called while another snack bar is already visible, the given snack bar
  /// will be added to a queue and displayed after the earlier snack bars have
  /// closed.
  ///
  /// To control how long a [SnackBar] remains visible, use [SnackBar.duration].
  ///
  /// To remove the [SnackBar] with an exit animation, use [hideCurrentSnackBar]
  /// or call [ScaffoldFeatureController.close] on the returned
  /// [ScaffoldFeatureController]. To remove a [SnackBar] suddenly (without an
  /// animation), use [removeCurrentSnackBar].
  ///
  /// See [ScaffoldMessenger.of] for information about how to obtain the
  /// [ScaffoldMessengerState].
  ///
  /// {@tool dartpad}
  /// Here is an example of showing a [SnackBar] when the user presses a button.
  ///
  /// ** See code in examples/api/lib/material/scaffold/scaffold_messenger_state.show_snack_bar.0.dart **
  /// {@end-tool}
  ///
  /// ## Relative positioning of floating SnackBars
  ///
  /// A [SnackBar] with [SnackBar.behavior] set to [SnackBarBehavior.floating] is
  /// positioned above the widgets provided to [Scaffold.floatingActionButton],
  /// [Scaffold.persistentFooterButtons], and [Scaffold.bottomNavigationBar].
  /// If some or all of these widgets take up enough space such that the SnackBar
  /// would not be visible when positioned above them, an error will be thrown.
  /// In this case, consider constraining the size of these widgets to allow room for
  /// the SnackBar to be visible.
  ///
  /// {@tool dartpad}
  /// Here is an example showing that a floating [SnackBar] appears above [Scaffold.floatingActionButton].
  ///
  /// ** See code in examples/api/lib/material/scaffold/scaffold_messenger_state.show_snack_bar.1.dart **
  /// {@end-tool}
  /// {@endtemplate}
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(String message, [Color? backgroundColor]) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message),
      ),
    );
  }

  /// Displays a [SnackBar] with a red background.
  ///
  /// {@macro twinsun.mixins.snackBars.showSnackBar}
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(Object? error) {
    return showSnackBar(
      error?.toString() ?? 'An unknown error occurred. Please try again later.',
      Colors.red,
    );
  }
}
