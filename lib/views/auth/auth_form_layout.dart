import 'package:flutter/material.dart';

class AuthScrollableBody extends StatelessWidget {
  const AuthScrollableBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(25),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight > 50
                  ? constraints.maxHeight - 50
                  : 0,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: 96,
        child: Image.asset('lib/images/app_icon.png'),
      ),
    );
  }
}
