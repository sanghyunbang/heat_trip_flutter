/// field_descriptor.dart
/// 타입별 상세 항목 스키마 정의에 사용하는 구조체 + 포맷터 유틸
import 'package:flutter/material.dart';

typedef ValueFormatter = String Function(dynamic);

class FieldDescriptor {
  final String key; // detailRaw의 키
  final String label; // UI 라벨
  final IconData icon;
  final ValueFormatter? format;
  const FieldDescriptor({
    required this.key,
    required this.label,
    required this.icon,
    this.format,
  });
}

// HTML 태그 제거(간단)
String stripHtml(dynamic v) =>
    v == null ? '' : v.toString().replaceAll(RegExp(r'<[^>]*>'), ' ').trim();

// 가능/없음/Y/N/0/1 통일
String yn(dynamic v) {
  final s = v?.toString().trim().toLowerCase() ?? '';
  if (s == '1' || s == 'y' || s == 'yes' || s == '가능') return '가능';
  if (s == '0' || s == 'n' || s == 'no' || s == '없음') return '없음';
  return v?.toString() ?? '';
}
