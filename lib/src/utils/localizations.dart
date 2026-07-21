import 'package:flutter/cupertino.dart';
import 'package:food_user_application/generated/l10n/app_localizations.dart';

extension LocalizationsExtension on BuildContext {
  AppLocalizations get localization => AppLocalizations.of(this)!;
}