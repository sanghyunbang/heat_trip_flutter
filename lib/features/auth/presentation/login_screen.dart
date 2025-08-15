//Navigator → go_router 로 교체 + StartScreen import 제거.[0816]

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ 추가
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

        // ✅ Navigator.pushReplacement → go_router
        context.go('/explore'); // or: context.goNamed('start');
      } else {
        _showDialog('[로그인 실패] 아이디와 비밀번호를 확인해주세요.');
      }
    } catch (e) {
      _showDialog('오류 발생: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    final success = await SocialLoginService.signIn(provider);
    if (success && mounted) {
      // ✅ 소셜 로그인 성공 시도 동일
      context.go('/explore');
    }
  }

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
