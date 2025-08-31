/// detail_spec.dart
/// contentType별로 보여줄 필드 목록(키/라벨/아이콘/포맷터)을 정의
import 'package:flutter/material.dart';
import 'content_type.dart';
import 'field_descriptor.dart';

final Map<ContentType, List<FieldDescriptor>> detailSpec = {
  // 12 관광지
  ContentType.attraction: const [
    FieldDescriptor(key: 'infocenter', label: '문의/안내', icon: Icons.phone),
    FieldDescriptor(key: 'restdate', label: '쉬는날', icon: Icons.event_busy),
    FieldDescriptor(key: 'usetime', label: '이용시간', icon: Icons.schedule),
    FieldDescriptor(
      key: 'parking',
      label: '주차시설',
      icon: Icons.local_parking,
      format: stripHtml,
    ),
    FieldDescriptor(
      key: 'chkbabycarriage',
      label: '유모차대여',
      icon: Icons.stroller,
      format: yn,
    ),
    FieldDescriptor(
      key: 'chkcreditcard',
      label: '신용카드',
      icon: Icons.credit_card,
      format: yn,
    ),
    FieldDescriptor(key: 'chkpet', label: '반려동물', icon: Icons.pets),
    FieldDescriptor(
      key: 'heritage1',
      label: '세계문화유산',
      icon: Icons.public,
      format: yn,
    ),
    FieldDescriptor(
      key: 'heritage2',
      label: '세계자연유산',
      icon: Icons.public,
      format: yn,
    ),
    FieldDescriptor(
      key: 'heritage3',
      label: '세계기록유산',
      icon: Icons.public,
      format: yn,
    ),
  ],

  // 14 문화시설
  ContentType.culture: const [
    FieldDescriptor(
      key: 'infocenterculture',
      label: '문의/안내',
      icon: Icons.phone,
    ),
    FieldDescriptor(key: 'usetimeculture', label: '이용시간', icon: Icons.schedule),
    FieldDescriptor(key: 'usefee', label: '이용요금', icon: Icons.payments),
    FieldDescriptor(
      key: 'parkingculture',
      label: '주차시설',
      icon: Icons.local_parking,
    ),
    FieldDescriptor(
      key: 'restdateculture',
      label: '쉬는날',
      icon: Icons.event_busy,
    ),
    FieldDescriptor(
      key: 'discountinfo',
      label: '할인정보',
      icon: Icons.local_offer,
    ),
  ],

  // 15 행사/공연/축제
  ContentType.festival: const [
    FieldDescriptor(key: 'eventstartdate', label: '시작일', icon: Icons.event),
    FieldDescriptor(
      key: 'eventenddate',
      label: '종료일',
      icon: Icons.event_available,
    ),
    FieldDescriptor(key: 'eventplace', label: '행사장소', icon: Icons.place),
    FieldDescriptor(key: 'eventhomepage', label: '홈페이지', icon: Icons.link),
    FieldDescriptor(key: 'playtime', label: '공연시간', icon: Icons.schedule),
    FieldDescriptor(key: 'program', label: '프로그램', icon: Icons.list),
    FieldDescriptor(
      key: 'usetimefestival',
      label: '이용요금',
      icon: Icons.payments,
    ),
  ],

  // 25 여행코스
  ContentType.course: const [
    FieldDescriptor(key: 'distance', label: '총거리', icon: Icons.timeline),
    FieldDescriptor(key: 'taketime', label: '총소요시간', icon: Icons.schedule),
    FieldDescriptor(key: 'theme', label: '테마', icon: Icons.style),
    FieldDescriptor(key: 'schedule', label: '코스일정', icon: Icons.route),
    FieldDescriptor(
      key: 'infocentertourcourse',
      label: '문의/안내',
      icon: Icons.phone,
    ),
  ],

  // 28 레포츠
  ContentType.leports: const [
    FieldDescriptor(
      key: 'infocenterleports',
      label: '문의/안내',
      icon: Icons.phone,
    ),
    FieldDescriptor(key: 'usetimeleports', label: '이용시간', icon: Icons.schedule),
    FieldDescriptor(key: 'usefeeleports', label: '입장료', icon: Icons.payments),
    FieldDescriptor(key: 'openperiod', label: '개장기간', icon: Icons.event),
    FieldDescriptor(
      key: 'reservation',
      label: '예약안내',
      icon: Icons.event_available,
    ),
  ],

  // 32 숙박
  ContentType.lodging: const [
    FieldDescriptor(key: 'checkintime', label: '입실시간', icon: Icons.login),
    FieldDescriptor(key: 'checkouttime', label: '퇴실시간', icon: Icons.logout),
    FieldDescriptor(key: 'roomcount', label: '객실수', icon: Icons.hotel),
    FieldDescriptor(key: 'roomtype', label: '객실유형', icon: Icons.meeting_room),
    FieldDescriptor(
      key: 'parkinglodging',
      label: '주차시설',
      icon: Icons.local_parking,
    ),
    FieldDescriptor(
      key: 'reservationurl',
      label: '예약안내(홈페이지)',
      icon: Icons.link,
    ),
    FieldDescriptor(
      key: 'barbecue',
      label: '바비큐장',
      icon: Icons.outdoor_grill,
      format: yn,
    ),
    FieldDescriptor(
      key: 'sauna',
      label: '사우나',
      icon: Icons.hot_tub,
      format: yn,
    ),
    FieldDescriptor(
      key: 'fitness',
      label: '휘트니스',
      icon: Icons.fitness_center,
      format: yn,
    ),
    FieldDescriptor(key: 'refundregulation', label: '환불규정', icon: Icons.rule),
  ],

  // 38 쇼핑
  ContentType.shopping: const [
    FieldDescriptor(
      key: 'infocentershopping',
      label: '문의/안내',
      icon: Icons.phone,
    ),
    FieldDescriptor(key: 'opentime', label: '영업시간', icon: Icons.schedule),
    FieldDescriptor(
      key: 'restdateshopping',
      label: '쉬는날',
      icon: Icons.event_busy,
    ),
    FieldDescriptor(key: 'saleitem', label: '판매품목', icon: Icons.shopping_bag),
    FieldDescriptor(
      key: 'saleitemcost',
      label: '품목별 가격',
      icon: Icons.attach_money,
    ),
    FieldDescriptor(key: 'shopguide', label: '매장안내', icon: Icons.store),
  ],

  // 39 음식점
  ContentType.food: const [
    FieldDescriptor(key: 'firstmenu', label: '대표메뉴', icon: Icons.restaurant),
    FieldDescriptor(key: 'opentimefood', label: '영업시간', icon: Icons.schedule),
    FieldDescriptor(key: 'restdatefood', label: '쉬는날', icon: Icons.event_busy),
    FieldDescriptor(key: 'infocenterfood', label: '문의/안내', icon: Icons.phone),
    FieldDescriptor(
      key: 'parkingfood',
      label: '주차시설',
      icon: Icons.local_parking,
    ),
    FieldDescriptor(
      key: 'packing',
      label: '포장가능',
      icon: Icons.shopping_bag,
      format: yn,
    ),
    FieldDescriptor(key: 'lcnsno', label: '인허가번호', icon: Icons.badge),
  ],
};
