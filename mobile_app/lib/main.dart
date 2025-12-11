import 'package:flutter/material.dart';
import 'features/events/screens/event_home_screen.dart';
import 'features/chat/screens/chat_home_screen.dart';
import 'features/games/screens/game_home_screen.dart';
import 'features/auth/screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _autoLoginDemo();
  }

  Future<void> _autoLoginDemo() async {
    const demoEmail = 'demo@example.com';
    const demoPassword = 'demo123';
    const demoName = 'Demo Kullanıcı';

    // Önce direkt giriş yapmayı dene
    var loginResult = await _authService.login(demoEmail, demoPassword);
    
    // Giriş başarısız olursa kayıt olmayı dene
    if (loginResult['success'] != true) {
      await _authService.register(demoEmail, demoPassword, demoName);
      loginResult = await _authService.login(demoEmail, demoPassword);
    }
    
    setState(() {
      _isLoading = false;
    });

    // Giriş başarılı olsa da olmasa da ana ekrana git
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Sayfalar Listesi (Sırayla)
  static const List<Widget> _pages = <Widget>[
    EventHomeScreen(), // 0: Etkinlik
    ChatHomeScreen(), // 1: Sohbet
    GameHomeScreen(), // 2: Oyun
    ProfileScreen(), // 3: Profil (YENİ!)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social App'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages[_selectedIndex], // Seçili sayfayı göster
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Etkinlik',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Sohbet',
          ),
          NavigationDestination(
            icon: Icon(Icons.videogame_asset_outlined),
            selectedIcon: Icon(Icons.videogame_asset),
            label: 'Oyun',
          ),
          // YENİ BUTON BURADA:
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
