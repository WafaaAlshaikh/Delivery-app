import 'package:flutter/material.dart';

class AppLocalizations {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'app_name': 'PickNGo',
      'features': 'Features',
      'how_it_works': 'How It Works',
      'for_you': 'For You',
      'stores': 'Stores',
      'log_in': 'Log in',
      'get_started': 'Get Started',
      'fast_delivery': 'Fast delivery from local stores',
      'headline': 'Everything you need,\ndelivered',
      'description': 'Shop from restaurants, supermarkets, pharmacies, bookstores, and more — all in one place.',
      'browse_stores': 'Browse Stores',
      'view_categories': 'View Categories',
      'language_en': 'English',
      'language_ar': 'العربية',
      'language_fr': 'Français',
    },
    'ar': {
      'app_name': 'بيك إن قو',
      'features': 'الميزات',
      'how_it_works': 'كيف تعمل',
      'for_you': 'لك',
      'stores': 'المحلات',
      'log_in': 'تسجيل دخول',
      'get_started': 'ابدأ الآن',
      'fast_delivery': 'توصيل سريع من المحلات المحلية',
      'headline': 'كل ما تحتاجه،\nيُوصَل إليك',
      'description': 'تسوق من المطاعم، السوبرماركت، الصيدليات، المكتبات والمزيد — في مكان واحد.',
      'browse_stores': 'تصفح المتاجر',
      'view_categories': 'عرض الفئات',
      'language_en': 'English',
      'language_ar': 'العربية',
      'language_fr': 'Français',
    },
    'fr': {
      'app_name': 'PickNGo',
      'features': 'Fonctionnalités',
      'how_it_works': 'Comment ça marche',
      'for_you': 'Pour vous',
      'stores': 'Magasins',
      'log_in': 'Se connecter',
      'get_started': 'Commencer',
      'fast_delivery': 'Livraison rapide des commerces locaux',
      'headline': 'Tout ce dont vous avez besoin,\nlivré',
      'description': 'Achetez dans des restaurants, supermarchés, pharmacies, librairies et plus — tout en un seul endroit.',
      'browse_stores': 'Parcourir les magasins',
      'view_categories': 'Voir les catégories',
      'language_en': 'English',
      'language_ar': 'العربية',
      'language_fr': 'Français',
    }
  };

  static String t(Locale locale, String key) {
    final lang = locale.languageCode;
    return _translations[lang]?[key] ?? _translations['en']![key] ?? key;
  }
}
