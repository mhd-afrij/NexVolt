import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/features/auth/login_page.dart';

class VechicleDetailsShow extends StatelessWidget {
  const VechicleDetailsShow({super.key});

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF50C878);
    const electricBlue = Color(0xFF0077FF);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("No user logged in")));
    }

    final vehiclesStream = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("vehicles")
        .orderBy("createdAt", descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [emeraldGreen, electricBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),

            // 🔝 Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    "Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),

                  // Logout Button
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Welcome Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Welcome, ${user.phoneNumber}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🤍 White Container
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: vehiclesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No vehicles found"));
                    }

                    var vehicles = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        var vehicle = vehicles[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_car,
                                color: Colors.green,
                                size: 35,
                              ),
                              const SizedBox(width: 15),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${vehicle['vehicleType']} - ${vehicle['model']}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text("Company: ${vehicle['company']}"),
                                    Text("Battery: ${vehicle['battery']}"),
                                    Text("Connector: ${vehicle['connector']}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
