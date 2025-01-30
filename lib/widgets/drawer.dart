import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_nepse_calculator/main.dart';
import 'package:easy_nepse_calculator/mixins/localization.dart';
import 'package:easy_nepse_calculator/providers/theme_provider.dart';
import 'package:easy_nepse_calculator/screens/settings.dart';
import 'package:easy_nepse_calculator/services/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

class CustomDrawer extends StatelessWidget {
  final PackageInfo? packageInfo;
  CustomDrawer({super.key, required this.packageInfo});

  final Uri _url = Uri.parse(
      'https://sites.google.com/view/easynepsecalculator-privacy/home');

  @override
  Widget build(BuildContext context) {
    ThemeProvider _themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "assets/icon/dark_logo.webp",
                    ),
                  )),
                  // currentAccountPicture:
                  //     Image.asset("assets/icon/subtle_logo.webp"),
                  accountName: Text(
                    "",
                  ),
                  accountEmail: Text(
                    "",
                  ),
                ),
                ListTile(
                  title: _themeProvider.isDarkMode
                      ? Text(
                          AppLocale.darkTheme.getString(context),
                        )
                      : Text(AppLocale.lightTheme.getString(context)),
                  leading: _themeProvider.isDarkMode
                      ? const Icon(
                          Icons.dark_mode,
                        )
                      : const Icon(Icons.light_mode),
                  onTap: () {
                    _themeProvider.changeTheme(!_themeProvider.isDarkMode);
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  title: Text(
                    AppLocale.changeLanguage.getString(context),
                  ),
                  trailing: Text(
                    localization.currentLocale!.languageCode,
                  ),
                  leading: const Icon(
                    Icons.language_sharp,
                  ),
                  onTap: () async {
                    if (localization.currentLocale?.languageCode == "en") {
                      await _themeProvider.setLanguage("Nepali");
                    } else {
                      await _themeProvider.setLanguage("English");
                    }
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  title: Text(
                    AppLocale.settings.getString(context),
                  ),
                  leading: const Icon(
                    Icons.settings,
                  ),
                  onTap: () {
                    navigateToPage(
                      context: context,
                      pageName: SettingsScreen(),
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  title: Text(
                    AppLocale.privacyPolicy.getString(context),
                  ),
                  leading: const Icon(
                    Icons.privacy_tip,
                  ),
                  onTap: () {
                    _launchUrl(_url);
                  },
                ),
              ],
            ),
          ),
          Divider(height: 0),
          if (packageInfo != null)
            SafeArea(
              top: false,
              child: ListTile(
                title: GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: AutoSizeText(
                    AppLocale.title.getString(context),
                    minFontSize: 12,
                    maxLines: 1,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Flexible(
                      child: InkWell(
                        child: AutoSizeText(
                          packageInfo!.version,
                          maxFontSize: 12,
                          minFontSize: 8,
                          maxLines: 1,
                        ),
                        onTap: () {},
                      ),
                    ),
                    Text(
                      "+",
                    ),
                    Flexible(
                      child: InkWell(
                        child: AutoSizeText(
                          packageInfo!.buildNumber,
                          maxFontSize: 12,
                          minFontSize: 8,
                          maxLines: 1,
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
