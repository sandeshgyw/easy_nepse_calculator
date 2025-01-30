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

class ReverseBuyScreen extends StatefulWidget {
  const ReverseBuyScreen({super.key});

  @override
  State<ReverseBuyScreen> createState() => _ReverseBuyScreenState();
}

class _ReverseBuyScreenState extends State<ReverseBuyScreen> {
  late CalculationProvider calculationProvider;

  BuyCalculation _reverseBuyCalculation = BuyCalculation(
    quantity: 0,
    price: 0,
    isPriceLocked: true,
    totalAmount: 0,
  );

  Map<String, TextEditingController> reverseBuyingControllers = {
    "quantity": TextEditingController(),
    "price": TextEditingController(),
    "totalAmount": TextEditingController(),
  };

  final GlobalKey<FormState> _formKeyReverseBuying = GlobalKey<FormState>();

  bool get calculateEnabled {
    if (_reverseBuyCalculation.isPriceLocked) {
      // If price is locked, we need investment amount and price
      return reverseBuyingControllers["totalAmount"]!.text.isNotEmpty &&
          reverseBuyingControllers["price"]!.text.isNotEmpty;
    } else {
      // If quantity is locked, we need investment amount and quantity
      return reverseBuyingControllers["totalAmount"]!.text.isNotEmpty &&
          reverseBuyingControllers["quantity"]!.text.isNotEmpty;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _addListenerToController(
        key: "quantity",
        onValueChange: (value) {
          _reverseBuyCalculation.quantity =
              value.isEmpty ? 0 : double.parse(value);
        });

    _addListenerToController(
        key: "price",
        onValueChange: (value) {
          _reverseBuyCalculation.price =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "totalAmount",
        onValueChange: (value) {
          _reverseBuyCalculation.totalAmount =
              value.isEmpty ? 0 : double.parse(value);
        });
  }

  void _addListenerToController({
    required String key,
    required Function(String) onValueChange,
  }) {
    reverseBuyingControllers[key]!.addListener(() {
      String textValue = reverseBuyingControllers[key]!.text;

      onValueChange(textValue);

      setState(() {});
    });
  }

  invokeReverseBuyCalculation() {
    if (_formKeyReverseBuying.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();

      BuyCalculation val = calculationProvider.calculateReverseBuy(
        buyCalculation: BuyCalculation(
          quantity: _reverseBuyCalculation.quantity,
          price: _reverseBuyCalculation.price,
          isPriceLocked: _reverseBuyCalculation.isPriceLocked,
          totalAmount: _reverseBuyCalculation.totalAmount,
        ),
        totalAmount: _reverseBuyCalculation.totalAmount,
      );
      if (_reverseBuyCalculation.isPriceLocked) {
        reverseBuyingControllers["quantity"]!.text =
            val.quantity.toStringAsFixed(2);
      } else {
        reverseBuyingControllers["price"]!.text = val.price.toStringAsFixed(2);
      }

      setState(() {});
      showFullScreenResults(
        context: context,
        isFindQuantity: _reverseBuyCalculation.isPriceLocked,
        quantity: _reverseBuyCalculation.quantity,
        buyPrice: _reverseBuyCalculation.price,
        investmentAmount: _reverseBuyCalculation.totalAmount,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    calculationProvider = Provider.of<CalculationProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocale.reverseBuyingCalculation.getString(context),
      ),
      floatingActionButton: AnimatedSize(
        duration: Duration(
          milliseconds: 500,
        ),
        child: AnimatedOpacity(
          duration: Duration(
            milliseconds: 500,
          ),
          opacity: calculateEnabled ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: invokeReverseBuyCalculation,
            label: Text(
              AppLocale.calculate.getString(context),
            ),
            icon: Icon(
              Icons.calculate,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKeyReverseBuying,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        minLeadingWidth: 0,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          AppLocale.investmentDetails.getString(context),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        leading: Icon(
                          Icons.money,
                        ),
                      ),
                      Text(
                        AppLocale.howMuchToInvest.getString(context),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      investmentMethodField(),
                      SizedBox(
                        height: 10,
                      ),
                      AnimatedSize(
                        duration: Duration(
                          milliseconds: 500,
                        ),
                        child: AnimatedOpacity(
                          duration: Duration(
                            milliseconds: 500,
                          ),
                          opacity: reverseBuyingControllers["totalAmount"]!
                                  .text
                                  .isNotEmpty
                              ? 1.0
                              : 0.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(),
                              ListTile(
                                minLeadingWidth: 0,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  AppLocale.calculationType.getString(context),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.calculate,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                AppLocale.whatToCalculate.getString(context),
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 20),
                              Center(
                                child: ToggleButtons(
                                  borderRadius: BorderRadius.circular(
                                      8), // Rounded corners
                                  borderWidth: 2, // Slightly thicker border
                                  borderColor: Theme.of(context)
                                      .dividerColor, // Border for unselected buttons
                                  selectedBorderColor: Theme.of(context)
                                      .colorScheme
                                      .primary, // Highlight for selected
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(
                                          0.1), // Background for selected
                                  selectedColor: Theme.of(context)
                                      .colorScheme
                                      .primary, // Text color for selected
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.7),
                                  isSelected: [
                                    _reverseBuyCalculation.isPriceLocked,
                                    _reverseBuyCalculation.isQuantityLocked
                                  ],
                                  onPressed: (index) {
                                    if (index == 0) {
                                      _reverseBuyCalculation.isPriceLocked =
                                          true;
                                    } else {
                                      _reverseBuyCalculation.isPriceLocked =
                                          false;
                                    }
                                    setState(() {});
                                  },
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Text(AppLocale.quantity
                                          .getString(context)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Text(
                                        AppLocale.buyPrice.getString(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Divider(),
                              ListTile(
                                minLeadingWidth: 0,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  AppLocale.enterDetails.getString(context),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.input,
                                ),
                              ),
                              if (_reverseBuyCalculation.isPriceLocked) ...[
                                Text(
                                  AppLocale.priceOfShare.getString(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                buyPriceField(false),
                              ] else ...[
                                Text(
                                  AppLocale.howManySharesToBuy
                                      .getString(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                buyQuantityField(true),
                              ],
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showFullScreenResults({
    required BuildContext context,
    required bool isFindQuantity,
    required double quantity,
    required double buyPrice,
    required double investmentAmount,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes the modal take full screen
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.9, // Full-screen height
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        AppLocale.calculationSummary.getString(context),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context), // Close the modal
                  ),
                ],
              ),
              Divider(),

              // Primary Result Section
              ListTile(
                dense: true,
                minLeadingWidth: 0,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppLocale.result.getString(context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Key Value Section
              Container(
                padding: EdgeInsets.all(12.0),
                margin: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Label Text
                    Text(
                      isFindQuantity
                          ? AppLocale.quantity.getString(context)
                          : AppLocale.buyPrice.getString(context),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Dynamic Value
                    Text(
                      isFindQuantity
                          ? "${quantity.toStringAsFixed(2)} units"
                          : AppLocale.currencySymbol.getString(context) +
                              "${buyPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                isFindQuantity
                    ? "You can buy ${quantity.toStringAsFixed(2)} shares at Rs. ${buyPrice.toStringAsFixed(2)} each with your investment of Rs. ${investmentAmount.toStringAsFixed(2)}"
                    : "To buy ${quantity.toStringAsFixed(2)} shares with your investment of Rs. ${investmentAmount.toStringAsFixed(2)}, you need to buy at a price of Rs. ${buyPrice.toStringAsFixed(2)} per share.",
                style: TextStyle(
                  fontSize: 14, fontStyle: FontStyle.italic,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              Divider(),

              // Additional Details Section

              ListTile(
                dense: true,
                minLeadingWidth: 0,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppLocale.additionalDetails.getString(context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              commisionAndFeesTile(),
              waccTile(),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  AppLocale.calculationNote.getString(context),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
  }

  CustomTextField buyQuantityField(bool isResult) {
    return CustomTextField(
      validator: (value) {
        if (_reverseBuyCalculation.isQuantityLocked &&
            (value == null || value.isEmpty)) {
          return AppLocale.numberOfSharesRequired.getString(context);
        }
        return null;
      },
      textController: reverseBuyingControllers["quantity"],
      hintText: isResult
          ? AppLocale.resultAfterCalculation.getString(context)
          : AppLocale.enterQuantity.getString(context),
      labelText: AppLocale.numberOfShares.getString(context),
      keyboardType: TextInputType.phone,
      readOnly: !_reverseBuyCalculation.isQuantityLocked,
    );
  }

  CustomTextField buyPriceField(bool isResult) {
    return CustomTextField(
      validator: (value) {
        if (_reverseBuyCalculation.isPriceLocked &&
            (value == null || value.isEmpty)) {
          return AppLocale.buyingPriceRequired.getString(context);
        }
        return null;
      },
      hintText: isResult
          ? AppLocale.resultAfterCalculation.getString(context)
          : AppLocale.enterBuyingPrice.getString(context),
      labelText: AppLocale.buyingPricePerShare.getString(context),
      keyboardType: TextInputType.phone,
      prefixText: AppLocale.currencySymbol.getString(context),
      textController: reverseBuyingControllers["price"],
      readOnly: !_reverseBuyCalculation.isPriceLocked,
    );
  }

  CustomTextField investmentMethodField() {
    return CustomTextField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocale.totalAmountRequired.getString(context);
        }
        return null;
      },
      textController: reverseBuyingControllers["totalAmount"],
      hintText: AppLocale.enterInvestmentAmount.getString(context),
      labelText: AppLocale.investmentAmount.getString(context),
      keyboardType: TextInputType.phone,
      prefixText: AppLocale.currencySymbol.getString(context),
    );
  }

  ListTile waccTile() {
    return ListTile(
        dense: true,
        minLeadingWidth: 0,
        contentPadding: EdgeInsets.zero,
        onTap: (reverseBuyingControllers["price"]!.text.isEmpty ||
                reverseBuyingControllers["quantity"]!.text.isEmpty)
            ? null
            : () {
                waccModalSheet(
                    totalAmount: double.parse(
                        reverseBuyingControllers["totalAmount"]!.text),
                    quantity: _reverseBuyCalculation.quantity);
              },
        title: Text(
          AppLocale.wacc.getString(context),
        ),
        leading: Icon(
          MdiIcons.scaleBalance,
        ),
        trailing: CustomChip(
            labelText: (reverseBuyingControllers["price"]!.text.isEmpty ||
                    reverseBuyingControllers["quantity"]!.text.isEmpty)
                ? "0"
                : (double.parse(reverseBuyingControllers["totalAmount"]!.text) /
                        _reverseBuyCalculation.quantity)
                    .toStringAsFixed(2),
            onDelete: () {
              waccModalSheet(
                  totalAmount: double.parse(
                      reverseBuyingControllers["totalAmount"]!.text),
                  quantity: _reverseBuyCalculation.quantity);
            }));
  }

  ListTile commisionAndFeesTile() {
    return ListTile(
      dense: true,
      onTap: () {
        feeModalSheet(_reverseBuyCalculation.transactionAmount);
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
            .calculateTotalCharges(_reverseBuyCalculation.transactionAmount)
            .toStringAsFixed(2),
        onDelete: () {
          feeModalSheet(_reverseBuyCalculation.transactionAmount);
        },
      ),
    );
  }

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
                  title: Text(AppLocale.dpFee.getString(context)),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        calculationProvider
                            .calculateDpCharges()
                            .toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(AppLocale.sebonCommission.getString(context)),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        calculationProvider
                            .calculateSebonFee(transactionAmount)
                            .toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(AppLocale.brokerCommission.getString(context)),
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
                  title: Text(
                    AppLocale.totalAmount.getString(context),
                  ),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        totalAmount.toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    AppLocale.totalShares.getString(context),
                  ),
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
}
