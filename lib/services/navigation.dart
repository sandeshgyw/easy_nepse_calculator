import 'dart:ui';

import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Future<dynamic> navigateTo(Widget pageNmae) {
    return navigatorKey.currentState!.push(getPageRoute(pageNmae));
  }
}

Future navigateToPage<T>({
  required BuildContext context,
  required Widget pageName,
}) {
  return Navigator.push(context, getPageRoute(pageName));
}

void navigateWithReplacement({
  required BuildContext context,
  required Widget pageName,
}) {
  Navigator.pushReplacement(context, getPageRoute(pageName));
}

void navigateWithReplacementNamed({
  required BuildContext context,
  required String pageName,
}) {
  Navigator.pushReplacementNamed(context, pageName);
}

void navigateWithName({
  required BuildContext context,
  required Widget pageName,
}) {
  Navigator.pushReplacement(context, getPageRoute(pageName));
}

Future<void> navigateWithAllReplaced(
    {required BuildContext context, required Widget pageName}) async {
  await Navigator.pushAndRemoveUntil(
    context,
    getPageRoute(pageName),
    (route) => false,
  );
}

void pushUntil({required BuildContext context, required Widget pageName}) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (BuildContext context) => pageName),
    ModalRoute.withName('/home'),
  );
}

void navigateNamedWithAllReplaced(
    {required BuildContext context, required String pageName}) {
  Navigator.of(context).popUntil(ModalRoute.withName("/home"));
}

Route<T> getPageRoute<T>(Widget destination) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) => destination,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var tween = Tween(
        begin: 0.0,
        end: 1.0,
      );
      var curvedAnimation = CurvedAnimation(
        curve: Curves.easeIn,
        parent: animation,
      );
      double value = tween.animate(curvedAnimation).value;
      return Opacity(
        opacity: value,
        child: Transform.scale(
          scale: lerpDouble(.9, 1, value)!,
          child: child,
        ),
      );
    },
  );
}
