import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// foundation.dart: trae ChangeNotifier, la clase que permite avisar cambios
//shared_preferences: guarda datos en el dispositivo, 
//por eso funciona offline y los datos sobreviven al cerrar la app

//extends ChangeNotifier le da el poder de llamar a 
//notifyListeners(), que le dice a todas las pantallas que 
//están "escuchando": "algo cambió, redibujate". Eso es lo 
//que hace Provider por detrás.
class EstadoApp extends ChangeNotifier {
  //datos o variables del usuario como nombre, skin que compro,
  //si es cunets pro o no , cantidad de diamantes, puntaje maximo alcanzado
  final String usuario = 'German';

  bool esPro = false;
  int diamantes = 50;
  int puntaje = 0;
  int mejor = 0;
  bool oscuro = false;
  String skinEquipada = 'monstruo';
  Set<String> skinsCompradas = {'monstruo'};
  //Es el acceso al almacenamiento local. late significa "se asigna despues"
  late SharedPreferences _prefs;
//PARA SABER QUE TIPO ES EL USUARIO
  String get tipoCuenta => esPro ? 'PRO' : 'BASIC';

  //se llama al iniciar la app en main.dart lee los datos guardados en el cell y en caso 
  //que no haya datos guardado asigna vbalores por defecto
  Future<void> cargar() async {
    _prefs = await SharedPreferences.getInstance();
    esPro = _prefs.getBool('pro') ?? false;
    diamantes = _prefs.getInt('diamantes') ?? 50;
    mejor = _prefs.getInt('mejor') ?? 0;
    oscuro = _prefs.getBool('oscuro') ?? false;
    skinEquipada = _prefs.getString('skin') ?? 'monstruo';
    skinsCompradas = (_prefs.getStringList('skins') ?? ['monstruo']).toSet();
  }

  //guarda los nuevos datos para que al cerrar la app y volverla a abrir estos se queden guardados
  void _guardar() {
    _prefs.setBool('pro', esPro);
    _prefs.setInt('diamantes', diamantes);
    _prefs.setInt('mejor', mejor);
    _prefs.setBool('oscuro', oscuro);
    _prefs.setString('skin', skinEquipada);
    _prefs.setStringList('skins', skinsCompradas.toList());
  }

  void setPuntaje(int p) {
    puntaje = p;
    //hace que todas las pantallas que usen watch se reedibujen con los nuevos datos
    notifyListeners();
  }
  //guarda el nuevo mejor puntaje si es meyor que el record
  void registrarPuntaje(int p) {
    if (p > mejor) mejor = p;
    _guardar();
    notifyListeners();
  }
  //suma la nueva cantidad de conseguidos en la partida
  // y con notify le informa a las pantallas el nuevo cambio para que se redibujen
  void sumarDiamantes(int n) {
    diamantes += n;
    _guardar();
    notifyListeners();
  }
  //verifica si los diamante salcanzan para una compra y los compra
  bool gastarDiamantes(int n) {
    if (diamantes < n) return false;
    diamantes -= n;
    _guardar();
    notifyListeners();
    return true;
  }

  void comprarPro() {
    esPro = true;
    _guardar();
    notifyListeners();
  }

  void cambiarTema() {
    oscuro = !oscuro;
    _guardar();
    notifyListeners();
  }

  void alternarPro() {
    esPro = !esPro;
    _guardar();
    notifyListeners();
  }
  //para comprar skins de la tineda 
  bool comprarSkin(String id, int precio) {
    if (skinsCompradas.contains(id)) return true;
    if (!gastarDiamantes(precio)) return false;
    skinsCompradas.add(id);
    _guardar();
    notifyListeners();
    return true;
  }
  //cambia la skin equipada y guarda los datos 
  void equiparSkin(String id) {
    if (!skinsCompradas.contains(id)) return;
    skinEquipada = id;
    _guardar();
    notifyListeners();
  }
}