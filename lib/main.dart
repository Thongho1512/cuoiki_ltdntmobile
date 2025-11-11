import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auction/presentation/bloc/auction_detail/auction_detail_bloc.dart';
import 'features/auction/presentation/bloc/auction_list/auction_list_bloc.dart';
import 'features/auction/presentation/pages/auction_detail_page.dart';
import 'features/auction/presentation/pages/auction_list_page.dart';
import 'features/splash/splash_page.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<AuctionListBloc>(create: (_) => di.sl<AuctionListBloc>()),
        BlocProvider<AuctionDetailBloc>(
          create: (_) => di.sl<AuctionDetailBloc>(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppConstants.splashRoute,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppConstants.splashRoute:
              return MaterialPageRoute(builder: (_) => const SplashPage());

            case AppConstants.loginRoute:
              return MaterialPageRoute(builder: (_) => const LoginPage());

            case AppConstants.registerRoute:
              return MaterialPageRoute(builder: (_) => const RegisterPage());

            case AppConstants.homeRoute:
              return MaterialPageRoute(builder: (_) => const AuctionListPage());

            case AppConstants.auctionDetailRoute:
              final auctionId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<AuctionDetailBloc>(),
                  child: AuctionDetailPage(auctionId: auctionId),
                ),
              );

            case AppConstants.profileRoute:
              return MaterialPageRoute(builder: (_) => const ProfilePage());

            default:
              return MaterialPageRoute(builder: (_) => const SplashPage());
          }
        },
      ),
    );
  }
}
