import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'screens/booking/booking_selection_screen.dart';

void main() {
  runApp(const NexVoltApp());
}

class NexVoltApp extends StatelessWidget {
  const NexVoltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexVolt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emeraldGreen,
          primary: AppColors.emeraldGreen,
        ),
        fontFamily: 'Roboto',
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Home',
    'Planner',
    'Garage',
    'Booking',
    'Account',
  ];

  static final List<Widget> _pages = [
    const HomeTab(),
    const PlannerTab(),
    const GarageTab(),
    const BookingTab(),
    const AccountTab(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.garage_outlined),
            selectedIcon: Icon(Icons.garage),
            label: 'Garage',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online_outlined),
            selectedIcon: Icon(Icons.book_online),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.emeraldGreen.withAlpha(31),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.electric_bolt,
                    size: 56,
                    color: AppColors.emeraldGreen,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Welcome to NexVolt',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap below to start your next charging booking.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const _SectionTitle(title: 'Quick Actions'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookingSelectionScreen(
                    stationId: 'station_001',
                    stationName: 'NexVolt Charging Hub',
                    stationAddress: '123 Electric Avenue, Tech Park',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emeraldGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Start Booking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlannerTab extends StatelessWidget {
  const PlannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Plan your next trip, review charging history, and set a route for a safer journey.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class GarageTab extends StatelessWidget {
  const GarageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Your vehicle garage will appear here with charging readiness and maintenance status.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class BookingTab extends StatelessWidget {
  const BookingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EKW Charging App',
      theme: ThemeData(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 4; // Account tab selected by default

  final List<Widget> _screens = [
    HomeScreen(),
    PlannerScreen(),
    GarageScreen(),
    BookingScreen(),
    AccountScreen(), // Account tab - ithula inner navigation irukum
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.local_parking), label: 'Garage'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

// Simple placeholder screens for other tabs
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home'), backgroundColor: Colors.green),
      body: Center(child: Text('Home Screen - Coming Soon')),
    );
  }
}

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking'), backgroundColor: Colors.green),
      body: Center(child: Text('Booking Screen - Coming Soon')),
    );
  }
}