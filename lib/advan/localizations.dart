import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class EwLocalizations {
  EwLocalizations(this.locale);

  final Locale locale;

  static EwLocalizations of(BuildContext context) {
    return Localizations.of(context, EwLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title':'-bank'
    },
    'zh': {
      'title':'负行'
    }
  };

  String get title {
    return _localizedValues[locale.languageCode]['title'];
  }
}

class EwLocalizationDelegate extends LocalizationsDelegate<EwLocalizations> {
  const EwLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<EwLocalizations> load(Locale locale) {
    return SynchronousFuture<EwLocalizations>(EwLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<EwLocalizations> old) => false;
}