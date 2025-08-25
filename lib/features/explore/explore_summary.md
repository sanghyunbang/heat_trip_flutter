# Flutter 앱에서의 HTTP 통신 흐름

## HTTP 통신이 일어나는 위치

HTTP 통신은 **`PlaceApiHttp`** 클래스 안에서만 발생합니다. 화면과 위젯들은 직접 `http` 패키지를 사용하지 않고, **추상 인터페이스(`PlaceApi`)**를 통해 간접적으로 호출합니다.

## 아키텍처 구조

```
UI Layer (Widgets)
      ↓
ViewModel Layer
      ↓
Repository Layer (Interface)
      ↓
Implementation Layer (HTTP Client)
```

## 호출 흐름 (Call Chain)

### 1. 초기화 단계 - ExploreScreen.initState
```dart
final PlaceApi _api = PlaceApiHttp(client: http.Client());
ExploreScrollVM vm = ExploreScrollVM(api: _api, ...);
```
- HTTP 클라이언트를 생성하고 ViewModel에 의존성 주입(Dependency Injection)

### 2. 사용자 인터랙션 - ExploreScreen
- 사용자가 스크롤을 끝까지 내리면
- `_vm.fetchNext()` 메서드 호출

### 3. 데이터 요청 - ExploreScrollVM.fetchNext()
```dart
// ViewModel에서 API 호출
final result = await api.fetchCursor(
  filters: currentFilters,
  cursor: nextCursor,
  size: pageSize
);
```
- `api`는 `PlaceApi` 타입이지만 실제 인스턴스는 `PlaceApiHttp`

### 4. 실제 HTTP 통신 - PlaceApiHttp.fetchCursor()
```dart
// URI 구성 및 헤더 설정
final uri = Uri.parse('$baseUrl/places').replace(queryParameters: params);
final response = await _client.get(uri, headers: headers);
final data = jsonDecode(response.body);
```
- **여기서 진짜 HTTP GET 요청이 실행됨**

### 5. 상태 업데이트 - ExploreScrollVM
```dart
_items.addAll(page.items);
notifyListeners(); // 변경사항 알림
```
- 응답 데이터를 내부 리스트에 추가
- UI에 변경사항 알림

### 6. UI 렌더링 - ExploreScreen.build()
```dart
AnimatedBuilder(
  animation: _vm,
  builder: (context, child) {
    return GridView.builder(
      itemBuilder: (context, index) => PlaceCard(place: _vm.items[index])
    );
  }
)
```
- 변경 알림을 받아 자동으로 다시 빌드
- `_vm.items`를 사용해 `PlaceCard` 위젯들을 렌더링

## Flutter의 의존성 주입 (DI) 방식

🟡 **Flutter는 Spring의 Bean처럼 DI를 기본 제공하지 않음**

Flutter는 기본적으로 **DI 컨테이너**가 없습니다. 하지만 개발자가 원하면 **DI를 구현하거나 도구를 사용할 수 있습니다.**

### 🔧 Flutter에서 DI를 구현하는 3가지 방식

#### 1. **생성자 주입 (Constructor Injection)** ⭐ **현재 프로젝트에서 사용 중**
가장 기본적인 방식으로, 직접 객체를 넘겨주는 형태입니다.

```dart
class ExploreScrollVM {
  final PlaceApi api;
  
  ExploreScrollVM({required this.api});  // 생성자로 주입
}

// 사용 예시 (현재 프로젝트 방식)
final PlaceApi _api = PlaceApiHttp(client: http.Client());
final vm = ExploreScrollVM(api: _api);
```

#### 2. **Provider 패키지 사용 (가장 널리 사용)**
Flutter에서 가장 널리 쓰이는 DI + 상태관리 도구입니다.

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<PlaceApi>(create: (_) => PlaceApiHttp()),
        ChangeNotifierProvider<ExploreScrollVM>(
          create: (context) => ExploreScrollVM(
            api: context.read<PlaceApi>()
          )
        ),
      ],
      child: MyApp(),
    ),
  );
}

// 사용할 때
final vm = Provider.of<ExploreScrollVM>(context);
```

#### 3. **GetIt 패키지 사용 (Spring Bean과 가장 유사)**
**서비스 로케이터 패턴**을 사용해서 전역에서 인스턴스를 등록하고 사용합니다.

```dart
final getIt = GetIt.instance;

void setupDI() {
  // Spring의 @Bean 등록과 유사
  getIt.registerSingleton<PlaceApi>(PlaceApiHttp());
  getIt.registerFactory<ExploreScrollVM>(
    () => ExploreScrollVM(api: getIt<PlaceApi>())
  );
}

// 사용할 때 (Spring의 ApplicationContext.getBean()과 유사)
final api = getIt<PlaceApi>();
final vm = getIt<ExploreScrollVM>();
```

### 현재 프로젝트 vs Spring Bean 비교

| 구분 | 현재 프로젝트 (생성자 주입) | Spring Bean |
|------|---------------------------|-------------|
| **등록 방식** | 수동으로 `new` 키워드로 생성 | `@Component`, `@Bean` 어노테이션으로 자동 등록 |
| **주입 방식** | 생성자에서 직접 전달 | `@Autowired`로 자동 주입 |
| **생명주기** | 개발자가 직접 관리 | Spring 컨테이너가 자동 관리 |
| **스코프** | 수동으로 싱글톤/프로토타입 구현 | `@Singleton`, `@Prototype` 등으로 선언적 관리 |

```dart
// 현재 방식 (수동 DI)
class ExploreScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    final PlaceApi _api = PlaceApiHttp(client: http.Client());  // 수동 생성
    _vm = ExploreScrollVM(api: _api);  // 수동 주입
  }
}
```

```java
// Spring 방식 (자동 DI)
@Controller
public class ExploreController {
    @Autowired
    private PlaceApi placeApi;  // 자동 주입
    
    @Autowired  
    private ExploreScrollVM vm; // 자동 주입
}
```

### 🔄 현재 프로젝트의 DI 흐름

```
ExploreScreen.initState()
    ↓
PlaceApiHttp 인스턴스 생성 (http.Client 주입)
    ↓
ExploreScrollVM 생성 (PlaceApi 주입)
    ↓
화면에서 ViewModel 사용
```

**장점**: 
- 심플하고 명확함
- 외부 패키지 의존성 없음
- 테스트 시 Mock 객체 주입 용이

**단점**: 
- 객체 생성/관리를 수동으로 해야 함
- 프로젝트가 커지면 DI 코드가 복잡해짐

## 핵심 포인트

### "여긴 HTTP가 없는데 어떻게 데이터가 표출되나?"에 대한 답

1. **관심사의 분리 (Separation of Concerns)**
   - `ExploreScreen`, `PlaceCard` 같은 UI 위젯 파일에는 HTTP 관련 코드가 없음
   - 네트워크 세부사항을 ViewModel이 추상화해서 처리

2. **반응형 프로그래밍 (Reactive Programming)**
   - ViewModel이 데이터 리스트를 관리
   - 리스트 변경 시 `notifyListeners()`로 UI에 알림
   - UI는 자동으로 새로운 데이터로 다시 그려짐

3. **이미지 네트워킹**
   ```dart
   Image.network(imageUrl) // PlaceCard 내부
   ```
   - HTTP를 명시적으로 호출하지 않아도 내부적으로 네트워크 사용
   - Flutter가 자동으로 이미지 URL에서 데이터를 가져와 표시

## ViewModel이란?

**ViewModel**은 **MVVM(Model-View-ViewModel) 패턴**의 핵심 구성요소로, **UI(View)와 비즈니스 로직(Model) 사이의 중간 다리** 역할을 합니다.

### 🎯 ViewModel의 역할

#### 1. **상태 관리 (State Management)**
```dart
class ExploreScrollVM extends ChangeNotifier {
  List<Place> _items = [];          // 화면에 표시할 데이터
  bool _isLoading = false;          // 로딩 상태
  String? _error;                   // 에러 상태
  
  // getter로 외부에 노출
  List<Place> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
}
```

#### 2. **비즈니스 로직 처리**
```dart
Future<void> fetchNext() async {
  if (_isLoading) return;           // 중복 요청 방지
  
  _setLoading(true);
  try {
    final result = await api.fetchCursor(...);
    _items.addAll(result.items);    // 데이터 추가
    _setLoading(false);
  } catch (e) {
    _setError(e.toString());        // 에러 처리
  }
}
```

#### 3. **View와 Model 연결**
```dart
// View에서 ViewModel 사용
AnimatedBuilder(
  animation: _vm,                   // ViewModel 변화 감지
  builder: (context, child) {
    if (_vm.isLoading) {
      return CircularProgressIndicator();
    }
    return GridView.builder(
      itemCount: _vm.items.length,  // ViewModel 데이터 사용
      itemBuilder: (context, index) => PlaceCard(place: _vm.items[index])
    );
  }
)
```

### 📱 MVVM 패턴 구조

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│     View        │◄──►│   ViewModel      │◄──►│     Model       │
│  (UI Widget)    │    │ (Business Logic) │    │ (Data/API)      │
├─────────────────┤    ├──────────────────┤    ├─────────────────┤
│ ExploreScreen   │    │ ExploreScrollVM  │    │ PlaceApiHttp    │
│ PlaceCard       │    │ - _items         │    │ Place (Entity)  │
│ GridView        │    │ - _isLoading     │    │ http.Client     │
│                 │    │ - fetchNext()    │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### 🔄 ViewModel의 데이터 흐름

#### **단방향 데이터 흐름**
1. **View → ViewModel**: 사용자 액션 (스크롤, 버튼 클릭)
2. **ViewModel → Model**: 데이터 요청 (API 호출)
3. **Model → ViewModel**: 응답 데이터 전달
4. **ViewModel → View**: 상태 변경 알림 (`notifyListeners()`)

```dart
// 1. View에서 사용자 액션
onTap: () => _vm.fetchNext(),

// 2. ViewModel에서 Model 호출  
Future<void> fetchNext() async {
  final result = await api.fetchCursor(...);  // Model 호출
  
// 3. 상태 업데이트 및 View 알림
  _items.addAll(result.items);
  notifyListeners();  // View에 변경 알림
}
```

### ⚖️ ViewModel vs 다른 패턴 비교

| 패턴 | View의 역할 | 비즈니스 로직 위치 | 상태 관리 |
|------|------------|------------------|----------|
| **MVC** | Controller와 직접 통신 | Controller | Controller |
| **MVP** | Presenter에 의존 | Presenter | Presenter |
| **MVVM** | ViewModel 관찰 | ViewModel | ViewModel |

### 🎁 ViewModel의 장점

#### 1. **관심사의 분리 (Separation of Concerns)**
```dart
// ❌ 나쁜 예: View에 비즈니스 로직이 섞임
class ExploreScreen extends StatefulWidget {
  void _loadData() async {
    final response = await http.get(...);  // HTTP 직접 호출
    final data = jsonDecode(response.body); // JSON 파싱
    setState(() => items = data);           // 상태 업데이트
  }
}

// ✅ 좋은 예: ViewModel로 분리
class ExploreScreen extends StatefulWidget {
  void _loadData() => _vm.fetchNext();     // 단순한 호출만
}
```

#### 2. **테스트 용이성**
```dart
// ViewModel 단위 테스트 가능
test('fetchNext should add items to list', () async {
  final mockApi = MockPlaceApi();
  final vm = ExploreScrollVM(api: mockApi);
  
  await vm.fetchNext();
  
  expect(vm.items.length, 10);
  expect(vm.isLoading, false);
});
```

#### 3. **재사용성**
- 같은 ViewModel을 여러 View에서 사용 가능
- 플랫폼별 UI는 다르지만 비즈니스 로직은 공유

### 🚨 주의사항

#### **ViewModel은 View를 몰라야 함**
```dart
// ❌ 나쁜 예: ViewModel이 View를 직접 참조
class ExploreScrollVM {
  BuildContext? context;  // View 참조 ❌
  
  void showDialog() {
    showDialog(context: context!, ...);  // View 조작 ❌
  }
}

// ✅ 좋은 예: 상태만 관리, View 조작은 View가 담당
class ExploreScrollVM {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;  // 상태만 노출
  
  void clearError() => _errorMessage = null;
}
```

## 데이터 흐름 요약

```
사용자 스크롤 
    ↓
UI 이벤트 감지
    ↓
ViewModel.fetchNext()
    ↓
PlaceApi.fetchCursor() (인터페이스)
    ↓
PlaceApiHttp.fetchCursor() (구현체)
    ↓
http.Client.get() (실제 HTTP 요청)
    ↓
JSON 응답 파싱
    ↓
ViewModel 상태 업데이트
    ↓
notifyListeners()
    ↓
UI 자동 재빌드
    ↓
새로운 PlaceCard들 렌더링
```

이러한 구조를 통해 **단일 책임 원칙**을 지키면서, UI 코드를 네트워크 로직으로부터 완전히 분리할 수 있습니다.