import 'package:auto_route/auto_route.dart';

import 'package:bazur/navigation/router.gr.dart';
import 'package:flutter/material.dart';
import 'root_guard.dart';
import 'route_builders.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: RootRoute.page,
          guards: [RootGuard()],
          children: [
            AutoRoute(
              path: '',
              page: DictionaryRoute.page,
            ),
            CustomRoute(
              path: 'editor',
              page: WordEditorRoute.page,
              customRouteBuilder: sheetRouteBuilder,
            ),
            CustomRoute(
              path: 'diff',
              page: WordsDiffRoute.page,
              customRouteBuilder: sheetRouteBuilder,
            ),
            CustomRoute(
              path: ':id',
              page: WordLoaderRoute.page,
              customRouteBuilder: dialogRouteBuilder,
            ),
            CustomRoute(
              path: ':id',
              page: WordRoute.page,
              customRouteBuilder: sheetRouteBuilder,
            ),
          ],
        ),
        AutoRoute(
          path: '/home',
          page: HomeRoute.page,
        ),
        AutoRoute(
          path: '/settings',
          page: SettingsRoute.page,
        ),
        RedirectRoute(path: '*', redirectTo: '/'),
      ];
}

@RoutePage(name: 'RootRoute')
class RootRouteScreen extends AutoRouter {
  const RootRouteScreen({Key? key}) : super(key: key);
}
