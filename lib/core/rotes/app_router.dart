import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/profile_setup_screen.dart';
import '../../screens/buddy_search/buddy_search_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/chat/meetup_scheduler_screen.dart';
import '../../screens/my_buddies/my_buddies_screen.dart';
import '../../screens/forum/forum_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../widgets/bottom_nav_bar.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/profile-setup', builder: (_, __) => const ProfileSetupScreen()),
      ShellRoute(
        builder: (context, state, child) => BottomNavBar(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const BuddySearchScreen()),
          GoRoute(path: '/buddies', builder: (_, __) => const MyBuddiesScreen()),
          GoRoute(path: '/forum', builder: (_, __) => const ForumScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/chat/:matchId/:buddyName',
        builder: (_, state) => ChatScreen(
          matchId: state.pathParameters['matchId']!,
          buddyName: state.pathParameters['buddyName']!,
        ),
      ),
      GoRoute(
        path: '/meetup/:matchId',
        builder: (_, state) => MeetupSchedulerScreen(
          matchId: state.pathParameters['matchId']!,
        ),
      ),
    ],
  );
}