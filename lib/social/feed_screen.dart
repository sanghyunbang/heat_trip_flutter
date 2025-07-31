import 'package:flutter/material.dart';
import 'feed_create_screen.dart';
import 'package:intl/intl.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String selectedFilter = '감정별보기';
  String? selectedSubFilter;

  final Map<String, List<String>> subFilters = {
    '감정별보기': ['신나요', '평온해요', '따뜻해요', '포근해요'],
    '지역별보기': ['제주도', '강원도', '서울', '부산'],
    '게시물보기': ['최신순', '인기순'],
    '피드만보기': ['나의 피드', '팔로우 피드'],
  };

  final List<Map<String, dynamic>> posts = [
    {
      'title': '조용한 휴식',
      'author': '김철수',
      'mood': '😌',
      'moodLabel': '평온해요',
      'moodTemperature': 5,
      'content': '한적한 시골에서 마음을 달래다 왔어요.',
      'location': '강원도',
      'likes': 5,
      'date': DateTime(2025, 7, 25),
      'imageUrl':
          'https://cdn.pixabay.com/photo/2024/08/29/10/01/nature-9006428_1280.jpg',
    },
    {
      'title': '따뜻한 카페 데이트',
      'author': '이영희',
      'mood': '😊',
      'moodLabel': '따뜻해요',
      'moodTemperature': 6,
      'content': '조용한 카페에서 친구와 좋은 시간을 보냈어요.',
      'location': '서울',
      'likes': 8,
      'date': DateTime(2025, 7, 30),
      'imageUrl':
          'https://cdn.pixabay.com/photo/2021/08/12/05/19/cathedral-6539937_1280.jpg',
    },
    {
      'title': '포근한 바닷가 산책',
      'author': '박민수',
      'mood': '🥰',
      'moodLabel': '포근해요',
      'moodTemperature': 4,
      'content': '바닷가에서 산책하며 힐링했어요.',
      'location': '부산',
      'likes': 15,
      'date': DateTime(2025, 7, 27),
      'imageUrl':
          'https://cdn.pixabay.com/photo/2017/08/06/18/29/woman-2594934_1280.jpg',
    },
    {
      'title': '서울 야경 감상',
      'author': '최지우',
      'mood': '😌',
      'moodLabel': '평온해요',
      'moodTemperature': 5,
      'content': '서울의 멋진 야경을 감상했어요.',
      'location': '서울',
      'likes': 20,
      'date': DateTime(2025, 7, 26),
      'imageUrl':
          'https://cdn.pixabay.com/photo/2019/08/10/03/15/bridge-4396131_1280.jpg',
    },
    {
      'title': '강원도 산속 힐링',
      'author': '한예슬',
      'mood': '🥰',
      'moodLabel': '포근해요',
      'moodTemperature': 6,
      'content': '강원도 산속에서 마음이 평화로워졌어요.',
      'location': '강원도',
      'likes': 9,
      'date': DateTime(2025, 7, 29),
      'imageUrl':
          'https://cdn.pixabay.com/photo/2021/12/14/16/15/city-6870803_1280.jpg',
    },
  ];

  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  Color moodColor(String moodLabel) {
    switch (moodLabel) {
      case '신나요':
        return Colors.pink.shade400;
      case '평온해요':
        return Colors.blue.shade400;
      case '따뜻해요':
        return Colors.orange.shade400;
      case '포근해요':
        return Colors.green.shade400;
      default:
        return Colors.grey;
    }
  }

  Widget moodTemperatureBar(int value, Color color) {
    return Row(
      children: List.generate(10, (index) {
        final isFilled = index < value;
        return Container(
          width: 8,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isFilled ? color.withOpacity(0.9) : color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 필터링된 데이터 리스트
    List<Map<String, dynamic>> filteredPosts = posts.where((post) {
      if (selectedFilter == '감정별보기' && selectedSubFilter != null) {
        return post['moodLabel'] == selectedSubFilter;
      }
      if (selectedFilter == '지역별보기' && selectedSubFilter != null) {
        return post['location'] == selectedSubFilter;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 186, 215),
      appBar: AppBar(
        title: const Text('모두의 여행'),
        backgroundColor: const Color.fromARGB(255, 255, 186, 215),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedCreateScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text('피드 작성', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📌 상위 필터',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: subFilters.keys.map((filter) {
                    final isSelected = selectedFilter == filter;
                    return ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.pinkAccent,
                      backgroundColor: Colors.grey[200],
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = filter;
                          selectedSubFilter = null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (subFilters[selectedFilter] != null) ...[
                  const Text(
                    '📂 하위 필터',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subFilters[selectedFilter]!.map((sub) {
                      final isSelected = selectedSubFilter == sub;
                      return ChoiceChip(
                        label: Text(
                          sub,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.deepPurpleAccent,
                        backgroundColor: Colors.grey[100],
                        onSelected: (_) {
                          setState(() {
                            selectedSubFilter = sub;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),

          /// 게시물 리스트
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                itemCount: filteredPosts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final post = filteredPosts[index];
                  final color = moodColor(post['moodLabel']);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            post['imageUrl'],
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // 내용 영역을 감정색 배경으로 감싸기
                        Container(
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15), // 감정 컬러 배경 (연하게)
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 위치 + 좋아요
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      post['location'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${post['likes']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // 감정 라벨
                              Row(
                                children: [
                                  Text(
                                    post['mood'],
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    post['moodLabel'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors
                                          .white, // 필요시 custom extension으로
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // 감정 온도계
                              moodTemperatureBar(
                                post['moodTemperature'],
                                color,
                              ),

                              const SizedBox(height: 12),

                              // 제목
                              Text(
                                post['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
