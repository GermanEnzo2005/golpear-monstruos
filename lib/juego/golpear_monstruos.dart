import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show TextStyle;
//las 3 cosas que pueden salir de los agujeros
enum Kind { monster, gem, bomb }
//golpear monstruos extiende de el motor de juego de flame por lo que
//tiene un bulce que corre 60 veces por segundo, un lienzo para dibujar y gestion
//de componentes
class GolpearMonstruos extends FlameGame {
  
  GolpearMonstruos({
    required this.onScore,
    required this.onDiamond,
    required this.onGameOver,
  });
//los casbles hacia flutter, el juego no conce la pantalla pero si avisa sumo punto, agarro diamante, perdio
  final void Function(int score) onScore;
  final void Function() onDiamond;
  final void Function(int score) onGameOver;
  //la grilla de 3x3 de los pozos
  static const int cols = 3;
  static const int rows = 3;
  //los 9 pozos
  final List<Hole> holes = [];
  final _rnd = Random();
  final _hudPaint = TextPaint(style: const TextStyle(fontSize: 26));

  double _spawnTimer = 0;
  int score = 0;
  int lives = 3;
  bool running = false;

  String skin = 'monstruo';

  // Dificultad: sube con el score
  //cada cuentos segundos aparece un nuevo evento dogamos
  double get _interval => max(0.45, 1.1 - score * 0.02);
  //cuanto timeopi se queda afuera antes de irse
  double get _stay => max(0.6, 1.5 - score * 0.02);
  //el max pone un piso para que no sea imposible

  @override
  Color backgroundColor() => const Color(0xFF8BC34A);
  //crea los nueve agujeros y los agrega a a lista
  @override
  Future<void> onLoad() async {
    for (var i = 0; i < cols * rows; i++) {
      final h = Hole(this);
      holes.add(h);
      add(h);
    }
    _layout();
  }
  //esto llama a layout si cambia el tamaño de la pantalla
  @override
  void onGameResize(Vector2 s) {
    super.onGameResize(s);
    if (holes.isNotEmpty) _layout();
  }
  //calcula la posicion y tamaño de los agujeros segun la pantalla
  //eja 50 pixeles arriba para las vidas, onGameresize lo vuelve a llamar si 
  //cambia la pantalla asi se adapta 
  void _layout() {
    final cellW = size.x / cols;
    final cellH = (size.y - 50) / rows;
    final side = min(cellW, cellH);
    for (var i = 0; i < holes.length; i++) {
      final c = i % cols;
      final r = i ~/ cols;
      holes[i]
        ..size = Vector2.all(side * 0.85)
        ..position = Vector2(
          c * cellW + (cellW - side * 0.85) / 2,
          50 + r * cellH + (cellH - side * 0.85) / 2,
        );
    }
  }

  // ---------- Controles (los llama la UI de Flutter) ----------
  //vacia los agujeros el puntaje y las vidas pone running en true para indicar que el juego esta corriendo
  // y con resumeEngine arranca el buvle del juego
  void startGame() {
    _clearHoles();
    score = 0;
    lives = 3;
    _spawnTimer = 0.6;
    running = true;
    resumeEngine();
  }
  //resetea todo
  void resetToReady() {
    running = false;
    _clearHoles();
    score = 0;
    lives = 3;
    resumeEngine();
  }
  //para revivir usando diamante socn 1 vida
  void revive() {
    _clearHoles();
    lives = 1;
    _spawnTimer = 1.0;
    running = true;
    resumeEngine();
  }
  //esconde todo
  void _clearHoles() {
    for (final h in holes) {
      h.hide();
    }
  }

  // ---------- Eventos desde los agujeros ----------
  //suma un punto si golpeas a un monstruo
  void monsterHit() {
    score++;
    onScore(score);
  }
  //
  void gemHit() => onDiamond();
  //resta vidas si el jhuego esta corriendo y se saltoe algun moustro o toco una bomba
  //si hay 0 vidas lo detiene 
  void loseLife() {
    if (!running) return;
    lives--;
    if (lives <= 0) {
      running = false;
      _clearHoles();
      onGameOver(score);
    }
  }

  // ---------- Loop ----------
  //el bucle del juego, se ejecuta 60 verces por segundo dt es el
  //tiempo trascurrido, con _rnd sortea un numero entre 0 y 1
  //si este numero es menor a 0.70 sale un mosutruo, si es menor a 
  //0.85 sale una gema y se esta entre 0.85 y 1 sale una bomba
  //este eventro salfdra en uno de los agujeros libres al azar
  @override
  void update(double dt) {
    //flame llama al update con un dto de 0.16 
    super.update(dt);
    if (!running) return;

    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer = _interval;
      //toma los agujeros libres y los convierte en una lista
      final free = holes.where((h) => !h.up).toList();
      if (free.isNotEmpty) {
        final r = _rnd.nextDouble();
        final kind = r < 0.70
            ? Kind.monster
            : r < 0.85
                ? Kind.gem
                : Kind.bomb;
        //sortea una posicion al azar entre los libres
        free[_rnd.nextInt(free.length)].show(kind, _stay);
      }
    }
  }
  //dibuja el HUB las vidas en el centro de la pantalla
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _hudPaint.render(
      canvas,
      '${'❤️' * lives}${'🖤' * (3 - lives).clamp(0, 3)}',
      Vector2(size.x / 2, 8),
      anchor: Anchor.topCenter,
    );
  }
}

// ======================= Agujero =======================
//extiende de PositionComponent porque es un objeto con una posicion y tamaño
//con TapCallbacks permite detectar toques
class Hole extends PositionComponent with TapCallbacks {
  Hole(this.game);

  final GolpearMonstruos game;
  //indica si es agujero esta acopado o no
  bool up = false;
  //inidca que es lo que contiende 
  Kind kind = Kind.monster;
  //tiempo restante del evento antes de esconderse
  double _time = 0;
  //tiempo duro al aparecer
  double _total = 1;
  //coor del pozo
  final _holePaint = Paint()..color = const Color(0xFF5D4037);
  
  final _rimPaint = Paint()..color = const Color(0xFF3E2723);
  late final _tp = TextPaint(style: const TextStyle(fontSize: 48));
  Sprite? _spriteMonstruo;
  Sprite? _spriteBomba;
  Sprite? _spriteDiamante;
    //respaldos por si no cargha la imagen 
    String get _emoji {
    switch (kind) {
      case Kind.monster:
        return '👾';
      case Kind.gem:
        return '💎';
      case Kind.bomb:
        return '💣';
    }
  }

  Sprite? get _sprite {
    switch (kind) {
      case Kind.monster:
        return _spriteMonstruo;
      case Kind.gem:
        return _spriteDiamante;
      case Kind.bomb:
        return _spriteBomba;
    }
  }
  //carga las imagenes
  @override
  Future<void> onLoad() async {
    // La skin verde no tiene sufijo; la azul termina en "2" si al finalagrego la violeta es la 3
    final sufijo = game.skin == 'monstruo' ? '' : '2';
    _spriteMonstruo = await game.loadSprite('${game.skin}.png');
    _spriteBomba = await game.loadSprite('monstruo_bomba$sufijo.png');
    _spriteDiamante = await game.loadSprite('monstruo_diamante$sufijo.png');
  }
  //activa el agujero con un tipo de evento y un tiempo que es el -stay diciendo
  //cuandoty tiempo tiene que salir
  void show(Kind k, double seconds) {
    kind = k;
    up = true;
    _time = seconds;
    _total = seconds;
  }
  //esconde o desactiva el agujero
  void hide() => up = false;
  //resta el timepo si se acaba y era un mostruo resta una vida
  //flame llama al update con un dto de 0.16 , esto porque en el update del juego 
  //se usa super.update(dt) lo que llama al update de cada agujero al mismo tiempo
  @override
  void update(double dt) {
    if (!up) return;
    _time -= dt;
    if (_time <= 0) {
      up = false;
      if (kind == Kind.monster) game.loseLife();
    }
  }
  //cuando golopeas una imagesn dependiendo el tipo hace una cosa u otera
  @override
  void onTapDown(TapDownEvent event) {
    if (!up || !game.running || game.paused) return;
    up = false;
    switch (kind) {
      case Kind.monster:
        game.monsterHit();
        break;
      case Kind.gem:
        game.gemHit();
        break;
      case Kind.bomb:
        game.loseLife();
        break;
    }
  }
  //dibuja el agujero con dos ovalos uno oscuro para el borde y no mas claro para el centro
  //si hay algo afuera del agujero mostruo gema o bomba la imagen crece desde 0, cargando la imagen o el emojo en caso de no estar
  @override
  void render(Canvas canvas) {
    final w = width;
    final h = height;

    canvas.drawOval(Rect.fromLTWH(0, h * 0.55, w, h * 0.4), _rimPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.05, h * 0.58, w * 0.9, h * 0.34), _holePaint);

    if (up) {
      final elapsed = _total - _time;
      final t = (elapsed / 0.15).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(w / 2, h * 0.7);
      canvas.scale(t);
      final sprite = _sprite;
      if (sprite != null) {
        sprite.render(
          canvas,
          position: Vector2(0, -h * 0.2),
          size: Vector2.all(h * 0.8),
          anchor: Anchor.center,
        );
      } else {
        _tp.render(canvas, _emoji, Vector2(0, -h * 0.25), anchor: Anchor.center);
      }
      canvas.restore();
    }
  }
}