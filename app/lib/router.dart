import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shareloop/pages/messagescreen.dart';
import 'package:shareloop/pages/homescreen.dart';
import 'package:shareloop/pages/profilescreen.dart';
import 'package:shareloop/pages/searchscreen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (ctx, state) {
        return const Homescreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'messages',
          builder: (BuildContext context, GoRouterState state) {
            return const MessageScreen();
          },
        ),
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state){
            return const ProfileScreen();
          }
        ),
        GoRoute(
          path: 'search',
          builder: (BuildContext context, GoRouterState state){
            return const SearchScreen();
          }
        )
      ],
    ),
  ],
);