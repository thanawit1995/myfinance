import 'package:flutter/material.dart';

class CategoryIconHelper {
  static const Map<String, IconData> iconMap = {
    // อาหารและเครื่องดื่ม (Food & Drinks)
    'fastfood': Icons.fastfood,
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'bakery_dining': Icons.bakery_dining,
    'ramen_dining': Icons.ramen_dining,
    'local_bar': Icons.local_bar,
    'icecream': Icons.icecream,

    // ช้อปปิ้งและของใช้ (Shopping & Goods)
    'shopping_bag': Icons.shopping_bag,
    'shopping_cart': Icons.shopping_cart,
    'checkroom': Icons.checkroom,
    'devices': Icons.devices,
    'storefront': Icons.storefront,
    'face': Icons.face,
    'spa': Icons.spa,

    // การเดินทาง (Transport & Travel)
    'directions_car': Icons.directions_car,
    'local_gas_station': Icons.local_gas_station,
    'directions_bus': Icons.directions_bus,
    'train': Icons.train,
    'two_wheeler': Icons.two_wheeler,
    'flight': Icons.flight,
    'local_taxi': Icons.local_taxi,

    // ที่อยู่อาศัยและบิล (Home & Utilities)
    'home': Icons.home,
    'water_drop': Icons.water_drop,
    'electric_bolt': Icons.electric_bolt,
    'wifi': Icons.wifi,
    'phone_android': Icons.phone_android,
    'receipt_long': Icons.receipt_long,
    'receipt': Icons.receipt,

    // สุขภาพและการศึกษา (Health & Education)
    'local_hospital': Icons.local_hospital,
    'medication': Icons.medication,
    'school': Icons.school,
    'menu_book': Icons.menu_book,
    'fitness_center': Icons.fitness_center,
    'sports_soccer': Icons.sports_soccer,

    // บันเทิงและไลฟ์สไตล์ (Entertainment & Pets)
    'movie': Icons.movie,
    'sports_esports': Icons.sports_esports,
    'pets': Icons.pets,
    'card_giftcard': Icons.card_giftcard,
    'volunteer_activism': Icons.volunteer_activism,
    'music_note': Icons.music_note,
    'camera_alt': Icons.camera_alt,

    // รายรับและการเงิน (Income & Savings)
    'payments': Icons.payments,
    'savings': Icons.savings,
    'trending_up': Icons.trending_up,
    'account_balance': Icons.account_balance,
    'work': Icons.work,
    'business_center': Icons.business_center,
    'redeem': Icons.redeem,
    'monetization_on': Icons.monetization_on,
    'currency_exchange': Icons.currency_exchange,

    // ทั่วไป (General)
    'category': Icons.category,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'attach_money': Icons.attach_money,
  };

  static const Map<String, List<String>> categorizedIcons = {
    'อาหาร & เครื่องดื่ม': [
      'fastfood',
      'restaurant',
      'local_cafe',
      'bakery_dining',
      'ramen_dining',
      'local_bar',
      'icecream',
    ],
    'ช้อปปิ้ง & ไลฟ์สไตล์': [
      'shopping_bag',
      'shopping_cart',
      'checkroom',
      'devices',
      'storefront',
      'face',
      'spa',
    ],
    'การเดินทาง': [
      'directions_car',
      'local_gas_station',
      'directions_bus',
      'train',
      'two_wheeler',
      'flight',
      'local_taxi',
    ],
    'บ้าน & บิลสาธารณูปโภค': [
      'home',
      'water_drop',
      'electric_bolt',
      'wifi',
      'phone_android',
      'receipt_long',
      'receipt',
    ],
    'สุขภาพ & กีฬา & การเรียน': [
      'local_hospital',
      'medication',
      'school',
      'menu_book',
      'fitness_center',
      'sports_soccer',
    ],
    'บันเทิง & สัตว์เลี้ยง & ให้': [
      'movie',
      'sports_esports',
      'pets',
      'card_giftcard',
      'volunteer_activism',
      'music_note',
      'camera_alt',
    ],
    'รายรับ & การลงทุน': [
      'payments',
      'savings',
      'trending_up',
      'account_balance',
      'work',
      'business_center',
      'redeem',
      'monetization_on',
      'currency_exchange',
    ],
    'ทั่วไป': [
      'category',
      'star',
      'favorite',
      'attach_money',
    ],
  };

  static List<String> get allIcons => iconMap.keys.toList();

  static IconData getIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.category;
    }
    return iconMap[iconName] ?? Icons.category;
  }
}
