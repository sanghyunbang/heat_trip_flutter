/// contact_card.dart
/// - 주소/전화/홈페이지 렌더링
/// - '길찾기'는 Google Maps 웹 호출
/// - 전화번호는 숫자만 추출 후 tel: 스킴으로 연결
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entity_detail/place_detail.dart';

class ContactCard extends StatelessWidget {
  final PlaceDetail detail;
  final Color? backgroundColor;

  const ContactCard({
    super.key,
    required this.detail,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // 포인트 컬러: #EB9C64
    final p = const Color(0xFFEB9C64);

    // 카드 배경색: 기본 흰색
    final cardBg = backgroundColor ?? Colors.white;
    // 보더 톤은 너무 진하지 않게
    final borderColor = const Color(0xFFEAEAEA);

    // 홈페이지 문자열에는 <a href="...">...</a> 형태가 섞여 들어올 수 있어 href를 우선 추출
    final homepageRaw = (detail.detailRaw['homepage'] ?? '').toString();
    final homepageHref =
        RegExp(r'href=\"([^\"]+)\"').firstMatch(homepageRaw)?.group(1) ??
            homepageRaw.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀 영역
            Row(
              children: [
                Icon(Icons.place),
                const SizedBox(width: 10),
                const Text('연락처 및 위치',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: .6, color: Color(0xFFE9E9E9)),
            const SizedBox(height: 6),

            // 주소
            if ((detail.address ?? '').isNotEmpty)
              _InfoRow(
                icon: Icons.location_on_outlined,
                iconColor: p,
                child: Text(detail.address!, style: const TextStyle(fontSize: 14)),
                onTap: (detail.lat != null && detail.lon != null)
                    ? () => _openMap(detail.lat!, detail.lon!)
                    : null,
                trailing: (detail.lat != null && detail.lon != null)
                    ? IconButton(
                  icon: const Icon(Icons.navigation),
                  color: p,
                  tooltip: '지도로 보기',
                  onPressed: () => _openMap(detail.lat!, detail.lon!),
                )
                    : null,
              ),

            // 문의전화
            if ((detail.detailRaw['infocenter'] ?? '').toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _InfoRow(
                  icon: Icons.call_outlined,
                  iconColor: p,
                  child: Text(
                    detail.detailRaw['infocenter'].toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.phone),
                    color: p,
                    tooltip: '전화걸기',
                    onPressed: () {
                      final tel = detail.detailRaw['infocenter']
                          .toString()
                          .replaceAll(RegExp(r'[^0-9]'), '');
                      if (tel.isNotEmpty) launchUrl(Uri.parse('tel:$tel'));
                    },
                  ),
                ),
              ),

            // 홈페이지
            if (homepageHref.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _InfoRow(
                  icon: Icons.public,
                  iconColor: p,
                  child: _LinkText(
                    homepageHref,
                    color: p,
                    maxLines: 1,
                    onTap: () => _openExternalUrl(homepageHref),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    color: p,
                    tooltip: '브라우저로 열기',
                    onPressed: () => _openExternalUrl(homepageHref),
                  ),
                ),
              ),

            const SizedBox(height: 6),
            const Divider(height: 1, thickness: .6, color: Color(0xFFE9E9E9)),
            const SizedBox(height: 12),

            // 액션 버튼
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.navigation),
                    label: const Text('길찾기'),
                    onPressed: (detail.lat != null && detail.lon != null)
                        ? () => _openMap(detail.lat!, detail.lon!)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: p,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p,
                      side: BorderSide(color: p, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _openMap(double lat, double lon) {
    launchUrl(
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon'),
      mode: LaunchMode.externalApplication,
    );
  }

  static void _openExternalUrl(String url) {
    final safe = url.startsWith('http') ? url : 'https://$url';
    launchUrl(Uri.parse(safe), mode: LaunchMode.externalApplication);
  }
}

/* ───────────────────────── helper widgets ───────────────────────── */

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.child,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(child: child),
        if (trailing != null) trailing!,
      ],
    );

    return onTap == null
        ? row
        : InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: row,
      ),
    );
  }
}

class _IconCapsule extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconCapsule({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _LinkText extends StatelessWidget {
  final String text;
  final Color color;
  final int maxLines;
  final VoidCallback onTap;
  const _LinkText(this.text, {required this.color, this.maxLines = 1, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: color,
          decoration: TextDecoration.underline,
          decorationColor: color.withOpacity(.7),
        ),
      ),
    );
  }
}
