// lib/features/auth/presentation/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
import 'package:heat_trip_flutter/features/auth/data/dto/register_request.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String _gender = 'male';
  bool _isLoading = false;
  bool _obscurePw = true;

  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = RegisterRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      nickname: _nicknameController.text.trim(),
      name: _nameController.text.trim(),
      gender: _gender,
    );

    final success = await _authRepository.register(request);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('회원가입 완료')));
      await Future.delayed(const Duration(milliseconds: 250));
      context.goNamed('login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('회원가입 실패. 다시 시도해주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const startBg = Color(0xFFF8F2E7);
    const fieldFill = Color(0xFFF2F4F7);
    const accent = Color(0xFFEB9C64);

    return Scaffold(
      backgroundColor: startBg,

      // 투명 AppBar(뒤로가기만 담당)
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
            // ── ⬇️ 헤더: 상단에 고정, 높이 명시 ──
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 120,
              child: Container(
                color: startBg,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      // 필요하면 로고 보이게 하세요 (assets 경로가 유효해야 합니다)
                      // Image(image: AssetImage('assets/Logo4.png'), height: 64),
                      // SizedBox(height: 10),
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Please sign up to get started',
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

            // ── ⬇️ 입력 카드: 헤더 높이만큼 띄워서 시작 ──
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
                    ),
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
                          fill: fieldFill,
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
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
                          fill: fieldFill,
                          validator: (value) =>
                          value == null || value.length < 8 ? '8자 이상 입력하세요' : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePw ? Icons.visibility_off : Icons.visibility,
                              color: Colors.black38,
                            ),
                            onPressed: () => setState(() => _obscurePw = !_obscurePw),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _label('닉네임'),
                        _filledField(
                          controller: _nicknameController,
                          hint: '닉네임을 입력하세요',
                          fill: fieldFill,
                          validator: (value) =>
                          value == null || value.isEmpty ? '닉네임을 입력하세요' : null,
                        ),
                        const SizedBox(height: 14),

                        _label('이름'),
                        _filledField(
                          controller: _nameController,
                          hint: '이름을 입력하세요',
                          fill: fieldFill,
                          validator: (value) =>
                          value == null || value.isEmpty ? '이름을 입력하세요' : null,
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
                                onChanged: (v) => setState(() => _gender = v!),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _radioTile(
                                title: '여자',
                                value: 'female',
                                group: _gender,
                                onChanged: (v) => setState(() => _gender = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submitForm,
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

  // ── 디자인 유틸 ──
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
    Color fill = const Color(0xFFF2F4F7),
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

  Widget _radioTile({
    required String title,
    required String value,
    required String group,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
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
}



// import 'package:flutter/material.dart';
// import 'package:heat_trip_flutter/features/auth/data/auth_repository_impl.dart';
// import 'package:heat_trip_flutter/features/auth/data/dto/register_request.dart';
// import 'package:go_router/go_router.dart'; // 추가 [0816]
//
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key}); //
//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   // TextFormField와 연결된 컨트롤러들
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _nicknameController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//
//   // 성별은 기본값을 'male'로 설정
//   String _gender = 'male';
//
//   // 로딩 상태 관리
//   bool _isLoading = false;
//
//   // AuthRepositoryImpl 인스턴스 생성 (HTTP 요청 처리 위임)
//   final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
//
//   /// 폼 제출 시 호출되는 메서드
//   Future<void> _submitForm() async {
//     // 유효성 검사 실패 시 중단
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     // RegisterRequest 객체 생성
//     final request = RegisterRequest(
//       email: _emailController.text.trim(),
//       password: _passwordController.text.trim(),
//       nickname: _nicknameController.text.trim(),
//       name: _nameController.text.trim(),
//       gender: _gender,
//     );
//
//     // 실제 HTTP 요청을 AuthRepository를 통해 전송
//     final success = await _authRepository.register(request);
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     if (success) {
//       // 성공 메시지 및 이전 화면으로 이동
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('회원가입 완료')));
//       await Future.delayed(const Duration(milliseconds: 250));
//       context.goNamed('login'); // 명시적으로 로그인 화면으로
//     } else {
//       // 실패 메시지 출력
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('회원가입 실패. 다시 시도해주세요.')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('회원가입'),
//         leading: IconButton(
//           onPressed: () => context.pop(), // 뒤로가기 보장
//           icon: const Icon(Icons.arrow_back),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : Form(
//                 key: _formKey,
//                 child: ListView(
//                   children: [
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: InputDecoration(labelText: '이메일'),
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (value) {
//                         if (value == null || !value.contains('@')) {
//                           return '유효한 이메일을 입력하세요';
//                         }
//                         return null;
//                       },
//                     ),
//                     TextFormField(
//                       controller: _passwordController,
//                       decoration: InputDecoration(labelText: '비밀번호'),
//                       obscureText: true,
//                       validator: (value) => value == null || value.length < 8
//                           ? '8자 이상 입력하세요'
//                           : null,
//                     ),
//                     TextFormField(
//                       controller: _nicknameController,
//                       decoration: InputDecoration(labelText: '닉네임'),
//                       validator: (value) =>
//                           value == null || value.isEmpty ? '닉네임을 입력하세요' : null,
//                     ),
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: InputDecoration(labelText: '이름'),
//                       validator: (value) =>
//                           value == null || value.isEmpty ? '이름을 입력하세요' : null,
//                     ),
//                     SizedBox(height: 10),
//                     Text('성별'),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: RadioListTile<String>(
//                             title: Text('남자'),
//                             value: 'male',
//                             groupValue: _gender,
//                             onChanged: (value) => setState(() {
//                               _gender = value!;
//                             }),
//                           ),
//                         ),
//                         Expanded(
//                           child: RadioListTile<String>(
//                             title: Text('여자'),
//                             value: 'female',
//                             groupValue: _gender,
//                             onChanged: (value) => setState(() {
//                               _gender = value!;
//                             }),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(onPressed: _submitForm, child: Text('회원가입')),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }
