import 'package:flutter/material.dart';
//contenedor que agrupa ambos temas del super juego
class TemaApp {
  //recibe el si el tema es claro o oscuro Brightness.light o Brightness.dark y 
  //arma todo lo necesario de ese tema paleta de colores,textos etc
  static ThemeData _base(Brightness brillo) {
    //flutter genera una paleta de colores a partir de la semilla, 
    //0xFFFF8A00 que es naranja es la semilla y de ahi salen colores qe combinan entre 
    //si primary y primaryContainer,etc con brightness indicamos si tienje que ser oscuros o claros
    //Material 3 cada color tiene un companero que contrasta con él. primaryContainer es un fondo y 
    //onPrimaryContainer es el color del texto que va encima. 
    //Siempre son opuestos en claridad, por eso nunca se pierde la lectura. Esa es la clave del arreglo.
    final esquema = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF8A00),
      brightness: brillo,
    );
    //es el manual de estilos de la app
    return ThemeData(
      //se actibvva metrial 3 para usar el disño de google moderlo de bordes redondeados, mejores colores
      useMaterial3: true,
      colorScheme: esquema,
      //si se eselecciono claro usa un color cremita si se selecciono modo oscuro un violeta mucho mas oscuro
      scaffoldBackgroundColor: brillo == Brightness.light
          ? const Color(0xFFFFF4E0)
          : const Color(0xFF1E1B2E),
          //estilo de la barra superior, da titulo centrado color de fondo , de los iconos como la flecha
          //estiliza los textos
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: esquema.primaryContainer,
        foregroundColor: esquema.onPrimaryContainer,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: esquema.onPrimaryContainer,
        ),
      ),
      //estiliza los botnes 
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static final claro = _base(Brightness.light);
  static final oscuro = _base(Brightness.dark);
}