import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/data/dto/register_request.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // TextFormField와 연결된 컨트롤러들
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // 성별은 기본값을 'male'로 설정
  String _gender = 'male';

  // 로딩 상태 관리
  bool _isLoading = false;

  // AuthRepositoryImpl 인스턴스 생성 (HTTP 요청 처리 위임)
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();

  /// 폼 제출 시 호출되는 메서드
  Future<void> _submitForm() async {
    // 유효성 검사 실패 시 중단
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // RegisterRequest 객체 생성
    final request = RegisterRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      nickname: _nicknameController.text.trim(),
      name: _nameController.text.trim(),
      gender: _gender,
    );

    // 실제 HTTP 요청을 AuthRepository를 통해 전송
    final success = await _authRepository.register(request);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // 성공 메시지 및 이전 화면으로 이동
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('회원가입 완료')));
      Navigator.pop(context);
    } else {
      // 실패 메시지 출력
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('회원가입 실패. 다시 시도해주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: '이메일'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return '유효한 이메일을 입력하세요';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: '비밀번호'),
                      obscureText: true,
                      validator: (value) => value == null || value.length < 8
                          ? '8자 이상 입력하세요'
                          : null,
                    ),
                    TextFormField(
                      controller: _nicknameController,
                      decoration: InputDecoration(labelText: '닉네임'),
                      validator: (value) =>
                          value == null || value.isEmpty ? '닉네임을 입력하세요' : null,
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: '이름'),
                      validator: (value) =>
                          value == null || value.isEmpty ? '이름을 입력하세요' : null,
                    ),
                    SizedBox(height: 10),
                    Text('성별'),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('남자'),
                            value: 'male',
                            groupValue: _gender,
                            onChanged: (value) => setState(() {
                              _gender = value!;
                            }),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('여자'),
                            value: 'female',
                            groupValue: _gender,
                            onChanged: (value) => setState(() {
                              _gender = value!;
                            }),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(onPressed: _submitForm, child: Text('회원가입')),
                  ],
                ),
              ),
      ),
    );
  }
}
