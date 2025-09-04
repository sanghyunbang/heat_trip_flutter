// lib/features/profile/presentation/profile_edit_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/profile/data/dto/update_profile_request.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── 컨트롤러 ──
  final _nicknameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(); // 선택 입력

  // 성별: FEMALE / MALE / OTHER (기본/모름: OTHER)
  String _gender = 'OTHER';
  String? _avatarUrl;
  bool _saving = false;

  // 서버 연동
  final _authRepo = AuthRepositoryImpl();
  bool _loadingProfile = true;
  String? _loadError;

  // 여행 타입(단일 선택)
  static const List<String> _travelTypeOptions = [
    '힐링','액티비티','문화·예술','미식','자연','도시여행','바다','산·트레킹'
  ];
  String? _selectedTravelType;

  // 디자인 색상(성별/여행타입만 사용)
  static const Color kPrimary = Color(0xFFEB9C64);
  static const Color kStroke  = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _loadFromServer();
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFromServer() async {
    setState(() {
      _loadingProfile = true;
      _loadError = null;
    });

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        setState(() {
          _loadError = '로그인이 필요합니다.';
          _loadingProfile = false;
        });
        return;
      }

      final data = await _authRepo.getMyProfile(token);
      // ignore: avoid_print
      print('[ProfileEdit] raw data: $data');

      if (data == null) {
        setState(() {
          _loadError = '프로필 정보를 불러오지 못했습니다.';
          _loadingProfile = false;
        });
        return;
      }

      // ===== 매핑 =====
      _nicknameCtrl.text = (data['nickname'] ?? '').toString();
      _nameCtrl.text     = (data['name'] ?? '').toString();
      _emailCtrl.text    = (data['email'] ?? '').toString();

      // FEMALE / MALE / OTHER 로 정규화
      final gRaw = (data['gender'] ?? '').toString().toUpperCase().trim();
      if (gRaw == 'FEMALE' || gRaw == 'F') {
        _gender = 'FEMALE';
      } else if (gRaw == 'MALE' || gRaw == 'M') {
        _gender = 'MALE';
      } else {
        _gender = 'OTHER';
      }

      // 이미지 URL 키 대응 (imageUrl / image_url / avatarUrl)
      final img = (data['imageUrl'] ?? data['image_url'] ?? data['avatarUrl'])?.toString().trim();
      _avatarUrl = (img != null && img.isNotEmpty) ? img : null;
      print('[ProfileEdit] parsed avatarUrl: $_avatarUrl');

      // 나이(선택)
      final dynamic age = data['age'];
      if (age != null && age.toString().isNotEmpty) {
        _ageCtrl.text = age.toString();
      } else if (data['birthDate'] != null) {
        final dt = DateTime.tryParse(data['birthDate'].toString());
        if (dt != null) _ageCtrl.text = _computeAge(dt).toString();
      }

      // 여행 타입 - 단일(선택)
      // ── 여행 타입(단일) ──
      final single = (data['travelType'] ?? '').toString().trim();
      _selectedTravelType = _travelTypeOptions.contains(single) ? single : null;

      setState(() => _loadingProfile = false);
    } catch (e) {
      setState(() {
        _loadError = '불러오는 중 오류가 발생했습니다: $e';
        _loadingProfile = false;
      });
    }
  }

  int _computeAge(DateTime birth) {
    final now = DateTime.now();
    int age = now.year - birth.year;
    final hadBirthday =
        (now.month > birth.month) ||
            (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthday) age--;
    return age.clamp(0, 150);
  }

  void _openAvatarSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('아바타 선택(데모)', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _OutlinedPillButton(label: '기본', onTap: () { setState(() => _avatarUrl = null); Navigator.pop(context); }),
                    _OutlinedPillButton(label: '샘플1', onTap: () { setState(() => _avatarUrl = 'https://picsum.photos/seed/heat1/200'); Navigator.pop(context); }),
                    _OutlinedPillButton(label: '샘플2', onTap: () { setState(() => _avatarUrl = 'https://picsum.photos/seed/heat2/200'); Navigator.pop(context); }),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('※ 실제 업로드/카메라 연동 없이 화면만 확인하는 데모입니다.',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    // 닉네임/이름/이메일 필수만 검증. 나이/여행타입은 선택
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final token = await TokenStorage.getToken();
    if (token == null) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final int? age = _ageCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_ageCtrl.text.trim());

    final req = UpdateProfileRequest(
      name: _nameCtrl.text.trim(),
      nickname: _nicknameCtrl.text.trim(),
      gender: _gender,                     // "FEMALE" | "MALE" | "OTHER"
      age: age,                            // nullable
      imageUrl: _avatarUrl,                // nullable
      travelType: _selectedTravelType,     // nullable
    );

    // 디버그: 실제로 뭐가 나가는지 확인
    print('[PUT /auth/me] body: ${jsonEncode(req.toJson())}');

    final ok = await _authRepo.updateMyProfile(token, req);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 저장되었습니다.')),
      );
      Navigator.of(context).pop(); // 수정 후 이전 화면으로
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
      ),
      body: SafeArea(
        child: _loadError != null
            ? Center(child: Text(_loadError!, style: const TextStyle(color: Colors.black54)))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ── 아바타 ──
                _AvatarPreview(
                  avatarUrl: _avatarUrl,
                  onChange: _openAvatarSheet,
                ),
                const SizedBox(height: 24),

                // ── 닉네임 ──
                TextFormField(
                  controller: _nicknameCtrl,
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 20,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return '닉네임을 입력하세요';
                    if (s.length < 2) return '2자 이상 입력하세요';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── 이름 ──
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return '이름을 입력하세요';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── 이메일 ──
                TextFormField(
                  controller: _emailCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return '이메일을 입력하세요';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s)) {
                      return '이메일 형식이 올바르지 않습니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── 성별: 아이콘 칩 ──
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('성별', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800])),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _IconChoice(
                      label: '여성',
                      icon: Icons.female,
                      selected: _gender == 'FEMALE',
                      onTap: () => setState(() => _gender = 'FEMALE'),
                    ),
                    _IconChoice(
                      label: '남성',
                      icon: Icons.male,
                      selected: _gender == 'MALE',
                      onTap: () => setState(() => _gender = 'MALE'),
                    ),
                    _IconChoice(
                      label: '기타',
                      icon: Icons.transgender,
                      selected: _gender == 'OTHER',
                      onTap: () => setState(() => _gender = 'OTHER'),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ── 선택사항 타이틀 ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: Container(height: 1, color: kStroke)),
                      const SizedBox(width: 10),
                      const Text('선택사항', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black54)),
                      const SizedBox(width: 10),
                      Expanded(child: Container(height: 1, color: kStroke)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── 나이 ──
                TextFormField(
                  controller: _ageCtrl,
                  decoration: const InputDecoration(
                    labelText: '나이',
                    hintText: '예: 27',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return null; // 선택사항
                    final n = int.tryParse(s);
                    if (n == null || n < 1 || n > 120) {
                      return '1~120 사이의 숫자를 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── 여행 타입: 원형 칩 ──
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('여행 타입 (선택)',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800])),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 16,
                  children: _travelTypeOptions.map((type) {
                    final selected = _selectedTravelType == type; // 단일 비교
                    return _RoundChip(
                      icon: _travelIcon(type),
                      label: type,
                      selected: selected,
                      onTap: () {
                        setState(() {
                          _selectedTravelType = selected ? null : type; // 클릭 시 토글
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 35),

                // ── 저장 버튼 ──
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                        width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('저장'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _travelIcon(String type) {
    switch (type) {
      case '힐링':
        return Icons.self_improvement;
      case '액티비티':
        return Icons.directions_run;
      case '문화·예술':
        return Icons.palette;
      case '미식':
        return Icons.restaurant;
      case '자연':
        return Icons.forest;
      case '도시여행':
        return Icons.location_city;
      case '바다':
        return Icons.beach_access;
      case '산·트레킹':
        return Icons.terrain;
      default:
        return Icons.local_activity;
    }
  }
}

/// ===== 기존 아바타 미리보기 =====
class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.avatarUrl,
    required this.onChange,
  });

  final String? avatarUrl;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    const double radius = 56.0;
    final url = avatarUrl?.trim() ?? '';
    final hasUrl = url.isNotEmpty;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 10)],
          ),
          child: ClipOval(
            child: hasUrl
                ? Image.network(
              url,
              key: ValueKey(url),
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(radius),
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  width: radius * 2,
                  height: radius * 2,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
            )
                : _fallback(radius),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onChange,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('이미지 변경(데모)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF554E4F), // ← 아이콘+텍스트 색
            side: const BorderSide(color: Color(0xFF554E4F)), // 테두리
          ),
        )

      ],
    );
  }

  Widget _fallback(double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.person, size: 48, color: Colors.black38),
      ),
    );
  }
}

class _OutlinedPillButton extends StatelessWidget {
  const _OutlinedPillButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: const BorderSide(color: _ProfileEditScreenState.kStroke),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

/// ====== 칩 컴포넌트(성별/여행타입에서 사용) ======
class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg  = selected ? _ProfileEditScreenState.kPrimary.withOpacity(.18) : Colors.white;
    final Color fg  = selected ? _ProfileEditScreenState.kPrimary : Colors.black45;
    final Color ring= selected ? _ProfileEditScreenState.kPrimary : _ProfileEditScreenState.kStroke;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: ring),
            ),
            child: Icon(icon, color: fg),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RoundChip extends StatelessWidget {
  const _RoundChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg  = selected ? _ProfileEditScreenState.kPrimary.withOpacity(.18) : Colors.white;
    final Color fg  = selected ? _ProfileEditScreenState.kPrimary : Colors.black45;
    final Color ring= selected ? _ProfileEditScreenState.kPrimary : _ProfileEditScreenState.kStroke;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: ring),
              ),
              child: Icon(icon, size: 22, color: fg),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
