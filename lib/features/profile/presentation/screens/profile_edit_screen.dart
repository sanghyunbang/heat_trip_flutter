import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── 데모용 초기값 (서버 연동 없이 화면만 확인) ──
  final _nicknameCtrl = TextEditingController(text: '민하');
  final _nameCtrl = TextEditingController(text: '김민하');
  final _emailCtrl = TextEditingController(text: 'minha@example.com');
  DateTime? _birthDate = DateTime(1998, 1, 23);
  String _gender = 'F';

  // 아바타(데모): 기본 아이콘 / 샘플이미지1 / 샘플이미지2
  String? _avatarUrl; // null이면 기본 아이콘
  bool _saving = false;

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: '생년월일 선택',
      fieldHintText: 'YYYY-MM-DD',
    );
    if (picked != null) setState(() => _birthDate = picked);
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
    await Future.delayed(const Duration(milliseconds: 700)); // 저장 흉내
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장(데모) 완료!')),
    );
    Navigator.of(context).pop(); // 이전 화면으로
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
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

                // ── 이메일 ──
                TextFormField(
                  controller: _emailCtrl,
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

                // ── 생년월일 ──
                InkWell(
                  onTap: _pickBirthDate,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '생년월일',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_birthDate == null
                            ? '선택하세요'
                            : '${_birthDate!.year.toString().padLeft(4, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 10)],
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
