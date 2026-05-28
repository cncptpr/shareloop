import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shareloop/screens/home_screen.dart';
import 'package:shareloop/screens/message_screen.dart';
import 'package:shareloop/screens/profile_screen.dart';
import 'package:shareloop/screens/explore_screen.dart';

enum Routes {
  home('/'),
  explore('/'),
  message('/message'),
  profile('/profile'),
  counter('/counter');

  final String route;
  const Routes(this.route);

  go(BuildContext ctx) => ctx.go(route);
}

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (ctx, state, navShell) => Scaffold(
        body: navShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navShell.currentIndex,
          onTap: (index) => navShell.goBranch(index),
          items: const [
            BottomNavigationBarItem(label: "Explore", icon: Icon(Icons.search)),
            BottomNavigationBarItem(
              label: "Messages",
              icon: Icon(Icons.message),
            ),
            BottomNavigationBarItem(label: "Profile", icon: Icon(Icons.person)),
          ],
        ),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.explore.route,
              builder: (ctx, state) => const ExploreScreen(),
              routes: [
                GoRoute(
                  path: Routes.counter.route,
                  builder: (ctx, state) => const Homescreen(),
                ),
              ],
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
