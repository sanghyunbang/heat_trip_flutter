// lib/features/auth/presentation/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/data/dto/register_request.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // ===== Consts =====
  static const Color _startBg = Color(0xFFF8F2E7);
  static const Color _fieldFill = Color(0xFFF2F4F7);
  static const Color _accent = Color(0xFFEB9C64);
  static const String kTermsVersion = 'v1.0';

  // ===== Form / State =====
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _nameController = TextEditingController();

  String _gender = 'male';          // 'male' | 'female' | 'other'
  String _ageGroup = 'over14';      // 'over14' | 'under14'

  bool _isLoading = false;
  bool _obscurePw = true;

  // Consents
  bool _agreeAll = false;
  bool _agreeTos = false;         // 필수
  bool _agreePrivacy = false;     // 필수
  bool _agreeMarketing = false;   // 선택

  final _authRepository = AuthRepositoryImpl();

  // ===== Lifecycle =====
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ===== Helpers =====
  void _toggleAgreeAll(bool? v) {
    final next = v ?? false;
    setState(() {
      _agreeAll = next;
      _agreeTos = next;
      _agreePrivacy = next;
      _agreeMarketing = next;
    });
  }

  void _syncAgreeAllFromChildren() {
    setState(() {
      _agreeAll = _agreeTos && _agreePrivacy && _agreeMarketing;
    });
  }

  Future<void> _openTermsFromAsset(String title, String assetPath) async {
    final body = await rootBundle.loadString(assetPath);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Text(
                    body,
                    style: const TextStyle(
                        fontSize: 13.5, height: 1.45, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    // 프런트 검증: 필수 동의 2개
    if (!_agreeTos || !_agreePrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('필수 동의 항목(이용약관/개인정보)을 확인해 주세요.'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // ★ 서버가 요구하는 신규 필드까지 포함한 DTO 생성
    final req = RegisterRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      nickname: _nicknameController.text.trim(),
      name: _nameController.text.trim(),
      gender: _gender,               // 'male' | 'female' | 'other'

      // 아래 필드가 RegisterRequest에 반드시 존재해야 함
      ageGroup: _ageGroup,           // 'over14' | 'under14'
      agreeTos: _agreeTos,
      agreePrivacy: _agreePrivacy,
      agreeMarketing: _agreeMarketing,
      tosVersion: kTermsVersion,
      privacyVersion: kTermsVersion,
      marketingVersion: _agreeMarketing ? kTermsVersion : null,
    );

    // (선택) 디버그: 실제 전송 바디 확인
    // debugPrint(req.toJson().toString());

    final success = await _authRepository.register(req);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('회원가입 완료')));
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      context.goNamed('login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 실패. 다시 시도해주세요.')));
    }
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _startBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: '뒤로',
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.goNamed('start'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 헤더
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 120,
              child: Container(
                color: _startBg,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Sign Up',
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87)),
                      SizedBox(height: 6),
                      Text('Please sign up to get started',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),

            // 폼
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 140, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 18,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _label('이메일'),
                              _filledField(
                                controller: _emailController,
                                hint: 'example@gmail.com',
                                keyboardType: TextInputType.emailAddress,
                                fill: _fieldFill,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      !value.contains('@')) {
                                    return '유효한 이메일을 입력하세요';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              _label('비밀번호'),
                              _filledField(
                                controller: _passwordController,
                                hint: '••••••••',
                                obscureText: _obscurePw,
                                fill: _fieldFill,
                                validator: (value) => value == null ||
                                        value.length < 8
                                    ? '8자 이상 입력하세요'
                                    : null,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePw
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black38,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscurePw = !_obscurePw),
                                ),
                              ),
                              const SizedBox(height: 14),

                              _label('닉네임'),
                              _filledField(
                                controller: _nicknameController,
                                hint: '닉네임을 입력하세요',
                                fill: _fieldFill,
                                validator: (value) => value == null ||
                                        value.isEmpty
                                    ? '닉네임을 입력하세요'
                                    : null,
                              ),
                              const SizedBox(height: 14),

                              _label('이름'),
                              _filledField(
                                controller: _nameController,
                                hint: '이름을 입력하세요',
                                fill: _fieldFill,
                                validator: (value) => value == null ||
                                        value.isEmpty
                                    ? '이름을 입력하세요'
                                    : null,
                              ),
                              const SizedBox(height: 14),

                              _label('성별'),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: _radioTile(
                                      title: '남자',
                                      value: 'male',
                                      group: _gender,
                                      onChanged: (v) =>
                                          setState(() => _gender = v!),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _radioTile(
                                      title: '여자',
                                      value: 'female',
                                      group: _gender,
                                      onChanged: (v) =>
                                          setState(() => _gender = v!),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              _label('나이 구분'),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: _radioTile(
                                      title: '만 14세 이상',
                                      value: 'over14',
                                      group: _ageGroup,
                                      onChanged: (v) =>
                                          setState(() => _ageGroup = v!),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _radioTile(
                                      title: '만 14세 미만',
                                      value: 'under14',
                                      group: _ageGroup,
                                      onChanged: (v) =>
                                          setState(() => _ageGroup = v!),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // 약관 동의
                              _label('약관 동의'),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                ),
                                child: Column(
                                  children: [
                                    CheckboxListTile(
                                      value: _agreeAll,
                                      onChanged: _toggleAgreeAll,
                                      title: const Text('전체 동의',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800)),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                    const Divider(height: 1),

                                    _consentRow(
                                      value: _agreeTos,
                                      onChanged: (v) {
                                        setState(
                                            () => _agreeTos = v ?? false);
                                        _syncAgreeAllFromChildren();
                                      },
                                      label: '이용약관 동의 (필수)',
                                      onView: () => _openTermsFromAsset(
                                          '이용약관',
                                          'assets/terms/terms_ko.md'),
                                    ),
                                    _consentRow(
                                      value: _agreePrivacy,
                                      onChanged: (v) {
                                        setState(() =>
                                            _agreePrivacy = v ?? false);
                                        _syncAgreeAllFromChildren();
                                      },
                                      label: '개인정보 처리방침 동의 (필수)',
                                      onView: () => _openTermsFromAsset(
                                          '개인정보처리방침',
                                          'assets/terms/privacy_ko.md'),
                                    ),
                                    _consentRow(
                                      value: _agreeMarketing,
                                      onChanged: (v) {
                                        setState(() =>
                                            _agreeMarketing = v ?? false);
                                        _syncAgreeAllFromChildren();
                                      },
                                      label: '마케팅 정보 수신 동의 (선택)',
                                      onView: () => _openTermsFromAsset(
                                          '마케팅 정보 수신 동의',
                                          'assets/terms/marketing_ko.md'),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _accent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    textStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  child: const Text('회원가입'),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Small UI helpers =====
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                letterSpacing: .4,
                color: Color(0xFF70757D),
                fontWeight: FontWeight.w700)),
      );

  Widget _filledField({
    required TextEditingController controller,
    required String hint,
    Color fill = _fieldFill,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: fill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: Colors.black87),
        suffixIcon: suffixIcon,
      ),
    );
  }

  OutlineInputBorder _border({Color color = Colors.transparent}) =>
      OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 1));

  Widget _radioTile({
    required String title,
    required String value,
    required String group,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(12)),
      child: RadioListTile<String>(
        value: value,
        groupValue: group,
        onChanged: onChanged,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _consentRow({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    VoidCallback? onView,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(child: Text(label)),
          if (onView != null)
            TextButton(
              onPressed: onView,
              child: const Text('보기',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}
