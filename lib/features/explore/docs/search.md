홈 화면 상단 검색바 관련

<home_screen 관련>

1.컨트롤러/포커스 선언 (상태 보관) — HomeScreenState
```
final _searchCtrl = TextEditingController();
final _searchFocus = FocusNode();
```

2. 검색바에 상태/콜백 주입 — SliverToBoxAdapter에서
```
_HeroWithSearchBar(
  ...
  searchCtrl: _searchCtrl,
  searchFocus: _searchFocus,
  onSubmitted: (q) => _goExplore(qp: {'q': q}),
)

```

3. 검색바 UI 본체 — _HeroWithSearchBar.build의 Stack 안 Positioned(top: ...)

```
Positioned(
  left: 16, right: 16, top: paddingTop + 8,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.35),
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: searchCtrl,         // ← (1)에서 받은 컨트롤러
          focusNode: searchFocus,         // ← (1)에서 받은 포커스
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,       // ← (2)에서 전달된 제출 콜백
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '아이디어 검색',
            prefixIcon: Icon(Icons.search, color: Colors.white),
            suffixIcon: Icon(Icons.tune, color: Colors.white),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    ),
  ),
)

```