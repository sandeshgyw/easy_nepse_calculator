import 'package:easy_nepse_calculator/constants/extension.dart';
import 'package:easy_nepse_calculator/mixins/localization.dart';
import 'package:easy_nepse_calculator/models/buy_calculation.dart';
import 'package:easy_nepse_calculator/providers/calculation_provider.dart';
import 'package:easy_nepse_calculator/widgets/custom_app_bar.dart';
import 'package:easy_nepse_calculator/widgets/custom_chip.dart';
import 'package:easy_nepse_calculator/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class BuyShareScreen extends StatefulWidget {
  const BuyShareScreen({super.key});

  @override
  State<BuyShareScreen> createState() => _BuyShareScreenState();
}

class _BuyShareScreenState extends State<BuyShareScreen> {
  late CalculationProvider calculationProvider;

  // bool get showCommission => hive.getBool("showCommissionBuy");
  // bool get showWacc => hive.getBool("showWaccBuy");

  Map<String, TextEditingController> buyingControllers = {
    "quantity": TextEditingController(),
    "price": TextEditingController(),
    "totalAmount": TextEditingController(),
  };

  final BuyCalculation _buyCalculation = BuyCalculation(
    quantity: 0,
    price: 0,
    isPriceLocked: true,
    totalAmount: 0,
  );

  feeModalSheet(double transactionAmount) {
    showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                    )),
                ListTile(
                  dense: true,
                  title: Text(
                    AppLocale.totalFees.getString(context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    AppLocale.dpFee.getString(context),
                  ),
                  trailing: Text(
                    calculationProvider
                        .calculateDpCharges()
                        .toCurrency(context),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    AppLocale.sebonCommission.getString(context),
                  ),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        calculationProvider
                            .calculateSebonFee(transactionAmount)
                            .toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    AppLocale.brokerCommission.getString(context),
                  ),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        calculationProvider
                            .calculateCommission(transactionAmount)
                            .toStringAsFixed(2),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  indent: 10,
                  endIndent: 10,
                ),
                ListTile(
                  dense: true,

                  // leading: new Icon(Icons.share),
                  title: Text(
                    AppLocale.total.getString(context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        calculationProvider
                            .calculateTotalCharges(transactionAmount)
                            .toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  subtitle: Text(
                    calculationProvider.getCommissionMessage(
                        transactionAmount, context),
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  waccModalSheet({
    required double totalAmount,
    required double quantity,
  }) {
    showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                    )),
                ListTile(
                  dense: true,
                  title: Text(
                    AppLocale.waccCalculation.getString(context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(AppLocale.totalAmount.getString(context)),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        totalAmount.toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(AppLocale.totalShares.getString(context)),
                  trailing: Text(
                    quantity.toStringAsFixed(2),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  indent: 10,
                  endIndent: 10,
                ),
                ListTile(
                  dense: true,

                  // leading: new Icon(Icons.share),
                  title: Text(
                    AppLocale.wacc.getString(context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        (totalAmount / quantity).toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity(vertical: -4),
                  subtitle: Text(
                    AppLocale.costPricePerShare.getString(context) +
                        " Rs. ${(totalAmount / quantity).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _addListenerToController({
    required String key,
    required Function(String) onValueChange,
  }) {
    buyingControllers[key]!.addListener(() {
      String textValue = buyingControllers[key]!.text;

      onValueChange(textValue);

      buyingControllers["totalAmount"]!.text = calculationProvider
          .calculateBuyPrice(_buyCalculation.transactionAmount)
          .toStringAsFixed(2);

      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _addListenerToController(
        key: "quantity",
        onValueChange: (value) {
          _buyCalculation.quantity = value.isEmpty ? 0 : double.parse(value);
        });

    _addListenerToController(
        key: "price",
        onValueChange: (value) {
          _buyCalculation.price = value.isEmpty ? 0 : double.parse(value);
        });
  }

  @override
  Widget build(BuildContext context) {
    calculationProvider = Provider.of<CalculationProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocale.buyingCalculation.getString(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      hintText: AppLocale.enterBuyingPrice.getString(context),
                      labelText:
                          AppLocale.buyingPricePerShare.getString(context),
                      keyboardType: TextInputType.phone,
                      prefixText: AppLocale.currencySymbol.getString(context),
                      textController: buyingControllers["price"],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      textController: buyingControllers["quantity"],
                      hintText: AppLocale.enterTotalShares.getString(context),
                      labelText: AppLocale.numberOfShares.getString(context),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          AppLocale.additionalDetails.getString(context),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          ListTile(
                            onTap: () {
                              feeModalSheet(_buyCalculation.transactionAmount);
                            },
                            minLeadingWidth: 0,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              MdiIcons.cash,
                            ),
                            title: Text(
                              AppLocale.commissionFees.getString(context),
                            ),
                            trailing: CustomChip(
                              labelText: calculationProvider
                                  .calculateTotalCharges(
                                      _buyCalculation.transactionAmount)
                                  .toStringAsFixed(2),
                              onDelete: () {
                                feeModalSheet(
                                    _buyCalculation.transactionAmount);
                              },
                            ),
                          ),
                          if (buyingControllers["price"]!.text.isNotEmpty &&
                              buyingControllers["quantity"]!.text.isNotEmpty)
                            ListTile(
                              minLeadingWidth: 0,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                MdiIcons.scaleBalance,
                              ),
                              onTap: (buyingControllers["price"]!
                                          .text
                                          .isEmpty ||
                                      buyingControllers["quantity"]!
                                          .text
                                          .isEmpty)
                                  ? null
                                  : () {
                                      waccModalSheet(
                                          totalAmount: double.parse(
                                              buyingControllers["totalAmount"]!
                                                  .text),
                                          quantity: _buyCalculation.quantity);
                                    },
                              title: Text(
                                AppLocale.wacc.getString(context),
                              ),
                              trailing: CustomChip(
                                onDelete: () {
                                  waccModalSheet(
                                      totalAmount: double.parse(
                                          buyingControllers["totalAmount"]!
                                              .text),
                                      quantity: _buyCalculation.quantity);
                                },
                                labelText:
                                    (buyingControllers["price"]!.text.isEmpty ||
                                            buyingControllers["quantity"]!
                                                .text
                                                .isEmpty)
                                        ? "0"
                                        : (double.parse(buyingControllers[
                                                        "totalAmount"]!
                                                    .text) /
                                                _buyCalculation.quantity)
                                            .toStringAsFixed(2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          resultSection(),
        ],
      ),
    );
  }

  resultSection() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: buyingControllers["price"]!.text.isNotEmpty &&
              buyingControllers["quantity"]!.text.isNotEmpty
          ? AnimatedSize(
              duration: Duration(milliseconds: 500),
              child: AnimatedOpacity(
                opacity: buyingControllers["price"]!.text.isNotEmpty &&
                        buyingControllers["quantity"]!.text.isNotEmpty
                    ? 1.0
                    : 0.0,
                duration: Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                  ),
                  child: Column(children: [
                    Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary, // Adaptive border color
                          width: 1.5,
                        ),
                        color: Theme.of(context)
                            .colorScheme
                            .surface, // Adaptive background color
                      ),
                      child: ListTile(
                        title: Text(
                          AppLocale.totalPayableAmount.getString(context),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color, // Adaptive text
                          ),
                        ),
                        subtitle: Text(
                          AppLocale.currencySymbol.getString(context) +
                              "${buyingControllers["totalAmount"]!.text}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .primary, // Highlighted text
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            )
          : null,
    );
  }
}
