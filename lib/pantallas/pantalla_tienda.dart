import 'package:flutter/material.dart';
//para leer el estado global de la app 
import 'package:provider/provider.dart';
//diamantes, modo pro o bzsic, skinsss
import '../modelos/estado_app.dart';
// contenedro de las ofertaas que se venden de diamantes en la app
class _Paquete {
  final int diamantes;
  final String precio;
  const _Paquete(this.diamantes, this.precio);
}
//los paquetes que estan cargados en la tinesa
const _paquetes = [
  _Paquete(100, '0,99'),
  _Paquete(550, '4,99'),
  _Paquete(1200, '9,99'),
];
//contenedor de las skins para comprar en la tiernda
class _Skin {
  final String id;
  final String nombre;
  final String imagen; // ruta del la imagben del moustro en la carpeta de assets
  final int precio;
  const _Skin(this.id, this.nombre, this.imagen, this.precio);
}

// 
const _skins = [
  _Skin('monstruo', 'Monstruo verde', 'assets/images/monstruo.png', 0),
  _Skin('monstruo2', 'Monstruo azul', 'assets/images/monstruo2.png', 30),
];

//extinede de StatelessWidget porque no guarda un estado propio modifca elestado de la app
//la skin seleccionada para el resto del juego y los diamantes que tien el usuario y actualiza cada cambio en EstadoApp
class PantallaTienda extends StatelessWidget {
  const PantallaTienda({super.key});

  @override //construyer todo lo estetico de la tienda
  Widget build(BuildContext context) {
    final app = context.watch<EstadoApp>();

    return Scaffold( //scaffold es el esqueleto de la pantalla el header, el body y footer
      appBar: AppBar(title: Text('Tienda 💎 ${app.diamantes}')),
      body: ListView(// el body esta dentro de una columna qe se puede deslizar
        padding: const EdgeInsets.all(16),
        children: [
          // compra el modo pro o cancela la susbcripcion todo dependiendo de sei ya esta activado el modo pro o no
          Card(
            color: app.esPro ? Colors.amber : null,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Text('👑', style: TextStyle(fontSize: 36)),
              title: Text(
                app.esPro ? 'Cuenta PRO activa' : 'Hacete PRO',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(app.esPro
                  ? 'Sin anuncios.'
                  : 'Sin anuncios para siempre'),
              trailing: FilledButton(
                onPressed: () => _comprarPro(context, app),
                child: Text(app.esPro ? 'Quitar' : '\$4,99'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // crea las tarjetas de los mosutros para seleccinar la skin 
          const Text('Skins de monstruo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          //se repite por cada slkin que esta cargada
          for (final s in _skins) _tarjetaSkin(context, app, s),
          const SizedBox(height: 16),

          // lar tarjetas con los dimantes que se venden
          const Text('Paquetes de diamantes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final p in _paquetes)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: const Text('💎', style: TextStyle(fontSize: 30)),
                title: Text('${p.diamantes} diamantes',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                trailing: FilledButton(
                  onPressed: () => _pagoSimulado(
                    context,
                    '${p.diamantes} diamantes',
                    '\$${p.precio}',
                    () => app.sumarDiamantes(p.diamantes),
                  ),
                  child: Text('\$${p.precio}'),
                ),
              ),
            ),
            //el footer
          const SizedBox(height: 12),
          const Text('',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
  //revisa si la skin se esta usando ya en ese caso figura como equipada e inabilita el boton
  Widget _tarjetaSkin(BuildContext context, EstadoApp app, _Skin s) {
    final comprada = app.skinsCompradas.contains(s.id);
    final equipada = app.skinEquipada == s.id;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Image.asset(s.imagen, width: 56, height: 56,
            errorBuilder: (_, __, ___) => const Text('👾', style: TextStyle(fontSize: 36))),
        title: Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(comprada ? (equipada ? 'Equipada ✅' : 'Comprada') : '💎 ${s.precio}'),
        trailing: FilledButton(
          onPressed: equipada
              ? null
              : () {
                  if (comprada) {
                    app.equiparSkin(s.id);
                  } else if (app.comprarSkin(s.id, s.precio)) {
                    app.equiparSkin(s.id);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No te alcanzan los diamantes 💎')),
                    );
                  }
                },
          child: Text(comprada ? 'Equipar' : 'Comprar'),
        ),
      ),
    );
  }
  //si ya esta en modo pro lo quita al tocar el boton 
  Future<void> _comprarPro(BuildContext context, EstadoApp app) async {
    if (app.esPro) {
      app.alternarPro(); // volver a BASIC
      return;
    }
    await _pagoSimulado(context, 'Cuenta PRO', '\$4,99', app.alternarPro);
  }
  //simula que se realiza una compra mostrando, un cartel para confirmar compra y mosteando 
  //la informacion de la compra y al confimar muestra una ruedita de carga por 2 segundos
  Future<void> _pagoSimulado(
      BuildContext context, String item, String precio, VoidCallback alExito) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirmar compra'),
        content: Text('$item por $precio'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Pagar')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    //ewl cuirculo de carga al confimrae y la notificacion de la compra
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!context.mounted) return;
    Navigator.pop(context);
    alExito();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ ¡Compra exitosa! $item')),
    );
  }
}