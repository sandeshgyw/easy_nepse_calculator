import 'package:easy_nepse_calculator/main.dart';
import 'package:easy_nepse_calculator/mixins/localization.dart';
import 'package:easy_nepse_calculator/providers/calculation_provider.dart';
import 'package:easy_nepse_calculator/providers/theme_provider.dart';
import 'package:easy_nepse_calculator/services/hive.dart';
import 'package:easy_nepse_calculator/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Global settings
  // bool showCommission = true;
  // bool showWacc = true;
  // bool showProfitLoss = true;

  String get selectedLanguage =>
      hive.getString("language") == "" ? "English" : hive.getString("language");

  bool get showCommissionBuy => hive.getBool("showCommissionBuy");
  bool get showWacc => hive.getBool("showWaccBuy");
  bool get showCommissionSell => hive.getBool("showCommissionSell");
  bool get showCapitalGain => hive.getBool("showCapitalGainSell");
  bool get showNetProfit => hive.getBool("showProfitLossSell");

  @override
  Widget build(BuildContext context) {
    CalculationProvider calculationProvider =
        Provider.of<CalculationProvider>(context);
    ThemeProvider _themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocale.settings.getString(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: Text(
                AppLocale.appearance.getString(context),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: Text(AppLocale.darkTheme.getString(context)),
              subtitle: Text(AppLocale.enableDarkTheme.getString(context)),
              value: _themeProvider.isDarkMode,
              onChanged: (value) {
                _themeProvider.changeTheme(value);
              },
            ),

            // Language Section
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                AppLocale.language.getString(context),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(AppLocale.appLanguage.getString(context)),
              subtitle: Text(AppLocale.selectLanguage.getString(context)),
              trailing: DropdownButton<String>(
                value: selectedLanguage,
                items: const [
                  DropdownMenuItem(value: "English", child: Text("English")),
                  DropdownMenuItem(value: "Nepali", child: Text("नेपाली")),
                ],
                onChanged: (value) async {
                  await _themeProvider.setLanguage(value!);
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
