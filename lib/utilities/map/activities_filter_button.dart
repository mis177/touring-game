import 'package:flutter/material.dart';

ElevatedButton getFilterButton(
    {required bool clickedThis,
    required bool clickedOther,
    required String text,
    required function}) {
  return ElevatedButton(
    style: ButtonStyle(
      elevation: MaterialStateProperty.resolveWith<double?>(
          (Set<MaterialState> states) {
        if (clickedThis) {
          return 1;
        } else {
          return 10;
        }
      }),
    ),
    onPressed: () {
      clickedThis = !clickedThis;
      if (clickedThis) {
        clickedOther = false;
      }
      function();
    },
    child: Text(text),
  );
}
