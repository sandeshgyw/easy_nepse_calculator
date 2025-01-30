import 'package:easy_nepse_calculator/mixins/localization.dart';
import 'package:easy_nepse_calculator/models/buy_calculation.dart';
import 'package:easy_nepse_calculator/providers/calculation_provider.dart';
import 'package:easy_nepse_calculator/widgets/custom_app_bar.dart';
import 'package:easy_nepse_calculator/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class RightShareScreen extends StatefulWidget {
  const RightShareScreen({super.key});

  @override
  State<RightShareScreen> createState() => _RightShareScreenState();
}

class _RightShareScreenState extends State<RightShareScreen> {
  late CalculationProvider calculationProvider;

  final RightShareAdjustmentCalculation _rightShareAdjustmentCalculation =
      RightShareAdjustmentCalculation(
    marketPrice: 0,
    paidUpValue: 100,
    rightSharePercent: 0,
  );

  Map<String, TextEditingController> rightAdjustmentControllers = {
    "marketPrice": TextEditingController(),
    "rightPercent": TextEditingController(),
    "adjustedPrice": TextEditingController(),
  };

  void _addListenerToController({
    required String key,
    required Function(String) onValueChange,
  }) {
    rightAdjustmentControllers[key]!.addListener(() {
      String textValue = rightAdjustmentControllers[key]!.text;

      onValueChange(textValue);

      rightAdjustmentControllers["adjustedPrice"]!.text = calculationProvider
          .calculateRightAdjustedPrice(
            _rightShareAdjustmentCalculation.marketPrice,
            _rightShareAdjustmentCalculation.rightSharePercent,
            _rightShareAdjustmentCalculation.paidUpValue,
          )
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
          _rightShareAdjustmentCalculation.marketPrice =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "rightPercent",
        onValueChange: (value) {
          _rightShareAdjustmentCalculation.rightSharePercent =
              value.isEmpty ? 0 : double.parse(value);
        });
  }

  @override
  Widget build(BuildContext context) {
    calculationProvider = Provider.of<CalculationProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocale.rightShareAdjustmentCalculation.getString(context),
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
                      hintText:
                          AppLocale.marketPriceBeforeClosure.getString(context),
                      labelText: AppLocale.marketPriceLabel.getString(context),
                      keyboardType: TextInputType.phone,
                      prefixText: AppLocale.currencySymbol.getString(context),
                      textController: rightAdjustmentControllers["marketPrice"],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      hintText: AppLocale.rightSharePercentageDeclared
                          .getString(context),
                      labelText: AppLocale.rightSharePercentageLabel
                          .getString(context),
                      keyboardType: TextInputType.phone,
                      textController:
                          rightAdjustmentControllers["rightPercent"],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocale.paidUpCapital.getString(context),
                        ),
                        ToggleButtons(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                          borderWidth: 2, // Slightly thicker border
                          borderColor: Theme.of(context)
                              .dividerColor, // Border for unselected buttons
                          selectedBorderColor: Theme.of(context)
                              .colorScheme
                              .primary, // Highlight for selected
                          fillColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1), // Background for selected
                          selectedColor: Theme.of(context)
                              .colorScheme
                              .primary, // Text color for selected
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                          isSelected: [
                            _rightShareAdjustmentCalculation.paidUpValue == 10,
                            _rightShareAdjustmentCalculation.paidUpValue == 100,
                          ],
                          onPressed: (index) {
                            _rightShareAdjustmentCalculation.paidUpValue =
                                index == 0 ? 10 : 100;
                            setState(() {});
                          },
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                AppLocale.ten.getString(context),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                AppLocale.hundred.getString(context),
                              ),
                            ),
                          ],
                        ),
                      ],
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
      child: rightAdjustmentControllers["rightPercent"]!.text.isNotEmpty &&
              rightAdjustmentControllers["marketPrice"]!.text.isNotEmpty
          ? AnimatedSize(
              duration: Duration(milliseconds: 500),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: rightAdjustmentControllers["rightPercent"]!
                            .text
                            .isNotEmpty &&
                        rightAdjustmentControllers["marketPrice"]!
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
                            "Rs.${calculationProvider.calculateRightAdjustedPrice(_rightShareAdjustmentCalculation.marketPrice, _rightShareAdjustmentCalculation.rightSharePercent, _rightShareAdjustmentCalculation.paidUpValue).toStringAsFixed(2)}",
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
