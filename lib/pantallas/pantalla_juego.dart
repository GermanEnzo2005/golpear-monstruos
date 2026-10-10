import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../juego/golpear_monstruos.dart';
import '../modelos/estado_app.dart';
import '../publicidad/anuncio.dart';
import '../componentes/cabecera_juego.dart';
//un enum con los 4 estados posibles de la partida
enum EstadoJuego { listo, jugando, pausado, terminado }
//a diferncia de las pantallas anteirore aca se usa StatefulWidget porqwue tiene  variables propias que cambia, estado
class PantallaJuego extends StatefulWidget {
  const PantallaJuego({super.key});

  @override
  State<PantallaJuego> createState() => _PantallaJuegoState();
}

class _PantallaJuegoState extends State<PantallaJuego> {
  late final GolpearMonstruos juego;
  EstadoJuego estado = EstadoJuego.listo;
  //crea el jkuego, se ejecuta una vexz al cargar la pantalla, onscore actualiza el puntaje del juego
  //onDiamon actualiza la cantidad de diamantes del jugador
  //on game over es cunaod el suauario pierde y se llama a teerminar juego
  @override
  void initState() {
    super.initState();
    final app = context.read<EstadoApp>();
    juego = GolpearMonstruos(
      onScore: app.setPuntaje,
      onDiamond: () => app.sumarDiamantes(1),
      onGameOver: _alTerminar,
    );
    juego.skin = app.skinEquipada;
  }

  // botones de abajo, cambia el estado de juego a jugando indicando que se empezo una partida
  void _iniciar() {
    context.read<EstadoApp>().setPuntaje(0);
    juego.startGame();
    setState(() => estado = EstadoJuego.jugando);
  }
  //altera el juago entrer jugando y pausado, pauseEngine para el motor de flame y resumeEngine lo despausa
  void _pausarReanudar() {
    if (estado == EstadoJuego.jugando) {
      juego.pauseEngine();
      setState(() => estado = EstadoJuego.pausado);
    } else if (estado == EstadoJuego.pausado) {
      juego.resumeEngine();
      setState(() => estado = EstadoJuego.jugando);
    }
  }
  //comienza todo de cero
  void _reiniciar() => _iniciar();

  // FINAL JUEGAZO
    Future<void> _alTerminar(int puntaje) async {
    final app = context.read<EstadoApp>();
    //registra el puntaje y cambia el estado del juego a terminado
    app.registrarPuntaje(puntaje);
    setState(() => estado = EstadoJuego.terminado);

    // anuncio al perder solo cuenta BASIC no pro
    if (!app.esPro) {
      await mostrarAnuncio(context);
      if (!mounted) return; //verifica si sigue la pantalla ya que si el codigo siguiera y usara context o setState en una pantalla que ya no existe crashea
    }
    //cartelito con el score de la partida
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('😿 ¡Game Over!'),
        content: Text('Puntaje: $puntaje\nMejor: ${app.mejor}'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  //dibuja la pantalla
  @override
  Widget build(BuildContext context) {
    final jugando = estado == EstadoJuego.jugando;
    final pausado = estado == EstadoJuego.pausado;
    //todo lo dinujable
    return Scaffold(
      //el header de la pantalla de juego donde se muestra los puntajes
      appBar: AppBar(title: const Text('Golpear Monstruos')),
      body: SafeArea(
        child: Column(
          children: [
            const CabeceraJuego(), //la nueva cabecera
            // la zona del juego el mapa
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 4,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    //mensaje que aparece antes de iniciar el juego 
                    GameWidget(game: juego),
                    if (estado == EstadoJuego.listo)
                      const Center(
                        child: Text(
                          'Presioná INICIAR\ny tocá los monstruos 👾\n¡Evitá las bombas 💣!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      //mensaje que parece cunado el juego esta en pausa
                    if (pausado)
                      const Center(
                        child: Text(
                          '⏸ PAUSA',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // TODOS LOS BOTONAZOZ
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  //boton iniicar, si el juego esta en estado de listo o terminado al tocarlo se inicia
                  // en otro caso si es juego ya esta iniicado o pausado no hace nada
                  FilledButton.icon(
                    onPressed: (estado == EstadoJuego.listo ||
                            estado == EstadoJuego.terminado)
                        ? _iniciar
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                  ),
                  //boton reanudar / pausa llama a poausar o reanidar pero solo esta permitido si el juego ya esta en estado de
                  // jugando o inicado
                  FilledButton.icon(
                    onPressed: (jugando || pausado) ? _pausarReanudar : null,
                    icon: Icon(pausado ? Icons.play_circle : Icons.pause),
                    label: Text(pausado ? 'Reanudar' : 'Pausa'),
                  ),
                  //boton de reinicar se puede poner en cualquier momento
                  FilledButton.icon(
                    onPressed: _reiniciar,
                    icon: const Icon(Icons.replay),
                    label: const Text('Reiniciar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}