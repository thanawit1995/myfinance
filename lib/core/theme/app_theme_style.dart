enum AppThemeStyle {
  vault,
  lumi,
}

extension AppThemeStyleX on AppThemeStyle {
  String get displayNameTh {
    switch (this) {
      case AppThemeStyle.vault:
        return 'VAULT (เรียบหรู คลาสสิก)';
      case AppThemeStyle.lumi:
        return 'Lumi (สดใส อบอุ่น Sunny Bloom)';
    }
  }

  String get displayNameEn {
    switch (this) {
      case AppThemeStyle.vault:
        return 'VAULT (Quiet Luxury)';
      case AppThemeStyle.lumi:
        return 'Lumi (Sunny Bloom)';
    }
  }
}
