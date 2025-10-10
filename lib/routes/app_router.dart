import 'package:flutter/material.dart';
import 'package:swallow_app/screens/auth/register/phone_code_can_screen.dart';
import 'package:swallow_app/screens/auth/register/welcome_register.dart';
import 'package:swallow_app/screens/candidato/explorar/explorar_screen.dart';
import 'package:swallow_app/screens/candidato/matches/matches_screen.dart';
import 'package:swallow_app/screens/candidato/postulaciones/postulaciones_screen.dart';
import '../screens/candidato/loading/loading_screen.dart';
import '../screens/candidato/vacantes/vacantes_screen.dart';
import 'route_names.dart';
import '../screens/auth/register/select_user_type_screen.dart';
import '../screens/auth/register/register_emp_screen.dart';
import '../screens/auth/register/phone_verification_can_screen.dart';
import '../screens/auth/register/phone_verification_emp_screen .dart';
import '../screens/auth/register/phone_code_emp_screen.dart';
import '../screens/auth/register/register_can_screen.dart';


import '../screens/auth/login_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/Loading_inicio.dart';

import '../widgets/navigation/bottom_tab_navigator.dart';
import '../widgets/navigation/empresa_bottom_navigator.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.LoadingInicio:
        return MaterialPageRoute(builder: (_) => const LoadingInicioScreen());

      case RouteNames.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      /*case RouteNames.selectUserType:
        return MaterialPageRoute(builder: (_) => const SelectUserTypeScreen());*/
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteNames.selectUserType:
        return MaterialPageRoute(builder: (_) => const SelectUserTypeScreen());
      
      case RouteNames.registerCandidato:
        return MaterialPageRoute(builder: (_) => const RegisterCandidatoScreen());

      case RouteNames.registerEmpresa:
        return MaterialPageRoute(builder: (_) => const RegisterEmpresaScreen());

      case RouteNames.phone_verification_can:
        return MaterialPageRoute(builder: (_) => const PhoneVerificationCanScreen());

      case RouteNames.phone_verification_emp:
        return MaterialPageRoute(builder: (_) => const PhoneVerificationEmpScreen());

      case RouteNames.phone_code_emp:
        return MaterialPageRoute(builder: (_) => const PhoneCodeEmpScreen());

      case RouteNames.phone_code_can:
        return MaterialPageRoute(builder: (_) => const PhoneCodeCanScreen());
      
      case '/welcome-register':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => WelcomeRegisterScreen(userType: args['userType']),
        );

      

    // Rutas Candidato
      case RouteNames.homeCandidato:
        return MaterialPageRoute(builder: (_) => const BottomTabNavigator());

      /*case RouteNames.vacantesCandidato:
        return MaterialPageRoute(builder: (_) => const VacantesScreen());*/

      case RouteNames.postulacionesCandidato:
        return MaterialPageRoute(builder: (_) => const PostulacionesCandidatoScreen());

      case RouteNames.matchesCandidato:
        return MaterialPageRoute(builder: (_) => const MatchesCandidatoScreen());

      case RouteNames.explorarCandidato:
        return MaterialPageRoute(builder: (_) => const ExplorarCandidatoScreen());

    // Rutas Empresa
      case RouteNames.homeEmpresa:
        return MaterialPageRoute(builder: (_) => const EmpresaBottomNavigator());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No se encontró la ruta ${settings.name}'),
            ),
          ),
        );
    }
  }
}