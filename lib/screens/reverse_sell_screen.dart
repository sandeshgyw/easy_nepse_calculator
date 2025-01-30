import 'package:easy_nepse_calculator/enums/transaction_type.dart';
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

class ReverseSellScreen extends StatefulWidget {
  const ReverseSellScreen({super.key});

  @override
  State<ReverseSellScreen> createState() => _ReverseSellScreenState();
}

class _ReverseSellScreenState extends State<ReverseSellScreen> {
  late CalculationProvider calculationProvider;

  final GlobalKey<FormState> _formKeyReverseSelling = GlobalKey<FormState>();

  SellCalculation _reverseSellCalculation = SellCalculation(
    quantity: 0,
    price: 0,
    buyingPrice: 0,
    sellingPrice: 0,
    netReceivableAmount: 0,
    holdingDays: HoldinDays.lessThanYear,
    isSellPriceLocked: true,
  );

  Map<String, TextEditingController> reverseSellingControllers = {
    "quantity": TextEditingController(),
    "buyPrice": TextEditingController(),
    "sellPrice": TextEditingController(),
    "netReceivableAmount": TextEditingController(),
    "capitalGain": TextEditingController(),
  };

  bool get calculateEnabled {
    if (_reverseSellCalculation.isSellPriceLocked) {
      // If sell price is locked, we need receivable amount, buy price, and quantity
      return reverseSellingControllers["netReceivableAmount"]!
              .text
              .isNotEmpty &&
          reverseSellingControllers["buyPrice"]!.text.isNotEmpty &&
          reverseSellingControllers["sellPrice"]!.text.isNotEmpty;
    } else {
      // If quantity is locked, we need receivable amount, buy price, and sell price
      return reverseSellingControllers["netReceivableAmount"]!
              .text
              .isNotEmpty &&
          reverseSellingControllers["buyPrice"]!.text.isNotEmpty &&
          reverseSellingControllers["quantity"]!.text.isNotEmpty;
    }
  }

  invokeReverseSellCalculation() {
    if (_formKeyReverseSelling.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();

      SellCalculation sellval = calculationProvider.calculateReverseForSell(
        sellCalculation: SellCalculation(
          quantity: _reverseSellCalculation.quantity,
          price: 0,
          buyingPrice: _reverseSellCalculation.buyingPrice,
          sellingPrice: _reverseSellCalculation.sellingPrice,
          netReceivableAmount: _reverseSellCalculation.netReceivableAmount,
          holdingDays: _reverseSellCalculation.holdingDays,
          isSellPriceLocked: _reverseSellCalculation.isSellPriceLocked,
        ),
      );

      if (_reverseSellCalculation.isSellPriceLocked) {
        reverseSellingControllers["quantity"]!.text =
            sellval.quantity.toStringAsFixed(2);
      } else {
        reverseSellingControllers["sellPrice"]!.text =
            sellval.sellingPrice.toStringAsFixed(2);
      }
      showFullScreenReverseSellResults(
        context: context,
        isFindQuantity: _reverseSellCalculation.isSellPriceLocked,
        quantity: _reverseSellCalculation.quantity,
        sellPrice: _reverseSellCalculation.sellingPrice,
        receivableAmount: _reverseSellCalculation.netReceivableAmount,
        commission: 0,
        capitalGainsTax: 0,
      );
    }

    setState(() {});
  }

  void _addListenerToController({
    required String key,
    required Function(String) onValueChange,
  }) {
    reverseSellingControllers[key]!.addListener(() {
      String textValue = reverseSellingControllers[key]!.text;

      onValueChange(textValue);

      setState(() {});
    });
  }

  String get calculateMessage {
    if (_reverseSellCalculation.isSellPriceLocked) {
      return "To receive Rs. ${_reverseSellCalculation.netReceivableAmount} after ${_reverseSellCalculation.holdingDays == HoldinDays.lessThanYear ? 7.5 : 5}% capital gains tax, you need to sell ${_reverseSellCalculation.quantity} stocks at Rs. ${_reverseSellCalculation.sellingPrice} each.";
    } else {
      return "To receive Rs. ${_reverseSellCalculation.netReceivableAmount} after ${_reverseSellCalculation.holdingDays == HoldinDays.lessThanYear ? 7.5 : 5}% capital gains tax by selling ${_reverseSellCalculation.quantity} stocks, you need to set a sell price of Rs. ${_reverseSellCalculation.sellingPrice} per share.";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _addListenerToController(
        key: "buyPrice",
        onValueChange: (value) {
          _reverseSellCalculation.buyingPrice =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "quantity",
        onValueChange: (value) {
          _reverseSellCalculation.quantity =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "sellPrice",
        onValueChange: (value) {
          _reverseSellCalculation.sellingPrice =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "netReceivableAmount",
        onValueChange: (value) {
          _reverseSellCalculation.netReceivableAmount =
              value.isEmpty ? 0 : double.parse(value);
        });
  }

  @override
  Widget build(BuildContext context) {
    calculationProvider = Provider.of<CalculationProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocale.reverseSellingCalculation.getString(context),
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
            onPressed: invokeReverseSellCalculation,
            label: Text(
              AppLocale.calculate.getString(context),
            ),
            icon: Icon(Icons.calculate),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKeyReverseSelling,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          minLeadingWidth: 0,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            AppLocale.receivableDetails.getString(context),
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
                          AppLocale.amountToReceive.getString(context),
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        receivableAmountField(),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(),
                        AnimatedSize(
                          duration: Duration(
                            milliseconds: 500,
                          ),
                          child: AnimatedOpacity(
                            duration: Duration(
                              milliseconds: 500,
                            ),
                            opacity: reverseSellingControllers[
                                        "netReceivableAmount"]!
                                    .text
                                    .isNotEmpty
                                ? 1.0
                                : 0.0,
                            child: Column(
                              children: [
                                ListTile(
                                  minLeadingWidth: 0,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    AppLocale.buyDetails.getString(context),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  leading: Icon(
                                    MdiIcons.shopping,
                                  ),
                                ),
                                Text(
                                  AppLocale.buyingPriceOfStock
                                      .getString(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                purchasePriceReverseSell(),
                                SizedBox(
                                  height: 10,
                                ),
                                Divider(),
                              ],
                            ),
                          ),
                        ),
                        AnimatedSize(
                          duration: Duration(
                            milliseconds: 500,
                          ),
                          child: AnimatedOpacity(
                            duration: Duration(
                              milliseconds: 500,
                            ),
                            opacity: reverseSellingControllers["buyPrice"]!
                                    .text
                                    .isNotEmpty
                                ? 1.0
                                : 0.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  minLeadingWidth: 0,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    AppLocale.calculationType
                                        .getString(context),
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
                                      _reverseSellCalculation.isSellPriceLocked,
                                      _reverseSellCalculation.isQuantityLocked
                                    ],
                                    onPressed: (index) {
                                      if (index == 0) {
                                        _reverseSellCalculation
                                            .isSellPriceLocked = true;
                                      } else {
                                        _reverseSellCalculation
                                            .isSellPriceLocked = false;
                                      }

                                      setState(() {});
                                    },
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(AppLocale.quantity
                                            .getString(context)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(
                                          AppLocale.sellPriceOnlyLabel
                                              .getString(context),
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
                                    AppLocale.holdingDays.getString(context),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.access_time,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  AppLocale.holdingDaysQuestion
                                      .getString(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 20),
                                holdingSwitchReverseSell(),
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
                                if (_reverseSellCalculation
                                    .isSellPriceLocked) ...[
                                  Text(
                                    AppLocale.sellingPrice.getString(context),
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  sellPriceReverseSellField(),
                                ] else ...[
                                  Text(
                                    AppLocale.sharesToSell.getString(context),
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  quantityFieldReverseSell(),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 80,
                        ),
                      ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row holdingSwitchReverseSell() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
          borderRadius: BorderRadius.circular(8), // Rounded corners
          borderWidth: 2, // Slightly thicker border
          borderColor:
              Theme.of(context).dividerColor, // Border for unselected buttons
          selectedBorderColor:
              Theme.of(context).colorScheme.primary, // Highlight for selected
          fillColor: Theme.of(context)
              .colorScheme
              .primary
              .withOpacity(0.1), // Background for selected
          selectedColor:
              Theme.of(context).colorScheme.primary, // Text color for selected
          color:
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          isSelected: [
            _reverseSellCalculation.holdingDays == HoldinDays.lessThanYear,
            _reverseSellCalculation.holdingDays == HoldinDays.moreThanYear,
          ],
          onPressed: (index) {
            if (index == 0) {
              _reverseSellCalculation.holdingDays = HoldinDays.lessThanYear;
            } else {
              _reverseSellCalculation.holdingDays = HoldinDays.moreThanYear;
            }
            setState(() {});
          },
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                AppLocale.underOneYear.getString(context),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                AppLocale.overOneYear.getString(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  capitalGainModalSheet(double transactionAmount) {
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
                    AppLocale.capitalGainInfo.getString(context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    AppLocale.capitalGain.getString(context),
                  ),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        "${calculationProvider.calculateCapitalGain(
                              sellPrice: _reverseSellCalculation.sellingPrice,
                              buyPrice: _reverseSellCalculation.buyingPrice,
                              quantity: _reverseSellCalculation.quantity,
                              // transactionAmount: _sellCalculation.sellTransactionAmount,
                              isInstitutional: false,
                              holdingDays: _reverseSellCalculation.holdingDays,
                            ).toStringAsFixed(2)}",
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(AppLocale.gainTaxPercentage.getString(context)),
                  trailing: Text(
                    _reverseSellCalculation.holdingDays ==
                            HoldinDays.lessThanYear
                        ? AppLocale.sevenPointFivePercent.getString(context)
                        : AppLocale.fivePercent.getString(context),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  indent: 10,
                  endIndent: 10,
                ),
                ListTile(
                  dense: true,
                  title: Text(AppLocale.capitalGainTax.getString(context)),
                  trailing: Text(AppLocale.currencySymbol.getString(context) +
                      "${calculationProvider.calculateCapitalGainTax(
                            sellPrice: _reverseSellCalculation.sellingPrice,
                            buyPrice: _reverseSellCalculation.buyingPrice,
                            quantity: _reverseSellCalculation.quantity,
                            // transactionAmount: _sellCalculation.sellTransactionAmount,
                            isInstitutional: false,
                            holdingDays: _reverseSellCalculation.holdingDays,
                          ).toStringAsFixed(2)}"),
                ),
                Text(
                  _reverseSellCalculation.holdingDays == HoldinDays.lessThanYear
                      ? AppLocale.capitalGainSlab7_5.getString(context)
                      : AppLocale.capitalGainSlab5.getString(context),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          );
        });
  }

  ListTile capitalGainReverseSell() {
    return ListTile(
      dense: true,
      leading: Icon(
        Icons.receipt_long,
      ),
      onTap: () {
        capitalGainModalSheet(
          _reverseSellCalculation.sellTransactionAmount,
        );
      },
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.zero,
      title: Text(
        AppLocale.capitalGainTax.getString(context) +
            "${_reverseSellCalculation.holdingDays == HoldinDays.lessThanYear ? " ( 7.5% ) " : "( 5% )"}",
      ),
      trailing: CustomChip(
        labelText: calculationProvider
            .calculateCapitalGainTax(
              sellPrice: _reverseSellCalculation.sellingPrice,
              buyPrice: _reverseSellCalculation.buyingPrice,
              quantity: _reverseSellCalculation.quantity,
              isInstitutional: false,
              holdingDays: _reverseSellCalculation.holdingDays,
            )
            .toStringAsFixed(2),
        onDelete: () {
          capitalGainModalSheet(
            _reverseSellCalculation.sellTransactionAmount,
          );
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
                const ListTile(
                  dense: true,
                  title: Text(
                    'Total Fees',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('DP Fee'),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        calculationProvider
                            .calculateDpCharges()
                            .toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('SEBON Commission'),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        calculationProvider
                            .calculateSebonFee(transactionAmount)
                            .toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Broker Commission'),
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
                  title: const Text(
                    'Total',
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

  ListTile commissionAndFeesReverseSell() {
    return ListTile(
      leading: Icon(
        MdiIcons.cash,
      ),
      dense: true,
      onTap: () {
        feeModalSheet(_reverseSellCalculation.sellTransactionAmount);
      },
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.zero,
      title: Text(
        AppLocale.commissionFees.getString(context),
      ),
      trailing: CustomChip(
        labelText: calculationProvider
            .calculateTotalCharges(
                _reverseSellCalculation.sellTransactionAmount)
            .toStringAsFixed(2),
        onDelete: () {
          feeModalSheet(_reverseSellCalculation.sellTransactionAmount);
        },
      ),
    );
  }

  CustomTextField quantityFieldReverseSell() {
    return CustomTextField(
      hintText: "Enter the total number of shares you want to sell",
      labelText: AppLocale.numberOfShares.getString(context),
      keyboardType: TextInputType.number,
      textController: reverseSellingControllers["quantity"],
      validator: (value) {
        if (_reverseSellCalculation.isQuantityLocked &&
            (value == null || value.isEmpty)) {
          return AppLocale.numberOfSharesRequired.getString(context);
        }
        return null;
      },
      readOnly: !_reverseSellCalculation.isQuantityLocked,
    );
  }

  CustomTextField sellPriceReverseSellField() {
    return CustomTextField(
      hintText: "Enter the price at which you want to sell each share",
      labelText: AppLocale.sellPriceLabel.getString(context),
      keyboardType: TextInputType.number,
      prefixText: AppLocale.currencySymbol.getString(context),
      textController: reverseSellingControllers["sellPrice"],
      validator: (value) {
        if (_reverseSellCalculation.isSellPriceLocked &&
            (value == null || value.isEmpty)) {
          return AppLocale.buyingPriceRequired.getString(context);
        }
        return null;
      },
      readOnly: !_reverseSellCalculation.isSellPriceLocked,
    );
  }

  CustomTextField purchasePriceReverseSell() {
    return CustomTextField(
      hintText: AppLocale.enterBuyPrice.getString(context),
      labelText: AppLocale.buyPricePerShare.getString(context),
      keyboardType: TextInputType.number,
      prefixText: AppLocale.currencySymbol.getString(context),
      textController: reverseSellingControllers["buyPrice"],
    );
  }

  CustomTextField receivableAmountField() {
    return CustomTextField(
      hintText: AppLocale.enterReceivableAmount.getString(context),
      labelText: AppLocale.receivableAmount.getString(context),
      keyboardType: TextInputType.number,
      prefixText: AppLocale.currencySymbol.getString(context),
      textController: reverseSellingControllers["netReceivableAmount"],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocale.totalAmountRequired.getString(context);
        }
        return null;
      },
    );
  }

  void showFullScreenReverseSellResults({
    required BuildContext context,
    required bool isFindQuantity,
    required double quantity,
    required double sellPrice,
    required double receivableAmount,
    required double commission,
    required double capitalGainsTax,
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
                          : AppLocale.sellPriceOnlyLabel.getString(context),
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
                              "${sellPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),

              // Result Description
              Text(
                isFindQuantity
                    ? "You need to sell ${quantity.toStringAsFixed(2)} shares at Rs. ${sellPrice.toStringAsFixed(2)} each to receive Rs. ${receivableAmount.toStringAsFixed(2)} after fees and taxes."
                    : "To sell ${quantity.toStringAsFixed(2)} shares and receive Rs. ${receivableAmount.toStringAsFixed(2)}, you need to set a sell price of Rs. ${sellPrice.toStringAsFixed(2)} per share.",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
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

              commissionAndFeesReverseSell(),
              capitalGainReverseSell(),
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
}
