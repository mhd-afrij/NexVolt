import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String userName; // 👈 pass logged user name

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    // 🔥 Navigation logic
    switch (index) {
      case 0:
        print("Home Clicked");
        break;
      case 1:
        print("Planner Clicked");
        break;
      case 2:
        print("Garage Clicked");
        break;
      case 3:
        print("Booking Clicked");
        break;
      case 4:
        print("Account Clicked");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      // 🔻 BODY
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔝 TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Good Morning, ${widget.userName}!",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: const [
                      Icon(Icons.tune),
                      SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🚗 VEHICLE CARD
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Tesla Model X",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("AAA 1111"),
                          SizedBox(height: 10),
                          Text("Battery : 77%"),
                        ],
                      ),
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey[300],
                      child: const Center(child: Text("Image")),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 🌤 WEATHER + STATION
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("New York, USA"),
                          SizedBox(height: 10),
                          Text(
                            "81°F",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Day 83°F - Night 76°F"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Favorite Station"),
                          SizedBox(height: 10),
                          Text("Tesla Station"),
                          Text("Hanover St.24"),
                          SizedBox(height: 5),
                          Text("1.2 Miles"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // 🗺 MAP SECTION
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(child: Text("Maps")),
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔻 BOTTOM NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.route), label: "Planner"),
          BottomNavigationBarItem(icon: Icon(Icons.garage), label: "Garage"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Booking",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}
