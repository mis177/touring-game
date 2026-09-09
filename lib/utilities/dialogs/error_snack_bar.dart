import 'package:flutter/material.dart';
import 'package:touring_game/core/errors/app_exception.dart';

void showErrorSnackBar(BuildContext context, Object error) {
  final message = error is AppException
      ? error.message
      : 'Something went wrong. Please try again.';
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
