import 'package:flutter/material.dart';

class FeedCreateScreen extends StatefulWidget {
  const FeedCreateScreen({super.key});

  @override
  _FeedCreateScreenState createState() => _FeedCreateScreenState();
}

class _FeedCreateScreenState extends State<FeedCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String author = '';
  String content = '';

  String? primaryMood; // 기본 기분 선택
  List<Map<String, String?>> extraMoodInputs = [];

  final List<Map<String, String>> moodOptions = [
    {'label': '슬픔', 'emoji': '😢'},
    {'label': '기쁨', 'emoji': '😊'},
    {'label': '심심함', 'emoji': '😐'},
    {'label': '평온함', 'emoji': '😌'},
    {'label': '신남', 'emoji': '🤩'},
  ];

  void addMoodInput() {
    setState(() {
      extraMoodInputs.add({'mood': null, 'detail': ''});
    });
  }

  void removeMoodInput(int index) {
    setState(() {
      extraMoodInputs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 186, 209),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 186, 215),
        title: const Text('피드 작성'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '제목'),
                onSaved: (value) => title = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty ? '제목을 입력하세요' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '글쓴이'),
                onSaved: (value) => author = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty ? '글쓴이를 입력하세요' : null,
              ),

              const SizedBox(height: 16),
              const Text('기분', style: TextStyle(fontSize: 16)),

              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: moodOptions.map((mood) {
                  final isSelected = primaryMood == mood['label'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        primaryMood = mood['label'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blueAccent.withOpacity(0.2)
                            : Colors.grey.shade200,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(mood['emoji']!, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(mood['label']!, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('기분 추가 입력', style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: addMoodInput,
                  ),
                ],
              ),

              ...extraMoodInputs.asMap().entries.map((entry) {
                int index = entry.key;
                String? selectedMood = entry.value['mood'];
                String? detail = entry.value['detail'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        children: moodOptions.map((mood) {
                          final isSelected = selectedMood == mood['label'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                extraMoodInputs[index]['mood'] = mood['label'];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blueAccent.withOpacity(0.2)
                                    : Colors.grey.shade200,
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(mood['emoji']!, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  Text(mood['label']!, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(labelText: '기분 설명'),
                        initialValue: detail,
                        onChanged: (value) {
                          extraMoodInputs[index]['detail'] = value;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => removeMoodInput(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('삭제', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: '내용'),
                maxLines: 5,
                onSaved: (value) => content = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty ? '내용을 입력하세요' : null,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            _formKey.currentState?.save();

            print('제목: $title');
            print('글쓴이: $author');
            print('기본 기분: $primaryMood');
            print('추가 기분들:');
            for (var mood in extraMoodInputs) {
              print(' - ${mood['mood']} : ${mood['detail']}');
            }
            print('내용: $content');

            // 예: 서버 전송 후 뒤로 이동
            Navigator.pop(context);
          }
        },
        label: const Text('피드 등록'),
        icon: const Icon(Icons.send),
      ),
    );
  }
}
