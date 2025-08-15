import 'package:flutter/material.dart';
import '../../data/curation_local_data_source.dart';
import '../../data/curation_repository_impl.dart';
import '../../domain/entities.dart';

/// WHAT: 저장된 선택을 요약해서 보여주는 결과 화면
class CurationResultScreen extends StatefulWidget {
  const CurationResultScreen({super.key});

  @override
  State<CurationResultScreen> createState() => _CurationResultScreenState();
}

class _CurationResultScreenState extends State<CurationResultScreen> {
  UserSelection? selection;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = CurationRepositoryImpl(CurationLocalDataSource());
    final s = await repo.load();
    setState(() => selection = s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('큐레이션 결과')),
      body: selection == null
          ? const Center(child: Text('저장된 선택이 없습니다.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('선택 요약', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    'PAD: P=${selection!.pad.pleasure}, A=${selection!.pad.arousal}, D=${selection!.pad.dominance}',
                  ),
                  Text('하위 감정: ${selection!.subEmotionEnglish ?? '-'}'),
                  Text('여행 목적: ${selection!.travelPurpose ?? '-'}'),
                  const SizedBox(height: 8),
                  Text('환경:'),
                  Text(' - 공간: ${selection!.environment.space ?? '-'}'),
                  Text(' - 사회성: ${selection!.environment.sociality ?? '-'}'),
                  Text(' - 소음도: ${selection!.environment.noise ?? '-'}'),
                  Text(' - 혼잡도: ${selection!.environment.congestion ?? '-'}'),
                  Text(
                    ' - 실내/실외: ${selection!.environment.indoorOutdoor ?? '-'}',
                  ),
                  const Spacer(),
                  const Text('TODO: 이곳에서 추천 로직/백엔드 연동으로 결과 리스트를 노출하세요.'),
                ],
              ),
            ),
    );
  }
}
