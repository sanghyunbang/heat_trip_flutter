// lib/features/foryou/presentation/screens/foryou_screen.dart

/// ─────────────────────────────────────────────────────────────────────────────
/// ForYouScreen  [Screen]
/// 역할:
///   - "For You" 추천 리스트 화면의 컨테이너(페이지).
///   - 데이터 로딩 트리거(초기/당겨서 새로고침), 리스트 렌더링, 상세 라우팅 처리.
/// 입력:
///   - [contextModel] : 추천 컨텍스트(도메인 모델, DTO 아님)
///   - [k]            : 추천 개수(Top-K)
/// 출력:
///   - 없음. UI 렌더링과 사용자 액션을 VM(ViewModel)에 위임.
/// 의존:
///   - 상태 관리: Provider + ChangeNotifier(ForYouVM)
///   - 라우팅: go_router (push + path params + extra 전달)
///   - 위젯: KPicker / ContextSummary / CategoryCard / SkeletonCard / ErrorView
/// 데이터/이벤트 흐름(핵심):
///   1) initState → VM.load(contextModel, k) : 비동기로 추천 요청
///   2) VM.loading / VM.error / VM.items 에 따라 3가지 UI 상태 전환
///   3) 카드 가시성/탭 이벤트를 VM으로 위임(onCardVisible / onCardInvisible / onTap)
/// 설계 팁:
///   - *presentation*은 항상 *domain* 인터페이스와 도메인 엔티티만 의존합니다.
///     (DTO/HTTP/REST 등 data 레이어 세부는 모름)
///   - 화면(Screen)의 세부 UI 조각은 widgets/로 분리(재사용/가독성 ↑)
///   - 라우팅 시, 동일한 도메인 Context를 extra로 넘겨 상세에서 보상 계산 일관성 유지
/// ─────────────────────────────────────────────────────────────────────────────

import 'dart:ui'; // FontFeature 등(고정폭 숫자 표시 등) 사용 가능. 여기서는 애니메이션/텍스트 옵션용.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // .animate().fadeIn() 등 문법용
import 'package:go_router/go_router.dart'; // 화면 전환/URL 라우팅
import 'package:provider/provider.dart'; // DI + 상태 주입/구독

// 도메인 엔티티(컨텍스트). DTO가 아닌 '순수 도메인' 타입에 의존해야 함.
import 'package:heat_trip_flutter/features/foryou/domain/entities/context.dart'
    as dom;

// ViewModel (주의: 폴더명이 state/states 중 프로젝트 규칙에 맞추세요)
import '../states/foryou_vm.dart';

// 화면에서 사용하는 재사용 위젯들
import '../widgets/k_picker.dart';
import '../widgets/context_summary.dart';
import '../widgets/category_card.dart';
import '../widgets/skeleton_card.dart';
import '../widgets/error_view.dart';

/// StatefulWidget인 이유:
///   - initState에서 최초 로딩 트리거를 걸기 위함
///   - 스크린 자체가 VM을 소유하진 않지만(Provider가 소유), 스크린 생명주기에 맞춘
///     초기 작업(Future.microtask)이 필요하기 때문
class ForYouScreen extends StatefulWidget {
  final dom.Context contextModel; // 추천 컨텍스트(도메인 모델)
  final int k; // Top-K (세그먼트 버튼으로 변경 가능)

  const ForYouScreen({super.key, required this.contextModel, this.k = 8});

  // statefulWidget은 createState() 오버라이드 필수
  // _ForYouScreenState 클래스의 인스턴스를 반환
  // 실제 UI 구성과 상태 관리는 이 State 클래스에서 수행
  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  @override
  void initState() {
    super.initState();

    // [!]initState에서는 context.read<T>() 사용 시, 곧바로 setState/notifyListeners가
    //    발생하면 프레임 타이밍 이슈가 있을 수 있음.
    //    → Future.microtask로 다음 이벤트 루프로 미룸(안전).
    //    → 또는 addPostFrameCallback을 사용해도 OK.
    Future.microtask(
      () => context.read<ForYouVM>().load(widget.contextModel, k: widget.k),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider가 주입한 ForYouVM을 구독(watch)하여 상태 변화 시 위젯이 리빌드됨.
    final vm = context.watch<ForYouVM>();

    return Scaffold(
      // Pull-to-refresh : 당겨서 새로고침 시에도 같은 컨텍스트 기준으로 재요청
      body: RefreshIndicator(
        onRefresh: () => context.read<ForYouVM>().load(widget.contextModel),

        // Sliver 기반 스크롤 화면 구성(상단 AppBar + 리스트)
        child: CustomScrollView(
          slivers: [
            // 상단 app bar (floating+snap로 스크롤에 따라 자연스럽게 등장/숨김)
            SliverAppBar(
              floating: true, // 스크롤 올리면 바로 나타남
              snap: true, // floating과 함께 사용 시, '툭' 하고 고정
              title: const Text(
                'For You',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),

              // 오른쪽 액션 영역: K값(Top-K) 변경 위젯.
              // K를 바꾸면 VM.load(context, k: v)로 재로딩.
              actions: [
                KPicker(
                  value: vm.k,
                  onChanged: (v) =>
                      context.read<ForYouVM>().load(widget.contextModel, k: v),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // 현재 컨텍스트 요약 칩(도메인 컨텍스트 표시, UI 컨테이너 포함)
            SliverToBoxAdapter(child: ContextSummary(ctx: widget.contextModel)),

            // ① 로딩 상태: 스켈레톤 카드 여러 개 표시
            if (vm.loading)
              SliverList.builder(
                itemCount: 6, // 스켈레톤 개수는 UI 취향/가로세로 비율에 맞게 조정
                itemBuilder: (_, __) =>
                    const SkeletonCard().animate().fadeIn(duration: 300.ms),
              )
            // ② 오류 상태: ErrorView + 재시도 버튼
            else if (vm.error != null)
              SliverFillRemaining(
                hasScrollBody: false, // 남은 화면 채우기(가운데 정렬 목적)
                child: ErrorView(
                  message: vm.error.toString(),
                  onRetry: () =>
                      context.read<ForYouVM>().load(widget.contextModel),
                ).animate().fadeIn(duration: 250.ms),
              )
            // ③ 정상 데이터 상태: 추천 리스트
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(
                          0xFFEBE2CD,
                        ).withOpacity(.8), // bg-200 톤
                        width: .8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상단 제목
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                          child: Text(
                            '추천 카테고리',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF353535), // text-100
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0x15000000)),

                        // 텍스트 중심 행(Row) 스타일의 CategoryCard 목록
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: vm.items.length,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: Color(0x14000000),
                          ),
                          itemBuilder: (_, i) {
                            final item = vm.items[i];

                            return CategoryCard(
                                  item: item,
                                  onVisible: () =>
                                      vm.onCardVisible(item.category),
                                  onInvisible: () => vm.onCardInvisible(
                                    item.category,
                                    widget.contextModel,
                                  ),
                                  onTap: () {
                                    vm.onTap(item.category);
                                    context.push(
                                      '/foryou/detail/${item.category}',
                                      extra: widget.contextModel,
                                    );
                                  },
                                )
                                .animate()
                                .slideY(begin: .06, end: 0, duration: 200.ms)
                                .fadeIn(duration: 200.ms);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 리스트 하단 여백(탭바/버텀바와 겹치지 않게)
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

/* ────────────────────────────── 자주 하는 실수 / 디버깅 팁 ──────────────────────────────
1) Provider 주입 순서
   - RecSysApi → ForYouRepositoryImpl(ProxyProvider) → ForYouVM(ChangeNotifierProvider)
   - 순서가 바뀌면 read<T>() 시점에 NPE/DI 오류가 납니다.

2) states vs state 폴더
   - import 경로가 실제 폴더와 맞는지 확인하세요.
   - VM 파일 경로만 달라도 분석기 오류 없이 런타임에 못 찾는 경우가 생길 수 있습니다.

3) extra 타입
   - 라우팅(extra)로 넘기는 타입이 dom.Context인지 확인(실수로 DTO 넘기면 캐스팅 예외).
   - 상세 라우트 빌더에서도 (state.extra is dom.Context) 체크로 방어 코드를 두세요.

4) 네트워크 예외(중요!)
   - VM에서 sendFeedback/getTopK 호출부는 try–catch로 감싸 로그만 남기세요.
   - 피드백 전송 실패로 앱이 죽으면 사용자 경험이 안 좋아집니다.

5) 최초 로딩 트리거
   - initState에서 바로 read/load 호출 시 프레임 타이밍 경고가 날 수 있어
     Future.microtask 또는 addPostFrameCallback을 활용합니다.

6) 스크롤 성능
   - SliverList.builder는 아이템을 필요할 때만 그려 메모리 효율적.
   - 카드에 무거운 이미지가 많다면 캐시/프리페치 전략 고려.

7) 애니메이션
   - flutter_animate는 체이닝 문법으로 간단히 효과를 줄 수 있지만,
     과하면 성능 저하. 짧고 가벼운 duration/offset을 추천합니다.
────────────────────────────────────────────────────────────────────────────── */
