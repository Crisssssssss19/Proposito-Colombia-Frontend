import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/vacancy_provider.dart';
import 'providers/candidate_provider.dart';
import 'providers/application_provider.dart';
import 'routes/app_router.dart';
import 'routes/route_names.dart';

void main() {
  runApp(const SwallowApp());
}

class SwallowApp extends StatelessWidget {
  const SwallowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VacancyProvider()),
        ChangeNotifierProvider(create: (_) => CandidateProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Swallow App',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: RouteNames.LoadingInicio,
            onGenerateRoute: AppRouter.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}