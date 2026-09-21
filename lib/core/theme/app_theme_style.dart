enum AppThemeStyle {
  vault,
  lumi,
}

extension AppThemeStyleX on AppThemeStyle {
  String get displayNameTh {
    switch (this) {
      case AppThemeStyle.vault:
        return 'VAULT';
      case AppThemeStyle.lumi:
        return 'Lumi';
    }
  }

  String get displayNameEn {
    switch (this) {
      case AppThemeStyle.vault:
        return 'VAULT';
      case AppThemeStyle.lumi:
        return 'Lumi';
    }
  }
}
