import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Muestra el anuncio en video y espera a que el usuario lo cierre.
Future<void> mostrarAnuncio(BuildContext context) {
  //showDialog abre una modal arriba de la pantalla actusl
  return showDialog(
    context: context,
    //tocar afuera no la cierra. El usuario no puede saltearse el anuncio
    barrierDismissible: false,
    builder: (_) => const _Anuncio(),
  );
}
//StatefulWidget porque tiene datos que cambian: si el video cargó y 
//cuántos segundos pasaron. El guion bajo lo hace privado.
class _Anuncio extends StatefulWidget {
  const _Anuncio();
//al usar StatefulWidget es necesario dividir en dos partes anuncio descripcion que no cambia
// y anuncioState, el objeto vivo que cambia 
  @override
  State<_Anuncio> createState() => _AnuncioState();
}

class _AnuncioState extends State<_Anuncio> {
  //el control deromoto del video
  late final VideoPlayerController _video;
  //inidca si el video cargo o no
  bool listo = false;
  //segundos reproduciodos
  int segundos = 0; // segundos que pasaron del video

  // Desde qué segundo se puede cerrar el anuncio
  static const int segundosParaCerrar = 5;
  //prepara y arranca el video
  @override
  void initState() {
    super.initState();
    //crea el controlar para el video descargado
    _video = VideoPlayerController.asset('assets/videos/publicidad.mp4')
      ..initialize().then((_) { //prepara el video y cuinado termina lo reproduce
        if (!mounted) return;
        setState(() => listo = true);
        _video.play();
      })
      ..addListener(() {  //se ejecuta cada vez que el video avanza,y con setState redibuja el boton
        final s = _video.value.position.inSeconds;
        if (mounted && s != segundos) setState(() => segundos = s);//if (!mounted) return; evita errores si cerraron la ventana antes de que cargara.
      });
  }
  //Se ejecuta al cerrar la ventana. Libera el video de la memoria y deja de reproducirlo. Si no, el sonido podría seguir sonando o gastar recursos.
  @override
  void dispose() {
    _video.dispose();
    super.dispose();
  }
  //la pantalla modal qyue se ve
  @override
  Widget build(BuildContext context) {
    //los valores que se ven como si el boton de cerrar ya esta disponible o cuento falta
    final puedeCerrar = segundos >= segundosParaCerrar;
    final faltan = segundosParaCerrar - segundos;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📢 Publicidad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (listo) // si el video esta listo lo meutra sino la ruedita de carga
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: _video.value.aspectRatio,
                  child: VideoPlayer(_video),
                ),
              )
            else
              const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 10),
            FilledButton(//el boon de cerrar
              onPressed: puedeCerrar ? () => Navigator.pop(context) : null, //el boton esta en gris indicando que no se puede tocar
              child: Text(puedeCerrar ? 'Cerrar ✖' : 'Cerrar en $faltan'), //si todabia no peude cerrar muetra lo que falta
            ),
          ],
        ),
      ),
    );
  }
}