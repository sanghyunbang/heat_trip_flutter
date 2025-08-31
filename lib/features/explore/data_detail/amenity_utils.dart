/// amenity_utils.dart
import 'package:flutter/material.dart';

IconData amenityIcon(String amenity) {
  switch (amenity) {
    case 'wifi':
      return Icons.wifi;
    case 'parking':
      return Icons.local_parking;
    case 'card':
      return Icons.credit_card;
    case 'accessible':
      return Icons.accessible;
    default:
      return Icons.check_circle_outline;
  }
}

String amenityLabel(String amenity) {
  switch (amenity) {
    case 'wifi':
      return 'Wi-Fi';
    case 'parking':
      return '주차';
    case 'card':
      return '카드결제';
    case 'accessible':
      return '접근성';
    default:
      return amenity;
  }
}
