import 'package:flutter/material.dart';

class AccountModeStore {
  AccountModeStore._();

  static final ValueNotifier<bool> isSeller = ValueNotifier<bool>(true);

  static void toggle() => isSeller.value = !isSeller.value;
}
