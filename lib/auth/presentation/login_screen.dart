import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/auth/data/dto/login_request.dart';
import 'package:heat_trip_flutter/auth/presentation/widgets/social_login_button.dart';
import 'package:heat_trip_flutter/auth/service/social_login_service.dart';
import 'package:heat_trip_flutter/home/start_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 이메일 로그인에 사용할 repository
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();

  // 소셜 로그인 서비스 (정적 메소드만 사용중)
  final SocialLoginService _loginService = SocialLoginService();

  // 사용자 입력을 위한 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // 일반 로그인 처리
  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showDialog('이메일과 비밀번호를 모두 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // AuthRepository를 통해 로그인 요청
      final token = await _authRepository.login(
        LoginRequest(email: email, password: password),
      );

      if (token != null) {
        // Flutter에서 로컬에 데이터를 저장할 수 있게 해주는 라이브러리
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StartScreen()),
          );
        }
      } else {
        _showDialog('[로그인 실패] 아이디와 비밀번호를 확인해주세요.');
      }
    } catch (e) {
      _showDialog('오류 발생: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 소셜 로그인 처리
  Future<void> _handleSocialLogin(String provider) async {
    final success = await SocialLoginService.signIn(provider);
    if (success && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StartScreen()),
      );
    }
  }

  /// 공통 알림창
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
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: '이메일'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleEmailLogin,
                      child: const Text('이메일 로그인'),
                    ),
              const Divider(height: 40),

              // 소셜 로그인 컴포넌트 사용
              SocialLoginButton(
                iconPath: 'assets/icons/google.svg',
                label: 'Google로 로그인',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: () => _handleSocialLogin('google'),
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
    );
  }
}
