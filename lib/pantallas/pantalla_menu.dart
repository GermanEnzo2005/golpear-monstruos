import 'package:flutter/material.dart';
//PARA QUE LOLS BOTONES SE ACTUAKLICAN AL CAMBIAR EL MODO OSEA SEAN REACTIVOS
import 'package:provider/provider.dart';
import '../modelos/estado_app.dart';
import 'pantalla_juego.dart';
import 'pantalla_tienda.dart';
//extiende de StatelessWidget porque no tiene estado propio carga el almacenado en estado app
class PantallaMenu extends StatelessWidget {
  const PantallaMenu({super.key});

  @override
  Widget build(BuildContext context) {
    //lee el estado de la app y redibuja el menu cuando el estado cambis
    final app = context.watch<EstadoApp>();
  //Scaffold es el esqueleto de la app
    return Scaffold(
      //esto es el fondo del menu con degradado
      body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: app.oscuro
              ? const [Color(0xFF2A2540), Color(0xFF1E1B2E)]
              : const [Color(0xFFB9F6CA), Color(0xFFFFF4E0)],
        ),
      ),
      //tanto la binebenida como los botones que aparecen superpuesrtos al fondo
      //safe area evita que la camara o la barra de estado tape el contenido , column apila los elementons verticalmente y main axisalingmen los centra
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //muestra la sin equipada
              Image.asset('assets/images/${app.skinEquipada}.png', height: 140),
              const SizedBox(height: 8),
              //el titulazo
              Text(
                'Golpear Monstruos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                  shadows: const [
                    Shadow(color: Colors.black26, offset: Offset(2, 3), blurRadius: 4),
                  ],
                ),
              ),
              //la binevenida al usuario
              const SizedBox(height: 8),
              Text('Hola, ${app.usuario} 👋  •  💎 ${app.diamantes}'),
              const SizedBox(height: 40),

              // boton jugar
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PantallaJuego()),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 30),
                  label: const Text('JUGAR', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(height: 14),

              // boton TIENDA
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PantallaTienda()),
                  ),
                  icon: const Icon(Icons.storefront),
                  label: const Text('TIENDA'),
                ),
              ),
              const SizedBox(height: 14),

              // Botón modo claro/oscuro
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.read<EstadoApp>().cambiarTema(),
                  icon: Icon(app.oscuro ? Icons.light_mode : Icons.dark_mode),
                  label: Text(app.oscuro ? 'Modo claro' : 'Modo oscuro'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}