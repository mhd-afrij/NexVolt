import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethod {
  final String id;
  final String type;
  final String lastDigits;
  bool isSelected;
  final IconData icon;
  final Color color;
  final String cvv;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastDigits,
    this.isSelected = false,
    required this.icon,
    required this.color,
    required this.cvv,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'lastDigits': lastDigits,
      'isSelected': isSelected,
      'icon': icon.codePoint,
      'color': color.value,
      'cvv': cvv,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return PaymentMethod(
      id: id,
      type: map['type'] ?? 'Card',
      lastDigits: map['lastDigits'] ?? '',
      isSelected: map['isSelected'] ?? false,
      icon: IconData(map['icon'] as int? ?? Icons.credit_card.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] as int? ?? Colors.blue.value),
      cvv: map['cvv'] ?? '',
    );
  }

  factory PaymentMethod.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentMethod(
      id: doc.id,
      type: data['type'] ?? 'Card',
      lastDigits: data['lastDigits'] ?? '',
      isSelected: false,
      icon: Icons.credit_card, // Default icon for Firestore loaded cards
      color: Colors.blue, // Default color for Firestore loaded cards
      cvv: data['cvv'] ?? '',
    );
  }
}
