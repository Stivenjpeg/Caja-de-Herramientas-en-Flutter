import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

void main() => runApp(const CajaApp());

const Color fondo = Color(0xFF101116);
const Color tarjeta = Color(0xFF1B1D26);
const Color turquesa = Color(0xFF35D6C4);

class CajaApp extends StatelessWidget {
  const CajaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Caja de Herramientas',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: fondo,
          colorScheme: ColorScheme.fromSeed(
              seedColor: turquesa, brightness: Brightness.dark),
          appBarTheme: const AppBarTheme(
              backgroundColor: fondo, foregroundColor: Colors.white),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: tarjeta,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
          ),
          cardTheme: CardThemeData(
              color: tarjeta,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18))),
        ),
        home: const InicioPage(),
      );
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});
  final opciones = const [
    ('Género por nombre', Icons.wc, GeneroPage()),
    ('Persona aleatoria', Icons.person_search, PersonaPage()),
    ('Universidades', Icons.school, UniversidadesPage()),
    ('Clima RD', Icons.cloud, ClimaPage()),
    ('Pokémon', Icons.catching_pokemon, PokemonPage()),
    ('Noticias WordPress', Icons.newspaper, NoticiasPage()),
    ('Acerca de', Icons.badge, AcercaPage()),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('CAJA DE HERRAMIENTAS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF203B43), Color(0xFF1B1D26)]),
                borderRadius: BorderRadius.circular(24)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.handyman, size: 54, color: turquesa),
              const SizedBox(height: 12),
              const Text('Una app, muchas herramientas.',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Consultas útiles conectadas a servicios web.',
                  style: TextStyle(color: Colors.grey.shade300)),
            ]),
          ),
          const SizedBox(height: 18),
          ...opciones.map((o) => Card(
                  child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: turquesa.withValues(alpha: 0.14),
                    child: Icon(o.$2, color: turquesa)),
                title: Text(o.$1,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => o.$3)),
              ))),
        ]),
      );
}

class GeneroPage extends StatefulWidget {
  const GeneroPage({super.key});
  @override
  State<GeneroPage> createState() => _GeneroPageState();
}

class _GeneroPageState extends State<GeneroPage> {
  final c = TextEditingController();
  bool cargando = false;
  Map<String, dynamic>? dato;
  String? error;
  Future<void> buscar() async {
    if (c.text.trim().isEmpty) return;
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      final r = await http
          .get(Uri.https('api.genderize.io', '/', {'name': c.text.trim()}));
      if (r.statusCode != 200) throw Exception('Servicio no disponible');
      setState(() => dato = jsonDecode(r.body) as Map<String, dynamic>);
    } catch (e) {
      setState(() => error = 'No se pudo consultar. Verifica tu conexión.');
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final masculino = dato?['gender'] == 'male';
    final color = dato?['gender'] == null
        ? turquesa
        : (masculino ? Colors.blue : Colors.pink);
    return Scaffold(
        appBar: AppBar(title: const Text('Predicción de género')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Escribe un nombre en cualquier idioma.',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
              controller: c,
              decoration: const InputDecoration(
                  labelText: 'Nombre', prefixIcon: Icon(Icons.person))),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: cargando ? null : buscar,
              child: cargando
                  ? const CircularProgressIndicator()
                  : const Text('Predecir')),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.redAccent)),
          if (dato != null)
            Container(
                margin: const EdgeInsets.only(top: 22),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color)),
                child: Column(children: [
                  Icon(masculino ? Icons.male : Icons.female,
                      size: 64, color: color),
                  Text(
                      dato!['gender'] == null
                          ? 'No se pudo determinar'
                          : masculino
                              ? 'Masculino'
                              : 'Femenino',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text(
                      'Probabilidad: ${dato!['probability'] ?? 'N/D'} · Muestras: ${dato!['count'] ?? 'N/D'}'),
                ]))
        ]));
  }
}

class PersonaPage extends StatefulWidget {
  const PersonaPage({super.key});
  @override
  State<PersonaPage> createState() => _PersonaPageState();
}

class _PersonaPageState extends State<PersonaPage> {
  Map<String, dynamic>? p;
  bool cargando = false;
  String? error;
  Future<void> cargar() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      final r =
          await http.get(Uri.parse('https://randomuser.me/api/?results=1'));
      if (r.statusCode != 200) throw Exception();
      final data = jsonDecode(r.body);
      setState(() => p = data['results'][0]);
    } catch (_) {
      setState(() => error = 'No se pudieron cargar los datos.');
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    cargar();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Persona aleatoria')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        if (cargando) const Center(child: CircularProgressIndicator()),
        if (error != null) Text(error!),
        if (p != null) ...[
          Center(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.network(p!['picture']['large'],
                      width: 150, height: 150, fit: BoxFit.cover))),
          const SizedBox(height: 18),
          Center(
              child: Text('${p!['name']['first']} ${p!['name']['last']}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          info(
              'Fecha de nacimiento',
              DateFormat('dd/MM/yyyy')
                  .format(DateTime.parse(p!['dob']['date']))),
          info('Edad', '${p!['dob']['age']} años'),
        ],
        const SizedBox(height: 16),
        FilledButton(
            onPressed: cargando ? null : cargar,
            child: const Text('Generar otra persona'))
      ]));
}

Widget info(String titulo, String valor) => Card(
    child: ListTile(
        title: Text(titulo, style: const TextStyle(color: turquesa)),
        subtitle: Text(valor, style: const TextStyle(fontSize: 17))));

class UniversidadesPage extends StatefulWidget {
  const UniversidadesPage({super.key});
  @override
  State<UniversidadesPage> createState() => _UniversidadesPageState();
}

class _UniversidadesPageState extends State<UniversidadesPage> {
  final c = TextEditingController(text: 'Dominican Republic');
  List<dynamic> lista = [];
  bool cargando = false;
  String? error;
  Future<void> buscar() async {
    if (c.text.trim().isEmpty) return;
    setState(() {
      cargando = true;
      error = null;
      lista = [];
    });
    try {
      final uri =
          Uri.https('adamix.net', '/proxy.php', {'country': c.text.trim()});
      final r = await http.get(uri);
      if (r.statusCode != 200) throw Exception();
      final d = jsonDecode(r.body);
      if (d is List) {
        lista = d;
      } else if (d is Map && d['universities'] is List) {
        lista = d['universities'];
      } else if (d is Map && d['data'] is List) {
        lista = d['data'];
      } else {
        throw Exception('Formato inesperado');
      }
    } catch (_) {
      error =
          'No se pudo obtener la lista. Revisa el nombre del país en inglés.';
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Universidades por país')),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                  child: TextField(
                      controller: c,
                      decoration: const InputDecoration(
                          labelText: 'Country in English'))),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: buscar,
                  icon: const Icon(Icons.search, color: turquesa))
            ])),
        if (cargando) const CircularProgressIndicator(),
        if (error != null)
          Padding(padding: const EdgeInsets.all(12), child: Text(error!)),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: lista.length,
                itemBuilder: (ctx, i) {
                  final u = lista[i] as Map;
                  final nombre = u['name'] ?? u['university'] ?? 'Universidad';
                  final dominio = u['domains'] is List
                      ? (u['domains'] as List).join(', ')
                      : (u['domain'] ?? 'No disponible');
                  final paginas = u['web_pages'];
                  final web = paginas is List && paginas.isNotEmpty
                      ? paginas.first
                      : (u['web_page'] ?? u['website']);
                  return Card(
                      child: ListTile(
                          title: Text('$nombre'),
                          subtitle: Text(
                              'Dominio: $dominio\nWeb: ${web ?? 'No disponible'}'),
                          isThreeLine: true,
                          trailing: IconButton(
                              icon: const Icon(Icons.open_in_new,
                                  color: turquesa),
                              onPressed: () => abrir(web?.toString()))));
                }))
      ]));
}

class ClimaPage extends StatefulWidget {
  const ClimaPage({super.key});
  @override
  State<ClimaPage> createState() => _ClimaPageState();
}

class _ClimaPageState extends State<ClimaPage> {
  Map<String, dynamic>? clima;
  bool cargando = false;
  String? error;
  Future<void> cargar() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      // Coordenadas aproximadas de Santo Domingo, República Dominicana.
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '18.4861',
        'longitude': '-69.9312',
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'America/Santo_Domingo',
        'forecast_days': '1'
      });
      final r = await http.get(uri);
      if (r.statusCode != 200) throw Exception();
      setState(() => clima = jsonDecode(r.body));
    } catch (_) {
      error = 'No se pudo consultar el clima. Intenta de nuevo.';
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    cargar();
  }

  String descripcion(int code) {
    if (code == 0) return 'Despejado';
    if ([1, 2, 3].contains(code)) return 'Parcialmente nublado';
    if ([45, 48].contains(code)) return 'Niebla';
    if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) return 'Lluvia';
    if ([95, 96, 99].contains(code)) return 'Tormenta';
    return 'Condición variable';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Clima · República Dominicana')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        if (cargando) const Center(child: CircularProgressIndicator()),
        if (error != null) Text(error!),
        if (clima != null) ...[
          Text(
              'Santo Domingo · ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
              style: const TextStyle(color: turquesa)),
          const SizedBox(height: 20),
          Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF164B60), tarjeta]),
                  borderRadius: BorderRadius.circular(24)),
              child: Column(children: [
                const Icon(Icons.cloud_queue, size: 70, color: turquesa),
                Text('${clima!['current']['temperature_2m']} °C',
                    style: const TextStyle(
                        fontSize: 42, fontWeight: FontWeight.bold)),
                Text(descripcion(clima!['current']['weather_code']),
                    style: const TextStyle(fontSize: 20)),
                Text(
                    'Sensación térmica: ${clima!['current']['apparent_temperature']} °C'),
              ])),
          const SizedBox(height: 12),
          info('Máxima del día',
              '${clima!['daily']['temperature_2m_max'][0]} °C'),
          info('Mínima del día',
              '${clima!['daily']['temperature_2m_min'][0]} °C'),
          info('Probabilidad máxima de lluvia',
              '${clima!['daily']['precipitation_probability_max'][0]} %'),
          info('Humedad', '${clima!['current']['relative_humidity_2m']} %'),
          info('Viento', '${clima!['current']['wind_speed_10m']} km/h'),
        ],
        FilledButton(
            onPressed: cargando ? null : cargar,
            child: const Text('Actualizar clima'))
      ]));
}

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});
  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final c = TextEditingController(text: 'pikachu');
  Map<String, dynamic>? p;
  bool cargando = false;
  String? error;
  final audio = AudioPlayer();
  Future<void> buscar() async {
    if (c.text.trim().isEmpty) return;
    setState(() {
      cargando = true;
      error = null;
      p = null;
    });
    try {
      final r = await http.get(Uri.https(
          'pokeapi.co', '/api/v2/pokemon/${c.text.trim().toLowerCase()}'));
      if (r.statusCode != 200) throw Exception();
      setState(() => p = jsonDecode(r.body));
    } catch (_) {
      setState(() => error =
          'Pokémon no encontrado. Escribe el nombre en inglés o su número.');
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  void dispose() {
    audio.dispose();
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sprites = p?['sprites']?['other']?['official-artwork']
            ?['front_default'] ??
        p?['sprites']?['front_default'];
    final cries = p?['cries'];
    return Scaffold(
        appBar: AppBar(title: const Text('Pokédex')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Row(children: [
            Expanded(
                child: TextField(
                    controller: c,
                    decoration: const InputDecoration(
                        labelText: 'Nombre del Pokémon'))),
            IconButton(
                onPressed: buscar,
                icon: const Icon(Icons.search, color: turquesa))
          ]),
          if (cargando) const Center(child: CircularProgressIndicator()),
          if (error != null) Text(error!),
          if (p != null) ...[
            if (sprites != null)
              Center(child: Image.network(sprites, width: 210, height: 210)),
            Center(
                child: Text((p!['name'] as String).toUpperCase(),
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold))),
            info('Experiencia base', '${p!['base_experience']} XP'),
            const SizedBox(height: 8),
            const Text('Habilidades',
                style: TextStyle(
                    color: turquesa,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            ...((p!['abilities'] as List).map((a) => ListTile(
                leading: const Icon(Icons.bolt, color: turquesa),
                title: Text(a['ability']['name']),
                subtitle: Text(a['is_hidden']
                    ? 'Habilidad oculta'
                    : 'Habilidad normal')))),
            if (cries?['latest'] != null)
              FilledButton.icon(
                  onPressed: () => audio.play(UrlSource(cries['latest'])),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Reproducir sonido (latest)'))
            else
              const Text('Este Pokémon no tiene sonido latest disponible.')
          ]
        ]));
  }
}

class NoticiasPage extends StatefulWidget {
  const NoticiasPage({super.key});
  @override
  State<NoticiasPage> createState() => _NoticiasPageState();
}

class _NoticiasPageState extends State<NoticiasPage> {
  List<dynamic> posts = [];
  bool cargando = false;
  String? error;
  // API pública REST de Kinsta: últimas publicaciones del blog.
  static const api = 'https://kinsta.com/wp-json/wp/v2/posts?per_page=3&_embed';
  Future<void> cargar() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      final r = await http.get(Uri.parse(api));
      if (r.statusCode != 200) throw Exception();
      setState(() => posts = jsonDecode(r.body));
    } catch (_) {
      error =
          'No se pudieron cargar las noticias. El sitio puede limitar solicitudes desde la app.';
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    cargar();
  }

  String limpiar(String s) => s
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&#8217;', "'")
      .replaceAll('&nbsp;', ' ');
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Noticias de Kinsta')),
      body: RefreshIndicator(
          onRefresh: cargar,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Center(
                child: Image.network(
                    'https://kinsta.com/wp-content/uploads/2021/03/kinsta-logo.png',
                    height: 46,
                    errorBuilder: (_, __, ___) => const Text('KINSTA',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: turquesa)))),
            const SizedBox(height: 16),
            if (cargando) const Center(child: CircularProgressIndicator()),
            if (error != null) Text(error!),
            ...posts.map((post) {
              final title = limpiar(post['title']?['rendered'] ?? 'Sin título');
              final excerpt = limpiar(post['excerpt']?['rendered'] ?? '');
              final link = post['link']?.toString();
              final media = post['_embedded']?['wp:featuredmedia'];
              final img = media is List && media.isNotEmpty
                  ? media[0]['source_url']
                  : null;
              return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (img != null)
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(img,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox.shrink())),
                            const SizedBox(height: 10),
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(excerpt,
                                maxLines: 4, overflow: TextOverflow.ellipsis),
                            Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                    onPressed: () => abrir(link),
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Visitar noticia')))
                          ])));
            })
          ])));
}

class AcercaPage extends StatelessWidget {
  const AcercaPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(padding: const EdgeInsets.all(22), children: [
        Center(
            child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: turquesa),
                child: const CircleAvatar(
                    radius: 78,
                    backgroundImage: AssetImage('assets/foto-perfil.jpg')))),
        const SizedBox(height: 20),
        const Center(
            child: Text('Keylin Steven Rosario Mordan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        const Center(
            child: Text('Estudiante de Desarrollo de Software · ITLA')),
        const SizedBox(height: 20),
        info('Matrícula', '20241613'),
        info('Correo', '20241613@itla.edu.do'),
        info('Teléfono', '829-343-3620'),
        Card(
            child: ListTile(
                leading: const Icon(Icons.code, color: turquesa),
                title: const Text('GitHub'),
                subtitle: const Text('github.com/Stivenjpeg'),
                onTap: () => abrir('https://github.com/Stivenjpeg'))),
        const SizedBox(height: 12),
        const Text(
            'Disponible para oportunidades de aprendizaje y desarrollo de software.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70))
      ]));
}

Future<void> abrir(String? url) async {
  if (url == null || url.isEmpty || url == 'null') return;
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
