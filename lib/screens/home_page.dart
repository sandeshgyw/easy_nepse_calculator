import 'package:easy_nepse_calculator/mixins/localization.dart';
import 'package:easy_nepse_calculator/screens/bonus_share_screen.dart';
import 'package:easy_nepse_calculator/screens/buy_share_screen.dart';
import 'package:easy_nepse_calculator/screens/reverse_buy_screen.dart';
import 'package:easy_nepse_calculator/screens/reverse_sell_screen.dart';
import 'package:easy_nepse_calculator/screens/right_share_screen.dart';
import 'package:easy_nepse_calculator/screens/sell_share_screen.dart';
import 'package:easy_nepse_calculator/services/navigation.dart';
import 'package:easy_nepse_calculator/widgets/custom_app_bar.dart';
import 'package:easy_nepse_calculator/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PackageInfo? packageInfo;
  @override
  void initState() {
    super.initState();

    getVersionNumber().then((value) {
      setState(() {
        packageInfo = value;
      });
    });
  }

  Future<PackageInfo> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  Widget buildGridItem(
      String title, IconData icon, String description, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                // color: Colors.blue,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400 // Lighter grey for dark theme
                      : Colors.grey.shade700, // Darker grey for light theme
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).size.width < 800
          ? CustomAppBar(
              title: AppLocale.title.getString(context),
            )
          : AppBar(
              automaticallyImplyLeading: false,
              forceMaterialTransparency: true,
              title: Text("Easy Nepse Calculator"),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Text(
                        "Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Privacy Policy",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      drawer: MediaQuery.of(context).size.width < 800
          ? CustomDrawer(packageInfo: packageInfo)
          : null,
      body: ListView(
        children: [
          ListTile(
            title: Text(
              AppLocale.basicCalculations.getString(context),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 800 ? 2 : 4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            children: [
              buildGridItem(
                AppLocale.buy.getString(context),
                Icons.shopping_cart,
                AppLocale.buyDescription.getString(context),
                () {
                  navigateToPage(
                    context: context,
                    pageName: BuyShareScreen(),
                  );
                },
              ),
              buildGridItem(
                AppLocale.sell.getString(context),
                Icons.sell,
                AppLocale.sellDescription.getString(context),
                () {
                  navigateToPage(
                    context: context,
                    pageName: SellShareScreen(),
                  );
                },
              ),
              buildGridItem(
                AppLocale.rightShare.getString(context),
                Icons.trending_up,
                AppLocale.rightShareDescription.getString(context),
                () {
                  navigateToPage(
                    context: context,
                    pageName: RightShareScreen(),
                  );
                },
              ),
              buildGridItem(
                AppLocale.bonusShare.getString(context),
                Icons.card_giftcard,
                AppLocale.bonusShareDescription.getString(context),
                () {
                  navigateToPage(
                    context: context,
                    pageName: BonusShareScreen(),
                  );
                },
              ),
            ],
          ),
          Divider(),
          ListTile(
            title: Text(
              AppLocale.advancedCalculations.getString(context),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 800 ? 2 : 4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            children: [
              buildGridItem(
                AppLocale.reverseBuy.getString(context),
                Icons.arrow_downward,
                AppLocale.reverseBuyDescription.getString(context),
                () {
                  navigateToPage(
                    context: context,
                    pageName: ReverseBuyScreen(),
                  );
                },
              ),
              buildGridItem(
                AppLocale.reverseSell.getString(context),
                Icons.arrow_upward,
                AppLocale.reverseSellDescription.getString(context),
                () {
                  navigateToPage(
                    context: context,
                    pageName: ReverseSellScreen(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
