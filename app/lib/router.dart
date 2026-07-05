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

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (ctx, state, navShell) => Scaffold(
        body: navShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navShell.currentIndex,
          onDestinationSelected: (index) => navShell.goBranch(index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.search), label: "Explore"),
            NavigationDestination(icon: Icon(Icons.message), label: "Messages"),
            NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.explore.route,
              builder: (ctx, state) => const ExploreScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.message.route,
              builder: (ctx, state) => const MessageScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profile.route,
              builder: (ctx, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
