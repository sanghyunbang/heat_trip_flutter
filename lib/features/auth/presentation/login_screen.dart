// lib/features/auth/presentation/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ 유지
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/data/dto/login_request.dart';
import 'package:heat_trip_flutter/features/auth/presentation/widgets/social_login_button.dart';
import 'package:heat_trip_flutter/features/auth/service/social_login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  final SocialLoginService _loginService = SocialLoginService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // ✅ 추가: 비밀번호 보이기/가리기 토글 상태
  bool _obscureLoginPw = true;

  // === 원본 기능 그대로 ===
  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showDialog('이메일과 비밀번호를 모두 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = await _authRepository.login(
        LoginRequest(email: email, password: password),
      );
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        if (!mounted) return;

        // ✅ Navigator.pushReplacement → go_router (원본 로직 유지)
        context.go('/explore');
      } else {
        _showDialog('[로그인 실패] 아이디와 비밀번호를 확인해주세요.');
      }
    } catch (e) {
      _showDialog('오류 발생: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // === 원본 기능 그대로 ===
  Future<void> _handleSocialLogin(String provider) async {
    final success = await SocialLoginService.signIn(provider);
    if (success && mounted) {
      context.go('/explore');
    }
  }

  // === 원본 기능 그대로 ===
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // sign_up_screen 과 동일 톤
    const startBg = Color(0xFFF8F2E7);
    const fieldFill = Color(0xFFF2F4F7);
    const accent = Color(0xFFEB9C64);

    // 상단 고정 헤더 높이
    const double headerHeight = 120;

    return Scaffold(
      backgroundColor: startBg,

      // 투명 AppBar (뒤로가기만 담당 / 기능 변경 없음)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: '뒤로',
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          // 뒤로갈 곳이 있으면 pop, 아니면 start로 이동
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('start');
            }
          },
        ),
      ),

      body: SafeArea(
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── 헤더: 상단 고정 ──
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: headerHeight,
              child: Container(
                color: startBg,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      // 필요 시 로고 사용 (assets 경로 맞으면 주석 해제)
                      // Image(image: AssetImage('assets/Logo4.png'), height: 64),
                      // SizedBox(height: 10),
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

            // ── 입력 카드(모달 느낌) + 소셜 로그인: 헤더 아래에서 시작 ──
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, headerHeight + 20, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ======= 원본 기능/필드 그대로 =======
                      _label('이메일'),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _filledDecoration(
                          hint: 'example@gmail.com',
                          fill: fieldFill,
                        ),
                      ),
                      const SizedBox(height: 14),

                      _label('비밀번호'),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureLoginPw, // ✅ 토글 적용
                        decoration: _filledDecoration(
                          hint: '••••••••',
                          fill: fieldFill,
                        ).copyWith(
                          // ✅ 눈 아이콘 토글
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureLoginPw
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black38,
                            ),
                            onPressed: () =>
                                setState(() => _obscureLoginPw = !_obscureLoginPw),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleEmailLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
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

                      const SizedBox(height: 24),
                      const Divider(),

                      // 소셜 로그인 버튼들(원본 그대로)
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE5E7EB), width: 1), // ← 연회색 테두리
                        ),
                        child: SocialLoginButton(
                          iconPath: 'assets/icons/google.svg',
                          label: 'Google로 로그인',
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          onPressed: () => _handleSocialLogin('google'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        iconPath: 'assets/icons/kakao.svg',
                        label: 'Kakao로 로그인',
                        backgroundColor: const Color(0xFFFEE500),
                        textColor: Colors.black,
                        onPressed: () => _handleSocialLogin('kakao'),
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        iconPath: 'assets/icons/naver.svg',
                        label: 'Naver로 로그인',
                        backgroundColor: const Color(0xFF03C75A),
                        textColor: Colors.white,
                        onPressed: () => _handleSocialLogin('naver'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== 디자인용 헬퍼 (기능 변경 없음) =====
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

  InputDecoration _filledDecoration({
    required String hint,
    Color fill = const Color(0xFFF2F4F7),
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(color: Colors.black87),
    );
  }

  OutlineInputBorder _border({Color color = Colors.transparent}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 1),
      );
}



// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart'; // ✅ 추가
// import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
// import 'package:heat_trip_flutter/features/auth/data/dto/login_request.dart';
// import 'package:heat_trip_flutter/features/auth/presentation/widgets/social_login_button.dart';
// import 'package:heat_trip_flutter/features/auth/service/social_login_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
//   final SocialLoginService _loginService = SocialLoginService();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//
//   Future<void> _handleEmailLogin() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     if (email.isEmpty || password.isEmpty) {
//       _showDialog('이메일과 비밀번호를 모두 입력해주세요.');
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     try {
//       final token = await _authRepository.login(
//         LoginRequest(email: email, password: password),
//       );
//       if (token != null) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('jwt_token', token);
//         if (!mounted) return;
//
//         // ✅ Navigator.pushReplacement → go_router
//         context.go('/explore'); // or: context.goNamed('start');
//       } else {
//         _showDialog('[로그인 실패] 아이디와 비밀번호를 확인해주세요.');
//       }
//     } catch (e) {
//       _showDialog('오류 발생: $e');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _handleSocialLogin(String provider) async {
//     final success = await SocialLoginService.signIn(provider);
//     if (success && mounted) {
//       // ✅ 소셜 로그인 성공 시도 동일
//       context.go('/explore');
//     }
//   }
//
//   void _showDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('알림'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('확인'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('로그인')),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             children: [
//               TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: '이메일'),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(labelText: '비밀번호'),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 20),
//               _isLoading
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _handleEmailLogin,
//                       child: const Text('이메일 로그인'),
//                     ),
//               const Divider(height: 40),
//               SocialLoginButton(
//                 iconPath: 'assets/icons/google.svg',
//                 label: 'Google로 로그인',
//                 backgroundColor: Colors.white,
//                 textColor: Colors.black,
//                 onPressed: () => _handleSocialLogin('google'),
//               ),
//               const SizedBox(height: 12),
//               SocialLoginButton(
//                 iconPath: 'assets/icons/kakao.svg',
//                 label: 'Kakao로 로그인',
//                 backgroundColor: const Color(0xFFFEE500),
//                 textColor: Colors.black,
//                 onPressed: () => _handleSocialLogin('kakao'),
//               ),
//               const SizedBox(height: 12),
//               SocialLoginButton(
//                 iconPath: 'assets/icons/naver.svg',
//                 label: 'Naver로 로그인',
//                 backgroundColor: const Color(0xFF03C75A),
//                 textColor: Colors.white,
//                 onPressed: () => _handleSocialLogin('naver'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
