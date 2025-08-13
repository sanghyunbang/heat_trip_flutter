import 'package:flutter/material.dart';
import 'package:heat_trip_flutter/features/explore/domain/entities/place_item.dart';
import 'package:heat_trip_flutter/features/explore/presentation/screens/explore_detail_screen.dart';

class PlaceCard extends StatelessWidget {
  final PlaceItem data;
  const PlaceCard({super.key, required this.data});

  String _safePrefix(String s, int len) {
    if (s.isEmpty) return '';
    if (s.runes.length <= len) return s;
    return String.fromCharCodes(s.runes.take(len));
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        onTap: () {
          // TODO: 상세 화면 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExploreDetailScreen(data: data),
            ),
          );
        },
        child: Stack(
          children: [
            // 1) 카드 전체를 채우는 이미지
            Positioned.fill(
        child: Hero(
        tag: 'place:${data.contentid}', // ✅ 디테일 화면의 Hero tag와 일치해야 함

          child: Image.network(
                data.firstimage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network( // API data에 firstimage가 없는 경우
                    'https://cdn.pixabay.com/photo/2019/07/08/04/23/traveling-4323759_1280.png', // 대체 이미지 주소
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            ),
            // 2) 하단 가독성용 그라데이션
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 110,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.18),
                        Colors.black.withOpacity(0.30),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3) 우상단 +(북마크) 배지
            Positioned(
              right: 10,
              top: 10,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    // TODO: 북마크 처리
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('북마크에 저장완료! (mock)'),
                        behavior: SnackBarBehavior.floating,
                        // margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      ),
                    );
                  },
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(Icons.add, size: 18, color: Colors.blueAccent),
                  ),
                ),
              ),
            ),

            // 4) 하단 텍스트 오버레이(타이틀 + 서브/지역)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'From: ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.70),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _safePrefix(data.addr1, 2),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
