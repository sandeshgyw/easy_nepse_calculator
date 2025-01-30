import 'package:easy_nepse_calculator/mixins/localization.dart';
import 'package:easy_nepse_calculator/models/buy_calculation.dart';
import 'package:easy_nepse_calculator/providers/calculation_provider.dart';
import 'package:easy_nepse_calculator/widgets/custom_app_bar.dart';
import 'package:easy_nepse_calculator/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class BonusShareScreen extends StatefulWidget {
  const BonusShareScreen({super.key});

  @override
  State<BonusShareScreen> createState() => _BonusShareScreenState();
}

class _BonusShareScreenState extends State<BonusShareScreen> {
  late CalculationProvider calculationProvider;
  final BonusAdjustMentCalculation _bonusAdjustmentCalculation =
      BonusAdjustMentCalculation(
    marketPrice: 0,
    bonusPercent: 0,
  );

  Map<String, TextEditingController> bonusAdjustmentControllers = {
    "marketPrice": TextEditingController(),
    "bonusPercent": TextEditingController(),
    "adjustedPrice": TextEditingController(),
  };

  void _addListenerToController({
    required String key,
    required Function(String) onValueChange,
  }) {
    bonusAdjustmentControllers[key]!.addListener(() {
      String textValue = bonusAdjustmentControllers[key]!.text;

      onValueChange(textValue);

      bonusAdjustmentControllers["adjustedPrice"]!.text = calculationProvider
          .calculateBonusAdjustedPrice(_bonusAdjustmentCalculation.marketPrice,
              _bonusAdjustmentCalculation.bonusPercent)
          .toStringAsFixed(2);

      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _addListenerToController(
        key: "marketPrice",
        onValueChange: (value) {
          _bonusAdjustmentCalculation.marketPrice =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "bonusPercent",
        onValueChange: (value) {
          _bonusAdjustmentCalculation.bonusPercent =
              value.isEmpty ? 0 : double.parse(value);
        });
  }

  @override
  Widget build(BuildContext context) {
    calculationProvider = Provider.of<CalculationProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocale.bonusShareAdjustmentCalculation.getString(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      hintText:
                          AppLocale.marketPriceBeforeClosure.getString(context),
                      labelText: AppLocale.marketPriceLabel.getString(context),
                      keyboardType: TextInputType.phone,
                      prefixText: AppLocale.currencySymbol.getString(context),
                      textController: bonusAdjustmentControllers["marketPrice"],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      hintText: AppLocale.enterBonusSharePercentage
                          .getString(context),
                      labelText:
                          AppLocale.bonusSharePercentage.getString(context),
                      keyboardType: TextInputType.phone,
                      textController:
                          bonusAdjustmentControllers["bonusPercent"],
                    ),
                    const SizedBox(
                      height: 10,
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
      child: bonusAdjustmentControllers["bonusPercent"]!.text.isNotEmpty &&
              bonusAdjustmentControllers["marketPrice"]!.text.isNotEmpty
          ? AnimatedSize(
              duration: Duration(milliseconds: 500),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: bonusAdjustmentControllers["bonusPercent"]!
                            .text
                            .isNotEmpty &&
                        bonusAdjustmentControllers["marketPrice"]!
                            .text
                            .isNotEmpty
                    ? 1.0
                    : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    right: 12,
                  ),
                  child: Column(
                    children: [
                      Divider(),
                      Container(
                        // padding: const EdgeInsets.all(12.0),
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
                            AppLocale.adjustedPrice.getString(context),
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
                            "Rs.${calculationProvider.calculateBonusAdjustedPrice(_bonusAdjustmentCalculation.marketPrice, _bonusAdjustmentCalculation.bonusPercent).toStringAsFixed(2)}",
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
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
