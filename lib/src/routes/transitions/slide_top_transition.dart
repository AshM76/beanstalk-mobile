import 'package:flutter/material.dart';

class SlideTopTransition extends PageRouteBuilder {
  Widget? transitionTo;
  SlideTopTransition({this.transitionTo})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => transitionTo!,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // animation = CurvedAnimation(
            // parent: animation, curve: Curves.decelerate);
            // return ScaleTransition(
            //     scale: animation,
            //     alignment: Alignment.center,
            //     child: child);
            return SlideTransition(
              position: Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero)
                  .animate(animation),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 200),
        );
}
