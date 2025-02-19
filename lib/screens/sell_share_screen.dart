import 'package:easy_nepse_calculator/enums/transaction_type.dart';
import 'package:easy_nepse_calculator/mixins/localization.dart';
import 'package:easy_nepse_calculator/models/buy_calculation.dart';
import 'package:easy_nepse_calculator/providers/calculation_provider.dart';
import 'package:easy_nepse_calculator/services/hive.dart';
import 'package:easy_nepse_calculator/widgets/custom_app_bar.dart';
import 'package:easy_nepse_calculator/widgets/custom_chip.dart';
import 'package:easy_nepse_calculator/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class SellShareScreen extends StatefulWidget {
  const SellShareScreen({super.key});

  @override
  State<SellShareScreen> createState() => _SellShareScreenState();
}

class _SellShareScreenState extends State<SellShareScreen> {
  late CalculationProvider calculationProvider;

  bool get showCommission => hive.getBool("showCommissionSell");
  bool get showCapitalGain => hive.getBool("showCapitalGainSell");
  bool get showNetProfit => hive.getBool("showProfitLossSell");

  InvestorType investorType = InvestorType.individual;

  final SellCalculation _sellCalculation = SellCalculation(
    quantity: 0,
    price: 0,
    buyingPrice: 0,
    sellingPrice: 0,
    netReceivableAmount: 0,
    holdingDays: HoldinDays.lessThanYear,
    isSellPriceLocked: true,
  );

  Map<String, TextEditingController> sellingControllers = {
    "quantity": TextEditingController(),
    "buyPrice": TextEditingController(),
    "sellPrice": TextEditingController(),
    "netReceivableAmount": TextEditingController(),
    "capitalGain": TextEditingController(),
  };

  void _addListenerToController({
    required String key,
    required Function(String) onValueChange,
  }) {
    sellingControllers[key]!.addListener(() {
      String textValue = sellingControllers[key]!.text;

      onValueChange(textValue);

      sellingControllers["netReceivableAmount"]!.text = calculationProvider
          .calculateNetReceivableAmount(
            sellPrice: _sellCalculation.sellingPrice,
            buyPrice: _sellCalculation.buyingPrice,
            quantity: _sellCalculation.quantity,
            isInstitutional: investorType == InvestorType.institution,
            holdingDays: _sellCalculation.holdingDays,
          )
          .toStringAsFixed(2);

      setState(() {});
    });
  }

  invokeCalculation() {
    sellingControllers["netReceivableAmount"]!.text = calculationProvider
        .calculateNetReceivableAmount(
          sellPrice: _sellCalculation.sellingPrice,
          buyPrice: _sellCalculation.buyingPrice,
          quantity: _sellCalculation.quantity,
          isInstitutional: investorType == InvestorType.institution,
          holdingDays: _sellCalculation.holdingDays,
        )
        .toStringAsFixed(2);

    setState(() {});
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
                              sellPrice: _sellCalculation.sellingPrice,
                              buyPrice: _sellCalculation.buyingPrice,
                              quantity: _sellCalculation.quantity,
                              // transactionAmount: _sellCalculation.sellTransactionAmount,
                              isInstitutional:
                                  investorType == InvestorType.institution,
                              holdingDays: _sellCalculation.holdingDays,
                            ).toStringAsFixed(2)}",
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    AppLocale.gainTaxPercentage.getString(context),
                  ),
                  trailing: Text(
                    investorType == InvestorType.institution
                        ? AppLocale.capitalGainTax10.getString(context)
                        : _sellCalculation.holdingDays ==
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
                  title: Text(
                    AppLocale.capitalGainTax.getString(context),
                  ),
                  trailing: Text(AppLocale.currencySymbol.getString(context) +
                      "${calculationProvider.calculateCapitalGainTax(
                            sellPrice: _sellCalculation.sellingPrice,
                            buyPrice: _sellCalculation.buyingPrice,
                            quantity: _sellCalculation.quantity,
                            // transactionAmount: _sellCalculation.sellTransactionAmount,
                            isInstitutional:
                                investorType == InvestorType.institution,
                            holdingDays: _sellCalculation.holdingDays,
                          ).toStringAsFixed(2)}"),
                ),
                Text(
                  investorType == InvestorType.institution
                      ? AppLocale.institutionalInvestorMessage
                          .getString(context)
                      : _sellCalculation.holdingDays == HoldinDays.lessThanYear
                          ? AppLocale.capitalGainSlab7_5.getString(context)
                          : AppLocale.capitalGainSlab5.getString(context),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          );
        });
  }

  profitLossModalSheet(bool isProfit, double amount) {
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
                    isProfit
                        ? AppLocale.profitInformation.getString(context)
                        : AppLocale.lossInformation.getString(context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(AppLocale.netReceivableAmount.getString(context)),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        calculationProvider
                            .calculateNetReceivableAmount(
                              sellPrice: _sellCalculation.sellingPrice,
                              buyPrice: _sellCalculation.buyingPrice,
                              quantity: _sellCalculation.quantity,
                              isInstitutional:
                                  investorType == InvestorType.institution,
                              holdingDays: _sellCalculation.holdingDays,
                            )
                            .toStringAsFixed(
                              2,
                            ),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    AppLocale.buyAmount.getString(context),
                  ),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        "${_sellCalculation.buyTransactionAmount.toStringAsFixed(2)}",
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  indent: 10,
                  endIndent: 10,
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    isProfit
                        ? AppLocale.profitAmount.getString(context)
                        : AppLocale.lossAmount.getString(context),
                  ),
                  trailing: Text(AppLocale.currencySymbol.getString(context) +
                      "${amount.abs().toStringAsFixed(2)}"),
                ),
                ListTile(
                  visualDensity: VisualDensity(vertical: -4),
                  subtitle: Text(
                    isProfit
                        ? AppLocale.profitAmountMessage
                            .getString(context)
                            .replaceAll("{}", amount.toStringAsFixed(2))
                        : AppLocale.lossAmountMessage
                            .getString(context)
                            .replaceAll(
                              "{}",
                              amount.abs().toStringAsFixed(2),
                            ),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        });
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
                  title: Text(
                    AppLocale.dpFee.getString(context),
                  ),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        calculationProvider
                            .calculateDpCharges()
                            .toStringAsFixed(2),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _addListenerToController(
        key: "buyPrice",
        onValueChange: (value) {
          _sellCalculation.buyingPrice =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "quantity",
        onValueChange: (value) {
          _sellCalculation.quantity = value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "sellPrice",
        onValueChange: (value) {
          _sellCalculation.sellingPrice =
              value.isEmpty ? 0 : double.parse(value);
        });
  }

  @override
  Widget build(BuildContext context) {
    calculationProvider = Provider.of<CalculationProvider>(context);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: AppLocale.sellingCalculation.getString(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        hintText: AppLocale.enterBuyingPrice.getString(context),
                        labelText:
                            AppLocale.buyingPricePerShare.getString(context),
                        keyboardType: TextInputType.number,
                        prefixText: AppLocale.currencySymbol.getString(context),
                        textController: sellingControllers["buyPrice"],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        hintText:
                            AppLocale.sellPricePerShare.getString(context),
                        labelText: AppLocale.sellPriceLabel.getString(context),
                        keyboardType: TextInputType.number,
                        prefixText: AppLocale.currencySymbol.getString(context),
                        textController: sellingControllers["sellPrice"],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        hintText:
                            AppLocale.totalSharesSelling.getString(context),
                        labelText: AppLocale.totalShares.getString(context),
                        keyboardType: TextInputType.number,
                        textController: sellingControllers["quantity"],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(AppLocale.institutionalInvestorTitle
                            .getString(context)),
                        subtitle: Text(AppLocale.institutionalInvestorSubtitle
                            .getString(context)),
                        value: investorType == InvestorType.institution,
                        onChanged: (bool? isInstitutional) {
                          setState(() {
                            investorType = isInstitutional!
                                ? InvestorType.institution
                                : InvestorType.individual;
                          });
                          invokeCalculation();
                        },

                        // activeColor: Theme.of(context)
                        //     .colorScheme
                        //     .primary, // Highlight color when ON
                        // secondary:
                        //     Icon(Icons.business), // Optional icon for better UI
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: investorType == InvestorType.institution
                            ? null
                            : AnimatedSize(
                                duration: Duration(milliseconds: 500),
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 500),
                                  opacity:
                                      investorType != InvestorType.institution
                                          ? 1.0
                                          : 0.0,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        minLeadingWidth: 0,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          AppLocale.holdingDays
                                              .getString(context),
                                        ),
                                        subtitle: Text(
                                          AppLocale.holdingDaysQuestion
                                              .getString(context),
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ToggleButtons(
                                            borderRadius: BorderRadius.circular(
                                                8), // Rounded corners
                                            borderWidth:
                                                2, // Slightly thicker border
                                            borderColor: Theme.of(context)
                                                .dividerColor, // Border for unselected buttons
                                            selectedBorderColor: Theme.of(
                                                    context)
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
                                              _sellCalculation.holdingDays ==
                                                  HoldinDays.lessThanYear,
                                              _sellCalculation.holdingDays ==
                                                  HoldinDays.moreThanYear,
                                            ],
                                            onPressed: (index) {
                                              if (index == 0) {
                                                _sellCalculation.holdingDays =
                                                    HoldinDays.lessThanYear;
                                              } else {
                                                _sellCalculation.holdingDays =
                                                    HoldinDays.moreThanYear;
                                              }
                                              invokeCalculation();
                                            },
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0),
                                                child: Text(
                                                  AppLocale.underOneYear
                                                      .getString(context),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.0),
                                                child: Text(
                                                  AppLocale.overOneYear
                                                      .getString(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                                feeModalSheet(
                                    _sellCalculation.sellTransactionAmount);
                              },
                              minLeadingWidth: 0,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.money,
                              ),
                              title: Text(
                                AppLocale.commissionFees.getString(context),
                              ),
                              trailing: CustomChip(
                                  labelText: calculationProvider
                                      .calculateTotalCharges(_sellCalculation
                                          .sellTransactionAmount)
                                      .toStringAsFixed(2),
                                  onDelete: () {
                                    feeModalSheet(
                                        _sellCalculation.sellTransactionAmount);
                                  }),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.receipt_long,
                              ),
                              onTap: () {
                                capitalGainModalSheet(
                                  _sellCalculation.sellTransactionAmount,
                                );
                              },
                              minLeadingWidth: 0,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                AppLocale.capitalGainTax.getString(context) +
                                    " ${investorType == InvestorType.institution ? "( ${AppLocale.capitalGainTax10.getString(context)} )" : _sellCalculation.holdingDays == HoldinDays.lessThanYear ? " ( ${AppLocale.sevenPointFivePercent.getString(context)} ) " : "( ${AppLocale.fivePercent.getString(context)} )"}",
                              ),
                              trailing: CustomChip(
                                  labelText: calculationProvider
                                      .calculateCapitalGainTax(
                                        sellPrice:
                                            _sellCalculation.sellingPrice,
                                        buyPrice: _sellCalculation.buyingPrice,
                                        quantity: _sellCalculation.quantity,
                                        isInstitutional: investorType ==
                                            InvestorType.institution,
                                        holdingDays:
                                            _sellCalculation.holdingDays,
                                      )
                                      .toStringAsFixed(2),
                                  onDelete: () {
                                    capitalGainModalSheet(
                                      _sellCalculation.sellTransactionAmount,
                                    );
                                  }),
                            ),
                            ListTile(
                              leading: calculationProvider
                                          .calculateNetReceivableAmount(
                                        sellPrice:
                                            _sellCalculation.sellingPrice,
                                        buyPrice: _sellCalculation.buyingPrice,
                                        quantity: _sellCalculation.quantity,
                                        isInstitutional: investorType ==
                                            InvestorType.institution,
                                        holdingDays:
                                            _sellCalculation.holdingDays,
                                      ) >
                                      _sellCalculation.buyTransactionAmount
                                  ? Icon(Icons.trending_up)
                                  : Icon(
                                      Icons.trending_down,
                                    ),
                              onTap: () {
                                profitLossModalSheet(
                                    calculationProvider
                                            .calculateNetReceivableAmount(
                                          sellPrice:
                                              _sellCalculation.sellingPrice,
                                          buyPrice:
                                              _sellCalculation.buyingPrice,
                                          quantity: _sellCalculation.quantity,
                                          isInstitutional: investorType ==
                                              InvestorType.institution,
                                          holdingDays:
                                              _sellCalculation.holdingDays,
                                        ) >
                                        _sellCalculation.buyTransactionAmount,
                                    (calculationProvider
                                            .calculateNetReceivableAmount(
                                          sellPrice:
                                              _sellCalculation.sellingPrice,
                                          buyPrice:
                                              _sellCalculation.buyingPrice,
                                          quantity: _sellCalculation.quantity,
                                          isInstitutional: investorType ==
                                              InvestorType.institution,
                                          holdingDays:
                                              _sellCalculation.holdingDays,
                                        ) -
                                        _sellCalculation.buyTransactionAmount));
                              },
                              minLeadingWidth: 0,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                "${calculationProvider.calculateNetReceivableAmount(
                                      sellPrice: _sellCalculation.sellingPrice,
                                      buyPrice: _sellCalculation.buyingPrice,
                                      quantity: _sellCalculation.quantity,
                                      isInstitutional: investorType ==
                                          InvestorType.institution,
                                      holdingDays: _sellCalculation.holdingDays,
                                    ) > _sellCalculation.buyTransactionAmount ? AppLocale.netProfit.getString(context) : AppLocale.netLoss.getString(context)}",
                              ),
                              trailing: CustomChip(
                                  labelText: (calculationProvider
                                              .calculateNetReceivableAmount(
                                            sellPrice:
                                                _sellCalculation.sellingPrice,
                                            buyPrice:
                                                _sellCalculation.buyingPrice,
                                            quantity: _sellCalculation.quantity,
                                            isInstitutional: investorType ==
                                                InvestorType.institution,
                                            holdingDays:
                                                _sellCalculation.holdingDays,
                                          ) -
                                          _sellCalculation.buyTransactionAmount)
                                      .abs()
                                      .toStringAsFixed(2),
                                  onDelete: () {
                                    profitLossModalSheet(
                                        calculationProvider
                                                .calculateNetReceivableAmount(
                                              sellPrice:
                                                  _sellCalculation.sellingPrice,
                                              buyPrice:
                                                  _sellCalculation.buyingPrice,
                                              quantity:
                                                  _sellCalculation.quantity,
                                              isInstitutional: investorType ==
                                                  InvestorType.institution,
                                              holdingDays:
                                                  _sellCalculation.holdingDays,
                                            ) >
                                            _sellCalculation
                                                .buyTransactionAmount,
                                        (calculationProvider
                                                .calculateNetReceivableAmount(
                                              sellPrice:
                                                  _sellCalculation.sellingPrice,
                                              buyPrice:
                                                  _sellCalculation.buyingPrice,
                                              quantity:
                                                  _sellCalculation.quantity,
                                              isInstitutional: investorType ==
                                                  InvestorType.institution,
                                              holdingDays:
                                                  _sellCalculation.holdingDays,
                                            ) -
                                            _sellCalculation
                                                .buyTransactionAmount));
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ]),
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
      child: sellingControllers["buyPrice"]!.text.isNotEmpty &&
              sellingControllers["sellPrice"]!.text.isNotEmpty &&
              sellingControllers["quantity"]!.text.isNotEmpty
          ? AnimatedSize(
              duration: Duration(milliseconds: 500),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: sellingControllers["buyPrice"]!.text.isNotEmpty &&
                        sellingControllers["sellPrice"]!.text.isNotEmpty &&
                        sellingControllers["quantity"]!.text.isNotEmpty
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
                            AppLocale.netReceivableAmount.getString(context),
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
                                "${sellingControllers["netReceivableAmount"]!.text}",
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
