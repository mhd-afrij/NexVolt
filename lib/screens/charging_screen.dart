import 'package:flutter/material.dart';

class ChargingScreen extends StatefulWidget {
  const ChargingScreen({super.key});

  @override
  State<ChargingScreen> createState() => _ChargingScreenState();
}

class _ChargingScreenState extends State<ChargingScreen> {
  String energy = '6';
  String distance = '20';
  String time = '2';
  
  List<String> dates = ['01.07', '03.07', '05.07', '07.07', '09.07'];
  List<String> prices = ['918', '10', '814', '651', '901'];

  void _updateData() {
    setState(() {
      energy = (int.parse(energy) + 1).toString();
      distance = (int.parse(distance) + 5).toString();
      time = (double.parse(time) + 0.2).toStringAsFixed(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Charging Activity'), backgroundColor: Colors.green, actions: [
        IconButton(onPressed: _updateData, icon: Icon(Icons.refresh)),
      ]),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Jul 12 - Jul 19', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () {}, icon: Icon(Icons.calendar_today)),
            ]),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _buildStatCard('Energy', '$energy kWh', Icons.flash_on),
              _buildStatCard('Distance', '$distance km', Icons.route),
              _buildStatCard('Time', '$time hr', Icons.access_time),
            ]),
            SizedBox(height: 20),
            Text('Weekly Overview', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SizedBox(height: 150, child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: prices.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(children: [
                  Text(prices[index], style: TextStyle(fontSize: 12)),
                  SizedBox(height: 5),
                  Container(width: 40, height: double.parse(prices[index]) / 15, color: Colors.green),
                  SizedBox(height: 5),
                  Text(dates[index], style: TextStyle(fontSize: 12)),
                ]),
              ),
            )),
            SizedBox(height: 20),
            Wrap(spacing: 10, children: dates.map((date) => Chip(label: Text(date), backgroundColor: Colors.green.shade100)).toList()),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Last Charging Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: _updateData, child: Text('Update', style: TextStyle(color: Colors.green))),
            ]),
            _buildStationCard('3707 Tahone Way, Sunnyvale', '\$1.84/kWh', '31 mi', '1.25 hr'),
            SizedBox(height: 10),
            _buildStationCard('1280 El Camino Real', '\$2.15/kWh', '3.8 mi', '41 min'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(width: 100, padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: Colors.green), SizedBox(height: 5),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey)),
      ]),
    );
  }

  Widget _buildStationCard(String location, String price, String distance, String time) {
    return Card(margin: EdgeInsets.only(bottom: 10), child: ListTile(
      leading: Icon(Icons.ev_station, color: Colors.green),
      title: Text(location, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$price • $distance • $time'),
    ));
  }
}