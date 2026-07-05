import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shareloop/screens/message_screen.dart';
import 'package:shareloop/screens/profile_screen.dart';
import 'package:shareloop/screens/explore_screen.dart';

enum Routes {
  explore('/'),
  message('/message'),
  profile('/profile');

  final String route;
  const Routes(this.route);

  go(BuildContext ctx) => ctx.go(route);
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> exploreBranchKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> messagesBranchKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> profileBranchKey = GlobalKey<NavigatorState>();
final exploreReset = ValueNotifier(0);
final messagesReset = ValueNotifier(0);
final profileReset = ValueNotifier(0);

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (ctx, state, navShell) => Scaffold(
        body: navShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navShell.currentIndex,
          onDestinationSelected: (index) {
            if (navShell.currentIndex == index) {
              final keys = [exploreBranchKey, messagesBranchKey, profileBranchKey];
              keys[index].currentState?.popUntil((route) => route.isFirst);
              [exploreReset, messagesReset, profileReset][index].value++;
            }
            navShell.goBranch(index);
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.search), label: "Entdecken"),
            NavigationDestination(icon: Icon(Icons.message), label: "Nachrichten"),
            NavigationDestination(icon: Icon(Icons.person), label: "Profil"),
          ],
        ),
      ),
      branches: [
        StatefulShellBranch(
          navigatorKey: exploreBranchKey,
          routes: [
            GoRoute(
              path: Routes.explore.route,
              builder: (ctx, state) => ExploreScreen(resetNotifier: exploreReset),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: messagesBranchKey,
          routes: [
            GoRoute(
              path: Routes.message.route,
              builder: (ctx, state) => MessageScreen(resetNotifier: messagesReset),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: profileBranchKey,
          routes: [
            GoRoute(
              path: Routes.profile.route,
              builder: (ctx, state) => ProfileScreen(resetNotifier: profileReset),
            ),
          ],
        ),
      ],
    ),
  ],
);
