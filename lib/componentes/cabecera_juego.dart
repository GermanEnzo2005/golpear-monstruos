import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/estado_app.dart';

class CabeceraJuego extends StatelessWidget {
  const CabeceraJuego({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<EstadoApp>();
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Fila 1: usuario y tipo de cuenta
            Row(
              children: [
                Image.asset('assets/images/${app.skinEquipada}.png', height: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    app.usuario,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: app.esPro ? Colors.amber : cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app.esPro ? '👑 ${app.tipoCuenta}' : app.tipoCuenta,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: app.esPro ? Colors.black87 : cs.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Fila 2: puntaje, mejor y diamantes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dato(context, '⭐', 'Puntaje', '${app.puntaje}'),
                _dato(context, '🏆', 'Mejor', '${app.mejor}'),
                _dato(context, '💎', 'Diamantes', '${app.diamantes}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(BuildContext context, String emoji, String etiqueta, String valor) {
    final color = Theme.of(context).colorScheme.onPrimaryContainer;
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etiqueta, style: TextStyle(fontSize: 11, color: color)),
            Text(valor,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ],
    );
  }
}