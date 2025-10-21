// lib/features/profile/presentation/screens/profile_edit_screen.dart
//
// 변경 요약
// - AuthRepositoryImpl를 late final로 두고, initState에서 context.read<ApiClient>()로 주입 초기화
// - getMyProfile(), updateMyProfile(req) 모두 토큰 인자를 제거 (ApiClient가 자동 처리)
// - 나머지 UI/검증/캐시 로직은 기존 유지

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:heat_trip_flutter/shared/network/api_client.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';
import 'package:heat_trip_flutter/features/profile/data/dto/update_profile_request.dart';

// ↓ shared/media 배럴 (models, repository, widgets 포함)
import 'package:heat_trip_flutter/shared/media/media.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── 텍스트 컨트롤러 ──
  final _nicknameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(); // 선택 입력

  // ── 상태 값 ──
  String _gender = 'OTHER'; // FEMALE / MALE / OTHER
  String? _avatarUrl; // 서버/캐시에서 가져온 프로필 이미지 URL
  int? _avatarMediaId; // (선택) 서버 mediaId를 보관하면 PUT /media/{id} 교체 가능
  bool _saving = false;

  // ── 서버 연동(프로필 API) ──
  late final AuthRepositoryImpl _authRepo; // ★ initState에서 주입 초기화
  bool _loadingProfile = true;
  String? _loadError;

  // ── 여행 타입(단일 선택) ──
  static const List<String> _travelTypeOptions = [
    '힐링',
    '액티비티',
    '문화·예술',
    '미식',
    '자연',
    '도시여행',
    '바다',
    '산·트레킹',
  ];
  String? _selectedTravelType;

  // ── 디자인 ──
  static const Color kPrimary = Color(0xFFEB9C64);
  static const Color kStroke = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    // [A] 여기서 ApiClient 주입
    _authRepo = AuthRepositoryImpl(context.read<ApiClient>());
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

  /// 서버에서 프로필 정보를 불러와 화면에 매핑
  /// - (선택) SP에 저장된 avatarUrl 캐시를 먼저 보여줘서 초기 UX 개선
  Future<void> _loadFromServer() async {
    setState(() {
      _loadingProfile = true;
      _loadError = null;
    });

    // (옵션) 캐시된 URL을 먼저 프리뷰에 표시
    try {
      final sp = await SharedPreferences.getInstance();
      final cached = sp.getString('avatarUrl');
      if (cached != null && cached.isNotEmpty) {
        setState(() => _avatarUrl = cached);
      }
    } catch (_) {}

    try {
      // UX: 토큰 유무로 로그인 상태만 판단
      final token = await TokenStorage.getToken();
      if (token == null) {
        setState(() {
          _loadError = '로그인이 필요합니다.';
          _loadingProfile = false;
        });
        return;
      }

      // [B] 토큰 인자 필요 없음
      final data = await _authRepo.getMyProfile();
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
      _nameCtrl.text = (data['name'] ?? '').toString();
      _emailCtrl.text = (data['email'] ?? '').toString();

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
      final img = (data['imageUrl'] ?? data['image_url'] ?? data['avatarUrl'])
          ?.toString()
          .trim();
      _avatarUrl = (img != null && img.isNotEmpty) ? img : _avatarUrl;

      // (선택) 서버가 mediaId를 내려주면 보관 (교체 API 사용 시 유리)
      final mediaId = data['avatarMediaId'];
      if (mediaId != null) {
        _avatarMediaId = int.tryParse(mediaId.toString());
      }

      // 나이(선택)
      final dynamic age = data['age'];
      if (age != null && age.toString().isNotEmpty) {
        _ageCtrl.text = age.toString();
      } else if (data['birthDate'] != null) {
        final dt = DateTime.tryParse(data['birthDate'].toString());
        if (dt != null) _ageCtrl.text = _computeAge(dt).toString();
      }

      // 여행 타입(단일)
      final single = (data['travelType'] ?? '').toString().trim();
      _selectedTravelType = _travelTypeOptions.contains(single) ? single : null;

      // 최신 URL을 캐시에 반영(선택)
      if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
        final sp = await SharedPreferences.getInstance();
        await sp.setString('avatarUrl', _avatarUrl!);
      }

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

  /// 저장 버튼: 폼 검증 → 로그인 확인 → UpdateProfileRequest → API → 성공 시 pop(true).
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    // UX: 로그인 여부만 확인
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
      gender: _gender,
      age: age,
      imageUrl: _avatarUrl, // ★ AvatarPicker에서 갱신한 url
      travelType: _selectedTravelType,
    );

    // 디버그: 실제 전송 바디 확인
    debugPrint('[PUT /auth/me] body: ${jsonEncode(req.toJson())}');

    // [C] 토큰 인자 제거된 API 호출
    final ok = await _authRepo.updateMyProfile(req);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 저장되었습니다.')),
      );
      Navigator.of(context).pop(true); // ★ ProfileScreen에서 재로딩 트리거
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 수정')),
      body: SafeArea(
        child: _loadError != null
            ? Center(
                child: Text(
                  _loadError!,
                  style: const TextStyle(color: Colors.black54),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ─────────────────────────────
                      // 아바타 (실제 업로드 위젯)
                      // - AvatarPicker 내부에서 업로드 후 url을 onUploaded로 전달
                      // ─────────────────────────────
                      AvatarPicker(
                        initialUrl: _avatarUrl,
                        existingMediaId: _avatarMediaId,
                        onUploaded: (UploadedMedia m) async {
                          setState(() {
                            _avatarUrl = m.url;
                            _avatarMediaId = m.id;
                          });
                          final sp = await SharedPreferences.getInstance();
                          await sp.setString('avatarUrl', m.url);
                        },
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

                      // ── 이메일(읽기전용) ──
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
                        child: Text(
                          '성별',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
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

                      // ── 선택사항 제목 구분선 ──
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(child: Container(height: 1, color: kStroke)),
                            const SizedBox(width: 10),
                            const Text(
                              '선택사항',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black54,
                              ),
                            ),
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
                        child: Text(
                          '여행 타입 (선택)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 14,
                        runSpacing: 16,
                        children: _travelTypeOptions.map((type) {
                          final selected = _selectedTravelType == type; // 단일
                          return _RoundChip(
                            icon: _travelIcon(type),
                            label: type,
                            selected: selected,
                            onTap: () {
                              setState(() {
                                _selectedTravelType = selected ? null : type;
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
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
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

/// ====== 공통 칩 컴포넌트 ======
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
    final Color bg = selected
        ? _ProfileEditScreenState.kPrimary.withOpacity(.18)
        : Colors.white;
    final Color fg = selected
        ? _ProfileEditScreenState.kPrimary
        : Colors.black45;
    final Color ring = selected
        ? _ProfileEditScreenState.kPrimary
        : _ProfileEditScreenState.kStroke;

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
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
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
    final Color bg = selected
        ? _ProfileEditScreenState.kPrimary.withOpacity(.18)
        : Colors.white;
    final Color fg = selected
        ? _ProfileEditScreenState.kPrimary
        : Colors.black45;
    final Color ring = selected
        ? _ProfileEditScreenState.kPrimary
        : _ProfileEditScreenState.kStroke;

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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ─────────────────────────── 각주 ───────────────────────────
[A] Provider로 등록된 ApiClient를 읽어와 AuthRepositoryImpl에 주입.
    화면 필드에서 context를 바로 쓰면 에러이므로, late final로 선언 후 initState에서 초기화함.

[B] getMyProfile()은 이제 토큰을 인자로 받지 않음. ApiClient가 내부에서 헤더를 붙임.
    다만 UX를 위해 로그인 여부(토큰 존재)는 화면에서 먼저 체크.

[C] updateMyProfile(req) 또한 토큰 인자 제거. 이전 “String 인자를 넣었다” 에러 해결.
────────────────────────────────────────────────────────── */
