import 'dart:ui';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LoaderTransparent extends StatelessWidget {
  Color? color;
  LoaderTransparent({required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Container(
          color: Colors.transparent,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 3, sigmaY: 3), // Adjust the blur intensity
          child: Container(
            color: Colors.black.withOpacity(
                0.003), // Adjust the opacity of the blurred overlay
          ),
        ),
        Center(
          child: Image.asset(
            "assets/tyreloading.gif",
            height: 65.0,
            width: 65.0,
            color: Colors.black,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );

    // Container(
    //     width: double.infinity,
    //     color: Colors.transparent,
    //     child: Center(
    //         child: SizedBox(
    //       height: 60.0,
    //       width: 60.0,
    //       child: Image.asset(
    //         "assets/tyreloading.gif",
    //         color: color,
    //         fit: BoxFit.fill,
    //       ),
    //       // CircularProgressIndicator(
    //       //     valueColor: AlwaysStoppedAnimation(Colors.blue),
    //       //     strokeWidth: 5.0)
    //     )));
  }
}
