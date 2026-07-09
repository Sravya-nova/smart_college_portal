import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ShellTab { dashboard, schedule, notices, profile }

class NavigationNotifier extends StateNotifier<ShellTab> {
  NavigationNotifier() : super(ShellTab.dashboard);

  void selectTab(ShellTab tab) {
    state = tab;
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, ShellTab>((ref) {
  return NavigationNotifier();
});
