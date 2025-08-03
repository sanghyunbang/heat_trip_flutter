import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String _gender = 'male';

  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(' '); // ← 실제 API 주소로 변경하세요

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': _emailController.text.trim(),
        'nickname': _nicknameController.text.trim(),
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'gender': _gender,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      // 성공 처리
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('회원가입 완료')));
      Navigator.pop(context);
    } else {
      // 실패 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패: ${response.statusCode}')),
      );
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
                      controller: _nicknameController,
                      decoration: InputDecoration(labelText: '닉네임'),
                      validator: (value) =>
                          value == null || value.isEmpty ? '닉네임을 입력하세요' : null,
                    ),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: '이름'),
                      validator: (value) =>
                          value == null || value.isEmpty ? '이름을 입력하세요' : null,
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: '성'),
                      validator: (value) =>
                          value == null || value.isEmpty ? '성을 입력하세요' : null,
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
