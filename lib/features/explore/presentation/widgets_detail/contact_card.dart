/// contact_card.dart
/// - 주소/전화/홈페이지 렌더링
/// - '길찾기'는 Google Maps 웹 호출
/// - 전화번호는 숫자만 추출 후 tel: 스킴으로 연결
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entity_detail/place_detail.dart';

class ContactCard extends StatelessWidget {
  final PlaceDetail detail;
  const ContactCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    // 홈페이지 문자열에는 <a href="...">...</a> 형태가 섞여 들어올 수 있어 href를 우선 추출
    final homepageRaw = (detail.detailRaw['homepage'] ?? '').toString();
    final homepageHref =
        RegExp(r'href=\"([^\"]+)\"').firstMatch(homepageRaw)?.group(1) ??
        homepageRaw.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '연락처 및 위치',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            // 주소
            if ((detail.address ?? '').isNotEmpty)
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(detail.address!)),
                ],
              ),

            // 문의전화 (infocenter)
            if ((detail.detailRaw['infocenter'] ?? '')
                .toString()
                .isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.call_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(detail.detailRaw['infocenter'].toString()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () {
                      final tel = detail.detailRaw['infocenter']
                          .toString()
                          .replaceAll(RegExp(r'[^0-9]'), ''); // 숫자만
                      if (tel.isNotEmpty) launchUrl(Uri.parse('tel:$tel'));
                    },
                    tooltip: '전화걸기',
                  ),
                ],
              ),
            ],

            // 홈페이지 링크
            if (homepageHref.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.public, size: 18, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(child: Text(homepageHref)),
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () => launchUrl(
                      Uri.parse(homepageHref),
                      mode: LaunchMode.externalApplication,
                    ),
                    tooltip: '브라우저로 열기',
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            // 액션 버튼 (길찾기 / 전화하기)
            Row(
              children: [
                // 길찾기: lat/lon이 있을 때만 활성화
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.navigation),
                    label: const Text('길찾기'),
                    onPressed: (detail.lat != null && detail.lon != null)
                        ? () {
                            final lat = detail.lat!;
                            final lon = detail.lon!;
                            launchUrl(
                              Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
                              ),
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.phone),
                    label: const Text('전화하기'),
                    onPressed: () {
                      final tel = (detail.detailRaw['infocenter'] ?? '')
                          .toString()
                          .replaceAll(RegExp(r'[^0-9]'), '');
                      if (tel.isNotEmpty) launchUrl(Uri.parse('tel:$tel'));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
