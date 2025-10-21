// lib/features/auth/presentation/login_screen.dart
//
// 목적
// - 이메일/비밀번호 로그인 UI + 레포 호출(DI)
// - "회원가입" 버튼, "로그인 없이 둘러보기" 버튼 추가
// - SignUpScreen과 톤을 맞춘 디자인 적용
//
// 라우팅 동작
// - 로그인 성공 → '/foryou_v2' 로 이동 (MAIN_AFTER_LOGIN과 일치)
// - 회원가입 → name: 'signUp' 라우트로 이동
// - 로그인 없이 둘러보기 → '/start' (공개 경로; 보호 탭은 리다이렉트됨)
//
// 주입/의존
// - ApiClient를 Provider에서 읽어 AuthRepositoryImpl 생성자에 주입
// - AuthState.setToken(token) 호출로 전역 상태 브로드캐스트

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/data/dto/login_request.dart';
import 'package:heat_trip_flutter/features/auth/state/auth_state.dart';
import 'package:heat_trip_flutter/shared/network/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ===== 스타일(회원가입 화면과 통일) =====
  static const Color _startBg = Color(0xFFF8F2E7);
  static const Color _fieldFill = Color(0xFFF2F4F7);
  static const Color _accent   = Color(0xFFEB9C64);

  // ===== DI =====
  late final AuthRepositoryImpl _authRepository;

  // ===== 폼 =====
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw    = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // Provider에서 ApiClient를 읽어 생성자 주입
    _authRepository = AuthRepositoryImpl(context.read<ApiClient>());
  }

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  // ===== 액션 =====
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _email.text.trim();
    final password = _pw.text.trim();

    setState(() => _loading = true);
    try {
      final token = await _authRepository.login(LoginRequest(email: email, password: password));
      if (token != null) {
        await context.read<AuthState>().setToken(token); // 저장 + 방송
        if (!mounted) return;
        // 로그인 성공 시에만 메인으로 이동
        context.go('/foryou_v2');
      } else {
        _snack('로그인 실패: 아이디/비밀번호를 확인하세요.');
      }
    } catch (e) {
      _snack('오류: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goSignUp() => context.goNamed('signUp');

  // 공개 경로로 보내 "그냥 둘러보기" 가능
  void _browseWithoutLogin() => context.go('/start');

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
              left: 0, right: 0, top: 0, height: 120,
              child: Container(
                color: _startBg,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Please log in to continue',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 본문 카드
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
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('이메일'),
                        _filledField(
                          controller: _email,
                          hint: 'example@gmail.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              (v == null || v.isEmpty || !v.contains('@'))
                                  ? '유효한 이메일을 입력하세요'
                                  : null,
                        ),
                        const SizedBox(height: 14),

                        _label('비밀번호'),
                        _filledField(
                          controller: _pw,
                          hint: '••••••••',
                          obscureText: _obscure,
                          validator: (v) =>
                              (v == null || v.length < 8)
                                  ? '8자 이상 입력하세요'
                                  : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              color: Colors.black38,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          height: 50,
                          child: _loading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _accent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  child: const Text('이메일 로그인'),
                                ),
                        ),

                        const SizedBox(height: 12),

                        // 회원가입 / 비회원 둘러보기
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _goSignUp,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  foregroundColor: Colors.black87,
                                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                child: const Text('회원가입'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _browseWithoutLogin,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  foregroundColor: Colors.black87,
                                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                child: const Text('둘러보기'),
                              ),
                            ),
                          ],
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

  // ===== 작은 UI 헬퍼 =====
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: .4,
            color: Color(0xFF70757D),
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _filledField({
    required TextEditingController controller,
    required String hint,
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
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        borderSide: BorderSide(color: color, width: 1),
      );
}
