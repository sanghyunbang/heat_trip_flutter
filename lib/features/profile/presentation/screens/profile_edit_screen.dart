// lib/features/profile/presentation/profile_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/service/token_storage.dart';

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
  final _ageCtrl = TextEditingController(); // ✅ 나이 입력용

  String _gender = 'OTHER'; // 'FEMALE' / 'MALE' / 'OTHER'
  String? _avatarUrl;   // null이면 기본 아이콘
  bool _saving = false;

  // ✅ 서버 연동용
  final _authRepo = AuthRepositoryImpl();
  bool _loadingProfile = true; // 프로필 로딩 스피너
  String? _loadError;          // 에러 메시지(선택)

  // ✅ 여행 타입(멀티 선택)
  static const List<String> _travelTypeOptions = [
    '힐링', '액티비티', '문화·예술', '미식', '자연', '도시여행', '바다', '산·트레킹'
  ];
  final Set<String> _selectedTravelTypes = {}; // 서버에서 불러오면 반영

  @override
  void initState() {
    super.initState();
    _loadFromServer(); // 화면 진입 시 서버에서 내 정보 로드
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  // ✅ 서버에서 유저 정보 로드
  Future<void> _loadFromServer() async {
    setState(() {
      _loadingProfile = true;
      _loadError = null;
    });

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        setState(() {
          _loadError = '로그인이 필요합니다.'; // 토큰 없음
          _loadingProfile = false;
        });
        return;
      }

      final data = await _authRepo.getMyProfile(token);
      if (data == null) {
        setState(() {
          _loadError = '프로필 정보를 불러오지 못했습니다.';
          _loadingProfile = false;
        });
        return;
      }

      // 서버 필드명 예시: name, nickname, email, gender, avatarUrl, birthDate, age, preferredTravelTypes
      _nicknameCtrl.text = (data['nickname'] ?? '').toString();
      _nameCtrl.text     = (data['name'] ?? '').toString();
      _emailCtrl.text    = (data['email'] ?? '').toString();

      final g = (data['gender'] ?? '').toString().toUpperCase();
      if (g == 'MALE' || g == 'M') _gender = 'MALE';
      else if (g == 'FEMALE' || g == 'F') _gender = 'FEMALE';
      else _gender = 'OTHER';

      _avatarUrl = (data['avatarUrl'] as String?);

      // ✅ 나이 채우기: age 우선, 없으면 birthDate로 계산
      final dynamic age = data['age'];
      if (age != null) {
        _ageCtrl.text = age.toString();
      } else if (data['birthDate'] != null) {
        final dt = DateTime.tryParse(data['birthDate'].toString());
        if (dt != null) _ageCtrl.text = _computeAge(dt).toString();
      }

      // ✅ 여행 타입 선택 반영 (preferredTravelTypes 또는 travelTypes)
      final dynamic types = data['preferredTravelTypes'] ?? data['travelTypes'];
      if (types is List) {
        final s = types.map((e) => e.toString()).toSet();
        _selectedTravelTypes
          ..clear()
          ..addAll(s.intersection(_travelTypeOptions.toSet())); // 알 수 없는 값 제외
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
    final hasHadBirthdayThisYear =
        (now.month > birth.month) ||
            (now.month == birth.month && now.day >= birth.day);
    if (!hasHadBirthdayThisYear) age--;
    return age.clamp(0, 150);
  }

  Future<void> _pickBirthDate() async {
    // ⛔️ 사용 안 함(생년월일 → 나이로 대체). 참조 남김 시 삭제 가능.
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
                    _AvatarChoiceButton(
                      label: '기본',
                      onTap: () { setState(() => _avatarUrl = null); Navigator.pop(context); },
                    ),
                    _AvatarChoiceButton(
                      label: '샘플1',
                      onTap: () {
                        setState(() => _avatarUrl = 'https://picsum.photos/seed/heat1/200');
                        Navigator.pop(context);
                      },
                    ),
                    _AvatarChoiceButton(
                      label: '샘플2',
                      onTap: () {
                        setState(() => _avatarUrl = 'https://picsum.photos/seed/heat2/200');
                        Navigator.pop(context);
                      },
                    ),
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

  Future<void> _saveDemo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장(데모) 완료!')),
    );
    Navigator.of(context).pop();
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
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveDemo,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('저장'),
          ),
        ],
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
                // ── 아바타 영역 ──
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

                // ── 이메일 ── (unique라면 readOnly 권장)
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

                // ── 나이 ──  ✅ (생년월일 대체)
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
                    if (s.isEmpty) return '나이를 입력하세요';
                    final n = int.tryParse(s);
                    if (n == null || n < 1 || n > 120) {
                      return '1~120 사이의 숫자를 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── 성별 ──
                Row(
                  children: [
                    const Text('성별', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('여성'),
                      selected: _gender == 'F',
                      onSelected: (v) => setState(() => _gender = 'F'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('남성'),
                      selected: _gender == 'M',
                      onSelected: (v) => setState(() => _gender = 'M'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('기타'),
                      selected: _gender == 'OTHER',
                      onSelected: (v) => setState(() => _gender = 'OTHER'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── 여행 타입 선택(멀티) ──  ✅
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('여행 타입', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800])),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _travelTypeOptions.map((type) {
                    final selected = _selectedTravelTypes.contains(type);
                    return ChoiceChip(
                      label: Text(type),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedTravelTypes.add(type);
                          } else {
                            _selectedTravelTypes.remove(type);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // ── 저장 버튼(보조) ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _saveDemo,
                    icon: const Icon(Icons.check),
                    label: const Text('저장(데모)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.avatarUrl,
    required this.onChange,
  });

  final String? avatarUrl;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    const radius = 56.0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black26.withOpacity(.08), blurRadius: 10)],
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, size: 48, color: Colors.black38)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onChange,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('아바타 변경(데모)'),
        ),
      ],
    );
  }
}

class _AvatarChoiceButton extends StatelessWidget {
  const _AvatarChoiceButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(label),
    );
  }
}
