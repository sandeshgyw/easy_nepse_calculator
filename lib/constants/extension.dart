import 'package:easy_nepse_calculator/mixins/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';

extension NumExtensions on num {
  String toCurrency(BuildContext context) {
    return NumberFormat.currency(
      decimalDigits: 2,
      symbol: AppLocale.currencySymbol.getString(context),
    ).format(this).replaceAll(".00", '');
  }
}
