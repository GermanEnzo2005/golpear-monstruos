import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'modelos/estado_app.dart';
import 'pantallas/pantalla_menu.dart';
import 'tema/tema_app.dart';
//primera funcion que ejecutar el dart al iniciar la app es async porque adentro hay cosas que hay que esperar
Future<void> main() async {
  //prepara el puente entre el flutter y el celu
  WidgetsFlutterBinding.ensureInitialized();
  //fija la pantalla en vertical
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //crea el estado global y espera a que lea todos los datos guardados
  final estado = EstadoApp();
  await estado.cargar();
  //arranca la app con priovider permiotiendole a l s pantallas que compartan datos eestnre si permitiendo que todas puedan ver los estados de estadoApp
  runApp(ChangeNotifierProvider.value(value: estado, child: const MyApp()));
}
//widget raiz es StatelessWidget porque lo unico que cambia el tema viene de estadoApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //busca el ultimo tema guardado en estado
    final oscuro = context.watch<EstadoApp>().oscuro;
    return MaterialApp(
      title: 'Golpear Monstruos',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      darkTheme: TemaApp.oscuro,
      themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,
      home: const PantallaMenu(),
    );
  }
}