import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/property.dart';
import '../models/vehicle.dart';
import '../models/vendor_work.dart';
import '../features/splash/splash_screen.dart';
import '../features/shell/main_nav_shell.dart';
import '../features/home/home_screen.dart';
import '../features/request_wizard/request_wizard_screen.dart';
import '../features/properties/properties_screen.dart';
import '../features/properties/property_detail_screen.dart';
import '../features/vehicles/vehicles_screen.dart';
import '../features/vehicles/vehicle_detail_screen.dart';
import '../features/vendor/vendor_registration_screen.dart';
import '../features/vendor/vendor_works_screen.dart';
import '../features/marketing/marketing_request_screen.dart';
import '../features/admin/admin_portal_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Four visible tabs plus the direct admin / dispatch route.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 2: Book Service Wizard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/request',
                builder: (context, state) {
                  final category = state.uri.queryParameters['category'];
                  return RequestWizardScreen(initialCategory: category);
                },
              ),
            ],
          ),

          // Tab 3: Properties Explorer
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/properties',
                builder: (context, state) => const PropertiesScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final property = state.extra as Property?;
                      if (property != null) {
                        return PropertyDetailScreen(property: property);
                      }
                      return const PropertiesScreen();
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 4: Join Artisan (Vendor KYC)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vendor',
                builder: (context, state) => const VendorRegistrationScreen(),
              ),
            ],
          ),

          // Tab 5: Admin / Dispatch Portal
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminPortalScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/vehicles',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VehiclesScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final vehicle = state.extra as Vehicle?;
              if (vehicle != null) {
                return VehicleDetailScreen(vehicle: vehicle);
              }
              return const VehiclesScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: '/work',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VendorWorksScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final work = state.extra as VendorWork?;
              if (work != null) return VendorWorkDetailScreen(work: work);
              return const VendorWorksScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: '/list-asset',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MarketingRequestScreen(),
      ),
    ],
  );
}
