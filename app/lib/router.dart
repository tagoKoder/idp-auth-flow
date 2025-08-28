import 'package:go_router/go_router.dart';
import 'features/auth/presentation/sign_in_screen.dart';
import 'features/register/presentation/register_screen.dart';
import 'features/profile/presentation/home_screen.dart';

final router = GoRouter(
  initialLocation: '/signin',
  routes: [
    GoRoute(path: '/signin', builder: (_, __) => const SignInScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
  ],
);
