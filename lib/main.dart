import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/perfil.dart';
import 'models/avaliacao.dart';
import 'screens/home_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/nova_avaliacao_screen.dart';
import 'screens/historico_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);

  runApp(EvoFitApp(storage: storage));
}

class EvoFitApp extends StatelessWidget {
  final StorageService storage;

  const EvoFitApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EvoFit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
          surface: const Color(0xFF151B22),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF151B22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2196F3)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF151B22),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF10151B),
          indicatorColor: Color(0x332196F3),
        ),
      ),
      home: AppShell(storage: storage),
    );
  }
}

class AppShell extends StatefulWidget {
  final StorageService storage;

  const AppShell({super.key, required this.storage});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  Perfil? _perfil;
  List<Avaliacao> _avaliacoes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final perfil = await widget.storage.carregarPerfil();
    final avaliacoes = await widget.storage.carregarAvaliacoes();
    if (!mounted) return;
    setState(() {
      _perfil = perfil;
      _avaliacoes = avaliacoes;
    });
  }

  Future<void> _openNovaAvaliacao() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NovaAvaliacaoScreen(storage: widget.storage),
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _openPerfil() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PerfilScreen(
          storage: widget.storage,
          perfilInicial: _perfil,
        ),
      ),
    );
    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        perfil: _perfil,
        avaliacoes: _avaliacoes,
        onNovaAvaliacao: _openNovaAvaliacao,
        onOpenPerfil: _openPerfil,
      ),
      HistoricoScreen(
        storage: widget.storage,
        perfil: _perfil,
        avaliacoes: _avaliacoes,
        onChanged: _load,
      ),
      PerfilScreen(
        storage: widget.storage,
        perfilInicial: _perfil,
        embedded: true,
        onSaved: _load,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) =>
            setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Evolução',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
