import 'package:flutter/material.dart';
import 'package:swallow_app/screens/candidato/explorar/explorar_screen.dart';
import 'package:swallow_app/screens/candidato/matches/matches_screen.dart';
import 'package:swallow_app/screens/candidato/postulaciones/postulaciones_screen.dart';
import '../screens/candidato/loading/loading_screen.dart';
import '../screens/candidato/vacantes/vacantes_screen.dart';
import 'route_names.dart';
import '../screens/auth/select_user_type_screen.dart';

import '../widgets/navigation/bottom_tab_navigator.dart';
import '../widgets/navigation/empresa_bottom_navigator.dart';
import '../screens/candidato/perfil/perfilScreen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.loading:
        return MaterialPageRoute(builder: (_) => const LoadingScreen());

      /*case RouteNames.selectUserType:
        return MaterialPageRoute(builder: (_) => const SelectUserTypeScreen());*/
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const SelectUserTypeScreen());

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

      case RouteNames.PerfilCandidato:
        return MaterialPageRoute(builder: (_) => const PerfilScreen());

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