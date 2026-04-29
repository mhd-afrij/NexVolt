import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User Data
  String userName = "David Smith";
  String userEmail = "david_smith1985@gmail.com";
  String userPhone = "+1 234 567 8900";
  
  // Subscription
  String currentPlan = "Premium";
  List<String> plans = ["Free", "Premium", "Pro"];
  
  // Vehicles
  List<Map<String, dynamic>> vehicles = [
    {"name": "Tenda Model X", "battery": 77, "plate": "ABC-1234"},
    {"name": "Nissan Leaf", "battery": 91, "plate": "XYZ-5678"},
  ];
  
  // Payment Methods
  List<Map<String, dynamic>> paymentMethods = [
    {"type": "Mastercard", "last4": "8295", "isDefault": true},
    {"type": "Visa", "last4": "9425", "isDefault": false},
  ];
  
  // Favorites
  List<String> favorites = [
    "3707 Tahone Way, Sunnyvale",
    "1280 El Camino Real",
  ];
  
  // Settings
  bool notificationsEnabled = true;
  String language = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(),
            SizedBox(height: 20),
            
            // My Vehicles Section
            _buildSectionHeader(Icons.directions_car, "My Vehicles", onAdd: () => _addVehicle()),
            SizedBox(height: 8),
            ...vehicles.map((vehicle) => _buildVehicleCard(vehicle)),
            SizedBox(height: 20),
            
            // Subscription Section
            _buildSectionHeader(Icons.star, "Subscription", onEdit: () => _showSubscriptionDialog()),
            SizedBox(height: 8),
            _buildSubscriptionCard(),
            SizedBox(height: 20),
            
            // Payment Methods Section
            _buildSectionHeader(Icons.credit_card, "Payment Methods", onAdd: () => _addPaymentMethod()),
            SizedBox(height: 8),
            ...paymentMethods.map((method) => _buildPaymentCard(method)),
            SizedBox(height: 20),
            
            // Charging History (Quick View)
            _buildSectionHeader(Icons.history, "Recent Charging", onViewAll: () => _goToCharging()),
            SizedBox(height: 8),
            _buildChargingHistoryPreview(),
            SizedBox(height: 20),
            
            // Favorites Section
            _buildSectionHeader(Icons.favorite, "Favorites", onViewAll: () => _showFavoritesDialog()),
            SizedBox(height: 8),
            ...favorites.map((station) => _buildFavoriteItem(station)),
            SizedBox(height: 20),
            
            // Settings Section (Security removed)
            _buildSectionHeader(Icons.settings, "Settings"),
            SizedBox(height: 8),
            _buildSettingsTile(Icons.notifications, "Notifications", notificationsEnabled ? "On" : "Off", onTap: () => _toggleNotifications()),
            _buildSettingsTile(Icons.language, "Language", language, onTap: () => _showLanguageDialog()),
            SizedBox(height: 20),
            
            // Help & Support
            _buildMenuTile(Icons.help, "Help & Support", () => _showHelpDialog()),
            
            // Logout
            _buildMenuTile(Icons.logout, "Logout", () => _showLogoutDialog(), isLogout: true),
          ],
        ),
      ),
    );
  }

  // Profile Header Widget
  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(radius: 45, backgroundColor: Colors.green, child: Icon(Icons.person, size: 45, color: Colors.white)),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(userEmail, style: TextStyle(color: Colors.grey)),
              Text(userPhone, style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        IconButton(onPressed: _showEditProfileDialog, icon: Icon(Icons.edit, color: Colors.green)),
      ],
    );
  }

  // Section Header with optional buttons
  Widget _buildSectionHeader(IconData icon, String title, {VoidCallback? onAdd, VoidCallback? onEdit, VoidCallback? onViewAll}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Spacer(),
        if (onAdd != null) IconButton(icon: Icon(Icons.add_circle, size: 20), onPressed: onAdd),
        if (onEdit != null) IconButton(icon: Icon(Icons.edit, size: 20), onPressed: onEdit),
        if (onViewAll != null) TextButton(onPressed: onViewAll, child: Text("View All", style: TextStyle(color: Colors.green))),
      ],
    );
  }

  // Vehicle Card
  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.electric_car, color: Colors.green),
        title: Text(vehicle["name"], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${vehicle["plate"]} • Battery: ${vehicle["battery"]}%"),
        trailing: SizedBox(width: 60, child: LinearProgressIndicator(value: vehicle["battery"] / 100, color: Colors.green)),
      ),
    );
  }

  // Subscription Card
  Widget _buildSubscriptionCard() {
    Color planColor = currentPlan == "Free" ? Colors.grey : (currentPlan == "Premium" ? Colors.blue : Colors.orange);
    return Card(
      child: ListTile(
        leading: Icon(Icons.stars, color: planColor),
        title: Text("$currentPlan Plan", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(currentPlan == "Free" ? "Basic features only" : (currentPlan == "Premium" ? "Real-time availability, Ad-free" : "Priority charging, Faster booking")),
        trailing: ElevatedButton(
          onPressed: _showSubscriptionDialog,
          style: ElevatedButton.styleFrom(backgroundColor: planColor),
          child: Text("Upgrade", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // Payment Card
  Widget _buildPaymentCard(Map<String, dynamic> method) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.credit_card, color: Colors.green),
        title: Text("${method["type"]} •••• ${method["last4"]}"),
        trailing: method["isDefault"] ? Chip(label: Text("Default"), backgroundColor: Colors.green.shade100) : IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () => _showPaymentOptions(method),
        ),
      ),
    );
  }

  // Charging History Preview
  Widget _buildChargingHistoryPreview() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.bolt, color: Colors.green),
        title: Text("Last Charge: 6 kWh • 20 km • 2 hr"),
        subtitle: Text("Jul 12, 2024 • 3707 Tahone Way"),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _goToCharging,
      ),
    );
  }

  // Favorite Item
  Widget _buildFavoriteItem(String station) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.favorite, color: Colors.red),
        title: Text(station),
        trailing: IconButton(icon: Icon(Icons.delete_outline), onPressed: () => _removeFavorite(station)),
      ),
    );
  }

  // Settings Tile
  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Menu Tile
  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.green),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : null)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // ==================== DIALOGS ====================
  
  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(text: userName);
    TextEditingController emailController = TextEditingController(text: userEmail);
    TextEditingController phoneController = TextEditingController(text: userPhone);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userName = nameController.text;
                userEmail = emailController.text;
                userPhone = phoneController.text;
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog() {
    String? selectedPlan = currentPlan;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Plan"),
        content: StatefulBuilder(
          builder: (context, setState) => RadioGroup<String>(
            groupValue: selectedPlan,
            onChanged: (value) {
              setState(() {
                selectedPlan = value;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: plans.map((plan) {
                return RadioListTile<String>(
                  title: Text(plan),
                  subtitle: Text(plan == "Free" ? "Basic features" : (plan == "Premium" ? "\$9.99/month" : "\$19.99/month")),
                  value: plan,
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() { currentPlan = selectedPlan!; });
              Navigator.pop(context);
              _showSnackBar("Plan upgraded to $currentPlan!");
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _showFavoritesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Favorite Stations"),
        content: SizedBox(width: double.maxFinite, child: Column(
          mainAxisSize: MainAxisSize.min,
          children: favorites.map((station) => ListTile(title: Text(station))).toList(),
        )),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Help & Support"),
        content: Text("Contact us: support@ekw.com\nPhone: 1-800-EKW-HELP"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(onPressed: () => _showSnackBar("Logged out!"), child: Text("Logout")),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Language"),
        content: StatefulBuilder(
          builder: (context, setState) => RadioGroup<String>(
            groupValue: language,
            onChanged: (value) {
              if (value != null) {
                setState(() { language = value; });
                Navigator.pop(context);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ["English", "Tamil", "Sinhala"].map((lang) {
                return RadioListTile<String>(
                  title: Text(lang),
                  value: lang,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentOptions(Map<String, dynamic> method) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: Icon(Icons.star), title: Text("Set as Default"), onTap: () {
            setState(() {
              for (var m in paymentMethods) { m["isDefault"] = false; }
              method["isDefault"] = true;
            });
            Navigator.pop(context);
          }),
          ListTile(leading: Icon(Icons.delete), title: Text("Remove Card"), onTap: () {
            setState(() { paymentMethods.remove(method); });
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  void _addVehicle() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Vehicle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: "Model")),
            TextField(decoration: InputDecoration(labelText: "Plate Number")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Add")),
        ],
      ),
    );
  }

  void _addPaymentMethod() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Card"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: "Card Number")),
            TextField(decoration: InputDecoration(labelText: "Expiry")),
            TextField(decoration: InputDecoration(labelText: "CVV")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Add")),
        ],
      ),
    );
  }

  void _removeFavorite(String station) {
    setState(() { favorites.remove(station); });
    _showSnackBar("Removed from favorites");
  }

  void _toggleNotifications() {
    setState(() { notificationsEnabled = !notificationsEnabled; });
    _showSnackBar("Notifications: ${notificationsEnabled ? "ON" : "OFF"}");
  }

  void _goToCharging() {
    // Navigate to Charging tab
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}