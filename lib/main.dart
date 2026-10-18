// ============================================================================ //  DINO WORLD - open world dinosaur game (single file Flutter) //  Packages: shared_preferences only. No image assets (all drawn in code). // ============================================================================ import 'dart:math'; import 'package:flutter/material.dart'; import 'package:flutter/scheduler.dart'; import 'package:flutter/services.dart'; import 'package:shared_preferences/shared_preferences.dart';

double cl(double v, double a, double b) => v < a ? a : (v > b ? b : v);

Color shade(Color c, double d) { final h = HSLColor.fromColor(c); return h.withLightness(cl(h.lightness + d, 0.0, 1.0)).toColor(); }

Color tintC(Color c, int v) { if (v == 0) return c; final h = HSLColor.fromColor(c); return h.withHue((h.hue + (v == 1 ? 55.0 : 200.0)) % 360).toColor(); }

// ============================================================================ // 1. LOCALIZATION // ============================================================================ const Map<String, String> kLangNames = { 'th': 'ไทย', 'en': 'English', 'ja': '日本語', 'zh': '中文', 'ko': '한국어', 'ms': 'Bahasa Melayu', 'es': 'Español', };

const List _keys = [ 'title', 'play', 'settings', 'choose', 'start', 'hp', 'atk', 'spd', 'carn', 'herb', 'resume', 'menu', 'retry', 'over', 'survived', 'kills', 'graphics', 'controls', 'language', 'fps', 'shadow', 'res', 'view', 'off', 'low', 'mid', 'high', 'auto', 'reset', 'showfps', 'attackbtn', 'size', 'opacity', 'mode', 'm_tap', 'm_hold', 'm_auto', 'joystick', 'fixed', 'floating', 'lefthand', 'haptic', 'layout', 'layout_hint', 'done', ];

Map<String, String> _m(String s) { final p = s.split('|'); final m = <String, String>{}; for (int i = 0; i < _keys.length && i < p.length; i++) { m[_keys[i]] = p[i]; } return m; }

final Map<String, Map<String, String>> kText = { 'en': _m('DINO WORLD|Play|Settings|Choose your dinosaur|Start game|HP|Attack|Speed|Carnivore|Herbivore|Resume|Main menu|Play again|GAME OVER|Survived|Kills|Graphics|Controls|Language|Frame rate|Shadows|Image detail|View distance|Off|Low|Medium|High|Auto-tune|Reset defaults|Show FPS|Attack button|Size|Opacity|Attack mode|Tap|Hold|Auto|Joystick|Fixed|Floating|Left-handed layout|Vibration|Edit button layout|Drag buttons to place them|Done'), 'th': _m('โลกไดโนเสาร์|เล่น|ตั้งค่า|เลือกไดโนเสาร์ของคุณ|เริ่มเกม|พลังชีวิต|โจมตี|ความเร็ว|กินเนื้อ|กินพืช|เล่นต่อ|เมนูหลัก|เล่นอีกครั้ง|จบเกม|รอดชีวิต|สังหาร|กราฟิก|ปุ่มควบคุม|ภาษา|เฟรมเรต|เงา|ความละเอียดภาพ|ระยะมองเห็น|ปิด|ต่ำ|กลาง|สูง|ปรับอัตโนมัติ|คืนค่าเริ่มต้น|แสดง FPS|ปุ่มโจมตี|ขนาด|ความโปร่งใส|รูปแบบโจมตี|กดครั้งเดียว|กดค้าง|อัตโนมัติ|จอยสติ๊ก|ติดที่เดิม|ลอยตามนิ้ว|วางปุ่มสำหรับคนถนัดซ้าย|สั่นเมื่อกดปุ่ม|จัดตำแหน่งปุ่ม|ลากปุ่มเพื่อวางตำแหน่ง|เสร็จ'), 'ja': _m('ダイノワールド|プレイ|設定|恐竜を選ぼう|ゲーム開始|HP|攻撃|速度|肉食|草食|再開|メインメニュー|もう一度|ゲームオーバー|生存時間|撃破|グラフィック|操作|言語|フレームレート|影|画質|描画距離|オフ|低|中|高|自動調整|初期化|FPS表示|攻撃ボタン|サイズ|透明度|攻撃モード|タップ|長押し|オート|ジョイスティック|固定|フローティング|左利きレイアウト|振動|ボタン配置|ボタンをドラッグして配置|完了'), 'zh': _m('恐龙世界|开始|设置|选择你的恐龙|开始游戏|生命|攻击|速度|肉食|草食|继续|主菜单|再玩一次|游戏结束|存活|击杀|画面|操作|语言|帧率|阴影|画质|视距|关|低|中|高|自动调整|恢复默认|显示FPS|攻击按钮|大小|透明度|攻击模式|点击|长按|自动|摇杆|固定|浮动|左手布局|震动|调整按钮布局|拖动按钮来摆放|完成'), 'ko': _m('다이노 월드|플레이|설정|공룡을 선택하세요|게임 시작|HP|공격|속도|육식|초식|계속|메인 메뉴|다시 하기|게임 오버|생존|처치|그래픽|조작|언어|프레임 속도|그림자|화질|시야 거리|끔|낮음|중간|높음|자동 조정|기본값 복원|FPS 표시|공격 버튼|크기|투명도|공격 방식|탭|길게 누름|자동|조이스틱|고정|플로팅|왼손 배치|진동|버튼 배치 편집|버튼을 끌어서 배치|완료'), 'ms': _m('Dunia Dino|Main|Tetapan|Pilih dinosaur anda|Mula permainan|HP|Serangan|Kelajuan|Karnivor|Herbivor|Sambung|Menu utama|Main semula|TAMAT|Bertahan|Bunuh|Grafik|Kawalan|Bahasa|Kadar bingkai|Bayang|Perincian imej|Jarak pandang|Mati|Rendah|Sederhana|Tinggi|Auto|Set semula|Papar FPS|Butang serang|Saiz|Kelegapan|Mod serang|Ketik|Tahan|Auto|Joystick|Tetap|Terapung|Susun atur kidal|Getaran|Edit susun atur butang|Seret butang untuk meletakkan|Siap'), 'es': _m('Mundo Dino|Jugar|Ajustes|Elige tu dinosaurio|Empezar|PV|Ataque|Velocidad|Carnívoro|Herbívoro|Continuar|Menú principal|Jugar otra vez|FIN DEL JUEGO|Sobreviviste|Bajas|Gráficos|Controles|Idioma|Fotogramas|Sombras|Detalle de imagen|Distancia de visión|No|Bajo|Medio|Alto|Autoajuste|Restablecer|Mostrar FPS|Botón de ataque|Tamaño|Opacidad|Modo de ataque|Toque|Mantener|Auto|Joystick|Fijo|Flotante|Diseño zurdo|Vibración|Editar botones|Arrastra los botones|Listo'), };

const Map<String, Map<String, String>> kNames = { 'en': { 'trex': 'T-Rex', 'allo': 'Allosaurus', 'raptor': 'Raptor', 'dilo': 'Dilophosaurus', 'trice': 'Triceratops', 'stego': 'Stegosaurus', 'para': 'Parasaurolophus', 'brachio': 'Brachiosaurus', 'compy': 'Compsognathus', }, 'th': { 'trex': 'ทีเร็กซ์', 'allo': 'อัลโลซอรัส', 'raptor': 'แรปเตอร์', 'dilo': 'ไดโลโฟซอรัส', 'trice': 'ไทรเซอราทอปส์', 'stego': 'สเตโกซอรัส', 'para': 'พาราซอโรโลฟัส', 'brachio': 'บราคิโอซอรัส', 'compy': 'คอมซอกนาทัส', }, };

String tr(String k) => kText[cfg.lang]?[k] ?? kText['en']![k] ?? k; String dinoName(String id) => kNames[cfg.lang]?[id] ?? kNames['en']![id] ?? id;

// ============================================================================ // 2. SETTINGS (single source of truth, saved automatically) // ============================================================================ final GameSettings cfg = GameSettings.I;

class GameSettings extends ChangeNotifier { static final GameSettings I = GameSettings.(); GameSettings.();

String lang = 'th'; int fps = 30; // 30 / 45 / 60 int shadow = 1; // 0 off, 1 low, 2 high double res = 0.75; // 0.5 / 0.75 / 1.0 (image detail level) int viewDist = 1; // 0 low, 1 mid, 2 high (NPC count + sim radius) bool showFps = false; bool haptic = true; bool leftHanded = false; int atkMode = 0; // 0 tap, 1 hold, 2 auto int atkSize = 1; double atkOpacity = 0.75; int joySize = 1; double joyOpacity = 0.6; bool joyFloating = false; Offset joyPos = const Offset(0.13, 0.74); Offset atkPos = const Offset(0.88, 0.72); Offset runPos = const Offset(0.75, 0.86);

double get atkPx => const [64.0, 80.0, 98.0][atkSize]; double get runPx => atkPx * 0.78; double get joyPx => const [110.0, 140.0, 170.0][joySize];

void update(void Function() f) { f(); notifyListeners(); _save(); }

void live(void Function() f) { f(); notifyListeners(); }

void commit() => _save();

void applyDefaultLayout() { if (leftHanded) { joyPos = const Offset(0.87, 0.74); atkPos = const Offset(0.12, 0.72); runPos = const Offset(0.25, 0.86); } else { joyPos = const Offset(0.13, 0.74); atkPos = const Offset(0.88, 0.72); runPos = const Offset(0.75, 0.86); } }

void resetGraphics() { update(() { fps = 30; shadow = 1; res = 0.75; viewDist = 1; showFps = false; }); }

void resetControls() { update(() { leftHanded = false; atkMode = 0; atkSize = 1; atkOpacity = 0.75; joySize = 1; joyOpacity = 0.6; joyFloating = false; haptic = true; applyDefaultLayout(); }); }

void autoTune(double raw) { update(() { if (raw >= 56) { fps = 60; shadow = 2; res = 1.0; viewDist = 2; } else if (raw >= 40) { fps = 45; shadow = 1; res = 0.75; viewDist = 1; } else if (raw > 0) { fps = 30; shadow = 0; res = 0.5; viewDist = 0; } else { fps = 30; shadow = 1; res = 0.75; viewDist = 1; } }); }

Future load() async { try { final p = await SharedPreferences.getInstance(); int gi(String k, int d, int lo, int hi) { final v = p.getInt(k); return (v != null && v >= lo && v <= hi) ? v : d; } double gd(String k, double d, double lo, double hi) { final v = p.getDouble(k); return (v != null && v >= lo && v <= hi) ? v : d; } final l = p.getString('lang'); if (l != null && kLangNames.containsKey(l)) lang = l; final f = p.getInt('fps'); if (f != null && (f == 30 || f == 45 || f == 60)) fps = f; final r = p.getDouble('res'); if (r != null && (r == 0.5 || r == 0.75 || r == 1.0)) res = r; shadow = gi('shadow', shadow, 0, 2); viewDist = gi('view', viewDist, 0, 2); showFps = p.getBool('showfps') ?? showFps; haptic = p.getBool('haptic') ?? haptic; leftHanded = p.getBool('left') ?? leftHanded; atkMode = gi('atkmode', atkMode, 0, 2); atkSize = gi('atksize', atkSize, 0, 2); atkOpacity = gd('atkop', atkOpacity, 0.2, 1.0); joySize = gi('joysize', joySize, 0, 2); joyOpacity = gd('joyop', joyOpacity, 0.2, 1.0); joyFloating = p.getBool('joyfloat') ?? joyFloating; Offset go(String k, Offset d) => Offset(gd('${k}x', d.dx, 0.04, 0.96), gd('${k}y', d.dy, 0.04, 0.96)); joyPos = go('joy', joyPos); atkPos = go('atk', atkPos); runPos = go('run', runPos); } catch (_) { // corrupted or unavailable storage -> keep defaults } }

Future save() async { try { final p = await SharedPreferences.getInstance(); await p.setString('lang', lang); await p.setInt('fps', fps); await p.setDouble('res', res); await p.setInt('shadow', shadow); await p.setInt('view', viewDist); await p.setBool('showfps', showFps); await p.setBool('haptic', haptic); await p.setBool('left', leftHanded); await p.setInt('atkmode', atkMode); await p.setInt('atksize', atkSize); await p.setDouble('atkop', atkOpacity); await p.setInt('joysize', joySize); await p.setDouble('joyop', joyOpacity); await p.setBool('joyfloat', joyFloating); await p.setDouble('joyx', joyPos.dx); await p.setDouble('joyy', joyPos.dy); await p.setDouble('atkx', atkPos.dx); await p.setDouble('atky', atkPos.dy); await p.setDouble('runx', runPos.dx); await p.setDouble('runy', runPos.dy); } catch () {} } }

// ============================================================================ // 3. SPECIES + FOOD CHAIN (data only, separate from AI code) // ============================================================================ class Species { final String id, emoji; final double hp, atk, speed, size, neckX, neckY, head, tail; final bool carn; final Color c1, c2; final List w; // spawn weight per biome: grass, forest, desert, swamp const Species(this.id, this.emoji, this.hp, this.atk, this.speed, this.size, this.carn, this.c1, this.c2, this.neckX, this.neckY, this.head, this.tail, this.w); }

const List kSpecies = [ Species('trex', '🦖', 320.0, 46.0, 125.0, 44.0, true, Color(0xFF8A5A3C), Color(0xFF5E3B26), 0.15, 0.12, 0.95, 1.7, [1.0, 1.0, 2.0, 0.5]), Species('allo', '🦖', 230.0, 34.0, 140.0, 36.0, true, Color(0xFFB5651D), Color(0xFF7A3E12), 0.2, 0.18, 0.75, 1.7, [1.5, 2.0, 1.0, 0.5]), Species('raptor', '🦎', 90.0, 16.0, 200.0, 20.0, true, Color(0xFFD4883A), Color(0xFF8F4F1A), 0.2, 0.22, 0.65, 1.9, [2.0, 1.0, 3.0, 0.5]), Species('dilo', '🦎', 110.0, 14.0, 150.0, 22.0, true, Color(0xFF4C9E6E), Color(0xFF2F6B48), 0.2, 0.28, 0.6, 1.8, [1.0, 1.0, 1.0, 3.0]), Species('trice', '🦏', 260.0, 30.0, 105.0, 34.0, false, Color(0xFF7E8F5B), Color(0xFF55643A), 0.12, -0.02, 0.9, 1.3, [3.0, 2.0, 1.0, 1.0]), Species('stego', '🦕', 240.0, 28.0, 95.0, 32.0, false, Color(0xFF6A8CAF), Color(0xFF3F5E80), 0.05, -0.1, 0.45, 1.5, [2.0, 3.0, 1.0, 1.0]), Species('para', '🦕', 150.0, 8.0, 175.0, 28.0, false, Color(0xFFC9A04B), Color(0xFF8B6A22), 0.25, 0.35, 0.65, 1.5, [4.0, 2.0, 1.0, 2.0]), Species('brachio', '🦕', 480.0, 20.0, 70.0, 54.0, false, Color(0xFF8E9AAF), Color(0xFF5F6B82), 0.55, 1.1, 0.5, 1.6, [2.0, 2.0, 0.5, 3.0]), Species('compy', '🐤', 35.0, 5.0, 190.0, 13.0, false, Color(0xFF9CCC65), Color(0xFF689F38), 0.15, 0.2, 0.55, 1.6, [4.0, 3.0, 3.0, 3.0]), ];

// Who hunts whom (carnivores). const Map<String, Set> kPrey = { 'trex': {'allo', 'trice', 'stego', 'raptor', 'dilo', 'para', 'compy'}, 'allo': {'stego', 'raptor', 'dilo', 'para', 'compy'}, 'raptor': {'dilo', 'compy', 'para'}, 'dilo': {'compy'}, }; // Who fights back instead of fleeing (herbivore defenders). const Map<String, Set> kDefends = { 'trice': {'raptor', 'dilo', 'allo'}, 'stego': {'raptor', 'dilo', 'compy'}, 'brachio': {'raptor', 'dilo', 'compy'}, }; // Special rules: T-Rex can only bring down a Brachiosaurus when it is below // 50% HP. A Raptor pack (3+) can beat a T-Rex.

// ============================================================================ // 4. WORLD (infinite, generated in chunks) // ============================================================================ const double kChunk = 512.0;

const List kBiome = [ Color(0xFF6FAE3E), Color(0xFF4C8B35), Color(0xFFDDB96B), Color(0xFF5B7B4C), ]; final List kBiomeD = kBiome.map((c) => shade(c, -0.06).withValues(alpha: 0.55)).toList(); final List kBiomeL = kBiome.map((c) => shade(c, 0.06).withValues(alpha: 0.5)).toList();

class Obstacle { final int type; // 0 tree, 1 rock, 2 pond, 3 bush final double x, y, cr, rad, scale; final int variant; double readyAt = 0; // bush: game time when berries are back Obstacle(this.type, this.x, this.y, this.cr, this.rad, this.scale, this.variant); }

class Chunk { final int cx, cy, biome; final List obs = []; final List patches = []; // x,y,r final List tufts = []; // x,y Chunk(this.cx, this.cy, this.biome); }

class World { final int seed; World(this.seed); final Map<(int, int), Chunk> _chunks = {};

Chunk chunk(int cx, int cy) => _chunks.putIfAbsent((cx, cy), () => _gen(cx, cy));

void prune(double px, double py) { final pcx = (px / kChunk).floor(), pcy = (py / kChunk).floor(); _chunks.removeWhere((k, v) => (k.$1 - pcx).abs() > 5 || (k.$2 - pcy).abs() > 5); }

int _hash(int a, int b, int c) { int h = (a * 374761393) ^ (b * 668265263) ^ (c * 1274126177) ^ (seed * 2246822519); h = (h ^ (h >> 13)) * 1274126177; h = h ^ (h >> 16); return h & 0x7fffffff; }

double _lat(int x, int y, int salt) => (_hash(x, y, salt) % 1000) / 1000.0;

double _noise(double x, double y, int salt) { final x0 = x.floor(), y0 = y.floor(); double fx = x - x0, fy = y - y0; fx = fx * fx * (3 - 2 * fx); fy = fy * fy * (3 - 2 * fy); final a = _lat(x0, y0, salt), b = _lat(x0 + 1, y0, salt); final c = _lat(x0, y0 + 1, salt), d = _lat(x0 + 1, y0 + 1, salt); final top = a + (b - a) * fx, bot = c + (d - c) * fx; return top + (bot - top) * fy; }

int biomeAtChunk(int cx, int cy) { if (cx == 0 && cy == 0) return 0; final n1 = _noise(cx * 0.22, cy * 0.22, 11); final n2 = _noise(cx * 0.22 + 50, cy * 0.22 + 50, 23); if (n1 < 0.27) return 2; if (n2 > 0.7) return 3; if (n2 < 0.36) return 1; return 0; }

int biomeAt(double x, double y) => biomeAtChunk((x / kChunk).floor(), (y / kChunk).floor());

bool _place(Chunk ch, Random r, int type, double cr, double rad, double scale, int variant, double margin) { for (int t = 0; t < 8; t++) { final x = ch.cx * kChunk + margin + r.nextDouble() * (kChunk - 2 * margin); final y = ch.cy * kChunk + margin + r.nextDouble() * (kChunk - 2 * margin); if (x * x + y * y < 170 * 170) continue; // keep spawn point clear bool ok = true; for (final o in ch.obs) { final dx = o.x - x, dy = o.y - y; final m = o.cr + cr + 16; if (dx * dx + dy * dy < m * m) { ok = false; break; } } if (ok) { ch.obs.add(Obstacle(type, x, y, cr, rad, scale, variant)); return true; } } return false; }

Chunk _gen(int cx, int cy) { final b = biomeAtChunk(cx, cy); final ch = Chunk(cx, cy, b); final r = Random(_hash(cx, cy, 99)); if (r.nextDouble() < const [0.3, 0.15, 0.08, 0.9][b]) { final n = b == 3 ? 1 + r.nextInt(2) : 1; for (int i = 0; i < n; i++) { final rad = 48 + r.nextDouble() * 40; _place(ch, r, 2, rad * 0.8, rad, 1.0, 0, rad + 14); } } final trees = const [4, 10, 1, 4][b] + r.nextInt(2); for (int i = 0; i < trees; i++) { int v; if (b == 2) { v = 2; } else if (b == 3) { v = 3; } else { v = r.nextInt(2); } _place(ch, r, 0, 13, 20, 0.8 + r.nextDouble() * 0.5, v, 30); } final rocks = const [2, 3, 6, 1][b]; for (int i = 0; i < rocks; i++) { final rad = 14 + r.nextDouble() * 16; _place(ch, r, 1, rad * 0.9, rad, 1.0, r.nextInt(5), 30); } final bushes = const [4, 3, 1, 3][b]; for (int i = 0; i < bushes; i++) { _place(ch, r, 3, 12, 14, 1.0, 0, 30); } for (int i = 0; i < 4; i++) { ch.patches.addAll([ cx * kChunk + r.nextDouble() * kChunk, cy * kChunk + r.nextDouble() * kChunk, 40 + r.nextDouble() * 70, ]); } for (int i = 0; i < 28; i++) { ch.tufts.addAll([ cx * kChunk + r.nextDouble() * kChunk, cy * kChunk + r.nextDouble() * kChunk, ]); } return ch; } }

// ============================================================================ // 5. GAME ENTITIES + ENGINE // ============================================================================ class Dino { final Species sp; final bool isPlayer; final int variant; double x, y, vx = 0, vy = 0; double hp; final double maxHp; double hunger = 100, stamina = 100; bool faceRight = true, dead = false, removed = false; double anim = 0, cd = 0, atkAnim = 0, flash = 0, corpse = 0, food = 0; double thinkT = 0, stateT = 0, aggroT = 0, wanderAng = 0, eatT = 0; int state = 0; // 0 idle, 1 wander, 2 flee, 3 hunt/fight, 4 eat, 5 forage Dino? target, aggro; Obstacle? bush; late final Color col1 = tintC(sp.c1, variant); late final Color col2 = tintC(sp.c2, variant);

Dino(this.sp, this.x, this.y, {this.isPlayer = false, this.variant = 0}) : hp = sp.hp, maxHp = sp.hp;

double get r => sp.size * 0.45; }

enum Phase { playing, over }

class FloatText { double x, y, ttl = 0.9; final String text; final Color color; FloatText(this.x, this.y, this.text, this.color); }

class Particle { double x, y, vx, vy, ttl, life; final double size; final Color color; Particle(this.x, this.y, this.vx, this.vy, this.life, this.size, this.color) : ttl = life; }

class DinoGame extends ChangeNotifier { final Random rng = Random(); late final World world; late final Dino player; final List dinos = []; final List texts = []; final List parts = []; Phase phase = Phase.playing; bool paused = false; double time = 20, survived = 0, cx = 0, cy = 0; double spawnT = 0, pruneT = 0, fpsT = 0, rawFps = 0, hapticT = 0, dustT = 0; int fpsN = 0, kills = 0; Offset joy = Offset.zero; bool run = false, atkHeld = false, exhausted = false; double atkBuf = 0;

DinoGame(Species sp, int variant) { world = World(Random().nextInt(1 << 30)); player = Dino(sp, 0, 0, isPlayer: true, variant: variant); dinos.add(player); final n = (maxNpc * 0.6).round(); for (int i = 0; i < n; i++) { _spawnOne(true); } }

int get maxNpc => const [16, 26, 36][cfg.viewDist]; double get simR => const [800.0, 1100.0, 1400.0][cfg.viewDist];

void repaint() => notifyListeners();

// ---------- helpers ---------- double _dist(Dino a, Dino b) { final dx = a.x - b.x, dy = a.y - b.y; return sqrt(dx * dx + dy * dy); }

bool canPrey(Dino a, Dino b) { final set = kPrey[a.sp.id]; if (set == null) return false; if (set.contains(b.sp.id)) return true; return a.sp.id == 'trex' && b.sp.id == 'brachio' && b.hp < b.maxHp * 0.5; }

bool _defends(Dino a, Dino b) => kDefends[a.sp.id]?.contains(b.sp.id) ?? false;

double _reach(Dino a, Dino b) => a.sp.size * 0.95 + b.sp.size * 0.55 + 8;

int _packNear(Dino d) { int n = 0; for (final o in dinos) { if (!o.dead && o.sp.id == 'raptor' && _dist(o, d) < 170) n++; } return n; }

bool _blocked(double x, double y, double r) { final ccx = (x / kChunk).floor(), ccy = (y / kChunk).floor(); for (int i = -1; i <= 1; i++) { for (int j = -1; j <= 1; j++) { final ch = world.chunk(ccx + i, ccy + j); for (final o in ch.obs) { if (o.type == 3) continue; final m = r + o.cr; final dx = x - o.x, dy = y - o.y; if (dx * dx + dy * dy < m * m) return true; } } } for (final d in dinos) { if (d.dead) continue; final dx = x - d.x, dy = y - d.y; if (dx * dx + dy * dy < 45 * 45) return true; } return false; }

void _collide(Dino d) { final r = d.r; final ccx = (d.x / kChunk).floor(), ccy = (d.y / kChunk).floor(); for (int i = -1; i <= 1; i++) { for (int j = -1; j <= 1; j++) { final ch = world.chunk(ccx + i, ccy + j); for (final o in ch.obs) { if (o.type == 3) continue; final rr = r + o.cr; final dx = d.x - o.x, dy = d.y - o.y; final d2 = dx * dx + dy * dy; if (d2 < rr * rr) { final dist = sqrt(d2); if (dist < 0.001) { d.x = o.x + rr; } else { d.x = o.x + dx / dist * rr; d.y = o.y + dy / dist * rr; } } } } } }

Obstacle? _nearestBush(double x, double y, double maxD) { Obstacle? best; double bd = maxD; final ccx = (x / kChunk).floor(), ccy = (y / kChunk).floor(); for (int i = -1; i <= 1; i++) { for (int j = -1; j <= 1; j++) { for (final o in world.chunk(ccx + i, ccy + j).obs) { if (o.type != 3 || o.readyAt > time) continue; final dx = o.x - x, dy = o.y - y; final dd = sqrt(dx * dx + dy * dy); if (dd < bd)
