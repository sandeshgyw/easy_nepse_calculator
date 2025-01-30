import 'package:easy_nepse_calculator/enums/transaction_type.dart';
import 'package:easy_nepse_calculator/mixins/localization.dart';
import 'package:easy_nepse_calculator/models/buy_calculation.dart';
import 'package:easy_nepse_calculator/providers/calculation_provider.dart';
import 'package:easy_nepse_calculator/widgets/custom_app_bar.dart';
import 'package:easy_nepse_calculator/widgets/custom_button.dart';
import 'package:easy_nepse_calculator/widgets/custom_text_field.dart';
import 'package:easy_nepse_calculator/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TransactionTypes currentTransactionType = TransactionTypes.buying;
  ReverseCalculationTypes reverseCalculationTypes =
      ReverseCalculationTypes.quantityCalculation;
  double commissionAndFees = 0;
  late CalculationProvider calculationProvider;

  final BuyCalculation _buyCalculation = BuyCalculation(
    quantity: 0,
    price: 0,
    isPriceLocked: true,
    totalAmount: 0,
  );
  BuyCalculation _reverseBuyCalculation = BuyCalculation(
    quantity: 0,
    price: 0,
    isPriceLocked: true,
    totalAmount: 0,
  );

  SellCalculation _reverseSellCalculation = SellCalculation(
    quantity: 0,
    price: 0,
    buyingPrice: 0,
    sellingPrice: 0,
    netReceivableAmount: 0,
    holdingDays: HoldinDays.lessThanYear,
    isSellPriceLocked: true,
  );

  Map<String, TextEditingController> buyingControllers = {
    "quantity": TextEditingController(),
    "price": TextEditingController(),
    "totalAmount": TextEditingController(),
  };

  Map<String, TextEditingController> reverseBuyingControllers = {
    "quantity": TextEditingController(),
    "price": TextEditingController(),
    "totalAmount": TextEditingController(),
  };

  Map<String, TextEditingController> sellingControllers = {
    "quantity": TextEditingController(),
    "buyPrice": TextEditingController(),
    "sellPrice": TextEditingController(),
    "netReceivableAmount": TextEditingController(),
    "capitalGain": TextEditingController(),
  };
  Map<String, TextEditingController> reverseSellingControllers = {
    "quantity": TextEditingController(),
    "buyPrice": TextEditingController(),
    "sellPrice": TextEditingController(),
    "netReceivableAmount": TextEditingController(),
    "capitalGain": TextEditingController(),
  };

  Map<String, TextEditingController> bonusAdjustmentControllers = {
    "marketPrice": TextEditingController(),
    "bonusPercent": TextEditingController(),
    "adjustedPrice": TextEditingController(),
  };

  Map<String, TextEditingController> rightAdjustmentControllers = {
    "marketPrice": TextEditingController(),
    "rightPercent": TextEditingController(),
    "adjustedPrice": TextEditingController(),
  };

  String _resultMessage = "";

  final GlobalKey<FormState> _formKeyReverseBuying = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyReverseSelling = GlobalKey<FormState>();

  final SellCalculation _sellCalculation = SellCalculation(
    quantity: 0,
    price: 0,
    buyingPrice: 0,
    sellingPrice: 0,
    netReceivableAmount: 0,
    holdingDays: HoldinDays.lessThanYear,
    isSellPriceLocked: true,
  );

  final BonusAdjustMentCalculation _bonusAdjustmentCalculation =
      BonusAdjustMentCalculation(
    marketPrice: 0,
    bonusPercent: 0,
  );

  final RightShareAdjustmentCalculation _rightShareAdjustmentCalculation =
      RightShareAdjustmentCalculation(
    marketPrice: 0,
    paidUpValue: 100,
    rightSharePercent: 0,
  );
  PackageInfo? packageInfo;

  String get calculateMessage {
    if (currentTransactionType == TransactionTypes.reverseBuying) {
      if (_reverseBuyCalculation.isPriceLocked) {
        return "You can buy ${_reverseBuyCalculation.quantity} stocks priced at Rs. ${_reverseBuyCalculation.price} with your investment of Rs. ${_reverseBuyCalculation.totalAmount}.";
      } else {
        return "You need to set a buy price of Rs. ${_reverseBuyCalculation.price} to purchase ${_reverseBuyCalculation.quantity} stocks with your investment of Rs. ${_reverseBuyCalculation.totalAmount}.";
      }
    } else if (currentTransactionType == TransactionTypes.reverseSelling) {
      if (_reverseSellCalculation.isSellPriceLocked) {
        return "To receive Rs. ${_reverseSellCalculation.netReceivableAmount} after ${_reverseSellCalculation.holdingDays == HoldinDays.lessThanYear ? 7.5 : 5}% capital gains tax, you need to sell ${_reverseSellCalculation.quantity} stocks at Rs. ${_reverseSellCalculation.sellingPrice} each.";
      } else {
        return "To receive Rs. ${_reverseSellCalculation.netReceivableAmount} after ${_reverseSellCalculation.holdingDays == HoldinDays.lessThanYear ? 7.5 : 5}% capital gains tax by selling ${_reverseSellCalculation.quantity} stocks, you need to set a sell price of Rs. ${_reverseSellCalculation.sellingPrice} per share.";
      }
    }
    return "Invalid transaction type or calculation configuration.";
  }

  @override
  void dispose() {
    buyingControllers.forEach((key, controller) {
      controller.dispose();
    });

    reverseBuyingControllers.forEach((key, controller) {
      controller.dispose();
    });

    sellingControllers.forEach((key, controller) {
      controller.dispose();
    });

    reverseSellingControllers.forEach((key, controller) {
      controller.dispose();
    });

    bonusAdjustmentControllers.forEach((key, controller) {
      controller.dispose();
    });

    rightAdjustmentControllers.forEach((key, controller) {
      controller.dispose();
    });

    // Always call super.dispose() at the end
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    getVersionNumber().then((value) {
      setState(() {
        packageInfo = value;
      });
    });

    // Add listeners to the controllers
    _addListenerToController(
        key: "quantity",
        transactionType: TransactionTypes.buying,
        onValueChange: (value) {
          _buyCalculation.quantity = value.isEmpty ? 0 : double.parse(value);
        });

    _addListenerToController(
        key: "price",
        transactionType: TransactionTypes.buying,
        onValueChange: (value) {
          _buyCalculation.price = value.isEmpty ? 0 : double.parse(value);
        });

    _addListenerToController(
        key: "quantity",
        transactionType: TransactionTypes.reverseBuying,
        onValueChange: (value) {
          _reverseBuyCalculation.quantity =
              value.isEmpty ? 0 : double.parse(value);
        });

    _addListenerToController(
        key: "price",
        transactionType: TransactionTypes.reverseBuying,
        onValueChange: (value) {
          _reverseBuyCalculation.price =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "totalAmount",
        transactionType: TransactionTypes.reverseBuying,
        onValueChange: (value) {
          _reverseBuyCalculation.totalAmount =
              value.isEmpty ? 0 : double.parse(value);
        });

    _addListenerToController(
        key: "buyPrice",
        transactionType: TransactionTypes.selling,
        onValueChange: (value) {
          _sellCalculation.buyingPrice =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "quantity",
        transactionType: TransactionTypes.selling,
        onValueChange: (value) {
          _sellCalculation.quantity = value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "sellPrice",
        transactionType: TransactionTypes.selling,
        onValueChange: (value) {
          _sellCalculation.sellingPrice =
              value.isEmpty ? 0 : double.parse(value);
        });

    _addListenerToController(
        key: "buyPrice",
        transactionType: TransactionTypes.reverseSelling,
        onValueChange: (value) {
          _reverseSellCalculation.buyingPrice =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "quantity",
        transactionType: TransactionTypes.reverseSelling,
        onValueChange: (value) {
          _reverseSellCalculation.quantity =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "sellPrice",
        transactionType: TransactionTypes.reverseSelling,
        onValueChange: (value) {
          _reverseSellCalculation.sellingPrice =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "netReceivableAmount",
        transactionType: TransactionTypes.reverseSelling,
        onValueChange: (value) {
          _reverseSellCalculation.netReceivableAmount =
              value.isEmpty ? 0 : double.parse(value);
        });

    _addListenerToController(
        key: "marketPrice",
        transactionType: TransactionTypes.bonusShareAdjustment,
        onValueChange: (value) {
          _bonusAdjustmentCalculation.marketPrice =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "bonusPercent",
        transactionType: TransactionTypes.bonusShareAdjustment,
        onValueChange: (value) {
          _bonusAdjustmentCalculation.bonusPercent =
              value.isEmpty ? 0 : double.parse(value);
        });

    _addListenerToController(
        key: "marketPrice",
        transactionType: TransactionTypes.rightShareAdjustment,
        onValueChange: (value) {
          _rightShareAdjustmentCalculation.marketPrice =
              value.isEmpty ? 0 : double.parse(value);
        });
    _addListenerToController(
        key: "rightPercent",
        transactionType: TransactionTypes.rightShareAdjustment,
        onValueChange: (value) {
          _rightShareAdjustmentCalculation.rightSharePercent =
              value.isEmpty ? 0 : double.parse(value);
        });
  }

  void _addListenerToController(
      {required String key,
      required Function(String) onValueChange,
      required TransactionTypes transactionType}) {
    if (transactionType == TransactionTypes.buying) {
      buyingControllers[key]!.addListener(() {
        String textValue = buyingControllers[key]!.text;

        onValueChange(textValue);

        buyingControllers["totalAmount"]!.text = calculationProvider
            .calculateBuyPrice(_buyCalculation.transactionAmount)
            .toStringAsFixed(2);

        setState(() {});
      });
    } else if (transactionType == TransactionTypes.selling) {
      sellingControllers[key]!.addListener(() {
        String textValue = sellingControllers[key]!.text;

        onValueChange(textValue);

        sellingControllers["netReceivableAmount"]!.text = calculationProvider
            .calculateNetReceivableAmount(
              sellPrice: _sellCalculation.sellingPrice,
              buyPrice: _sellCalculation.buyingPrice,
              quantity: _sellCalculation.quantity,
              isInstitutional: false,
              holdingDays: _sellCalculation.holdingDays,
            )
            .toStringAsFixed(2);

        setState(() {});
      });
    } else if (transactionType == TransactionTypes.bonusShareAdjustment) {
      bonusAdjustmentControllers[key]!.addListener(() {
        String textValue = bonusAdjustmentControllers[key]!.text;

        onValueChange(textValue);

        bonusAdjustmentControllers["adjustedPrice"]!.text = calculationProvider
            .calculateBonusAdjustedPrice(
                _bonusAdjustmentCalculation.marketPrice,
                _bonusAdjustmentCalculation.bonusPercent)
            .toStringAsFixed(2);

        setState(() {});
      });
    } else if (transactionType == TransactionTypes.rightShareAdjustment) {
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
    } else if (transactionType == TransactionTypes.reverseBuying) {
      reverseBuyingControllers[key]!.addListener(() {
        String textValue = reverseBuyingControllers[key]!.text;

        onValueChange(textValue);

        setState(() {});
      });
    } else if (transactionType == TransactionTypes.reverseSelling) {
      reverseSellingControllers[key]!.addListener(() {
        String textValue = reverseSellingControllers[key]!.text;

        onValueChange(textValue);

        setState(() {});
      });
    }
  }

  invokeCalculation() {
    sellingControllers["netReceivableAmount"]!.text = calculationProvider
        .calculateNetReceivableAmount(
          sellPrice: _sellCalculation.sellingPrice,
          buyPrice: _sellCalculation.buyingPrice,
          quantity: _sellCalculation.quantity,
          isInstitutional: false,
          holdingDays: _sellCalculation.holdingDays,
        )
        .toStringAsFixed(2);

    setState(() {});
  }

  invokeReverseSellCalculation() {
    if (_formKeyReverseSelling.currentState!.validate()) {
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
      _resultMessage = calculateMessage;
    }

    setState(() {});
  }

  invokeReverseBuyCalculation() {
    if (_formKeyReverseBuying.currentState!.validate()) {
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

      _resultMessage = calculateMessage;
      setState(() {});
    }
  }

  Future<PackageInfo> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  @override
  Widget build(BuildContext context) {
    calculationProvider = Provider.of<CalculationProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocale.title.getString(context),
      ),
      drawer: CustomDrawer(packageInfo: packageInfo),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField<String>(
              autofocus: true,
              value: TransactionTypes.buying.name, // Default value

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              items: [
                DropdownMenuItem(
                  value: TransactionTypes.buying.name,
                  child: Text(
                    AppLocale.buyingCalculation.getString(context),
                  ),
                ),
                DropdownMenuItem(
                  value: TransactionTypes.selling.name,
                  child: Text(
                    AppLocale.sellingCalculation.getString(context),
                  ),
                ),
                DropdownMenuItem(
                  value: TransactionTypes.reverseBuying.name,
                  child: Text(
                    AppLocale.reverseBuyingCalculation.getString(context),
                  ),
                ),
                DropdownMenuItem(
                  value: TransactionTypes.reverseSelling.name,
                  child: Text(
                    AppLocale.reverseSellingCalculation.getString(context),
                  ),
                ),
                DropdownMenuItem(
                  value: TransactionTypes.bonusShareAdjustment.name,
                  child: Text(
                    AppLocale.bonusShareAdjustmentCalculation
                        .getString(context),
                  ),
                ),
                DropdownMenuItem(
                  value: TransactionTypes.rightShareAdjustment.name,
                  child: Text(
                    AppLocale.rightShareAdjustmentCalculation
                        .getString(context),
                  ),
                ),
                // DropdownMenuItem(
                //   value: TransactionTypes.merger.name,
                //   child: const Text('Merger Calculation'),
                // ),
              ],
              onChanged: (value) {
                setState(() {
                  currentTransactionType = getTransactionType(value!);
                  _resultMessage = "";
                });
              },
            ),
            const Divider(),
            if (currentTransactionType == TransactionTypes.buying)
              buyingWidgetBlock()
            else if (currentTransactionType == TransactionTypes.selling)
              sellingWidgetBlock()
            else if (currentTransactionType ==
                TransactionTypes.bonusShareAdjustment)
              bonusWidgetBlock()
            else if (currentTransactionType ==
                TransactionTypes.rightShareAdjustment)
              rightShareWidgetBlock()
            else if (currentTransactionType ==
                TransactionTypes.reverseBuying) ...[
              reverseBuyingWidgetBlock(),
              CustomButton(
                width: double.infinity,
                onPress: invokeReverseBuyCalculation,
                text: "Calculate",
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ] else if (currentTransactionType ==
                TransactionTypes.reverseSelling) ...[
              reverseSellingWidgetBlock(),
              CustomButton(
                width: double.infinity,
                onPress: invokeReverseSellCalculation,
                text: "Calculate",
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  buyingWidgetBlock() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomTextField(
              hintText: "Enter the buying price per share",
              labelText: "Buying Price per Share",
              keyboardType: TextInputType.phone,
              prefixText: AppLocale.currencySymbol.getString(context),
              textController: buyingControllers["price"],
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              textController: buyingControllers["quantity"],
              hintText: "Enter the total shares you're purchasing",
              labelText: "Number of Shares",
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              onTap: () {
                feeModalSheet(_buyCalculation.transactionAmount);
              },
              minLeadingWidth: 0,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                "Commission & Fees",
              ),
              trailing: Chip(
                shape: const RoundedRectangleBorder(
                  side: BorderSide(style: BorderStyle.none),
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      20,
                    ),
                  ),
                ),
                label: Text(
                  calculationProvider
                      .calculateTotalCharges(_buyCalculation.transactionAmount)
                      .toStringAsFixed(2),
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            ListTile(
              minLeadingWidth: 0,
              contentPadding: EdgeInsets.zero,
              onTap: (buyingControllers["price"]!.text.isEmpty ||
                      buyingControllers["quantity"]!.text.isEmpty)
                  ? null
                  : () {
                      waccModalSheet(
                          totalAmount: double.parse(
                              buyingControllers["totalAmount"]!.text),
                          quantity: _buyCalculation.quantity);
                    },
              title: const Text(
                "WACC",
              ),
              trailing: Chip(
                shape: const RoundedRectangleBorder(
                  side: BorderSide(style: BorderStyle.none),
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      20,
                    ),
                  ),
                ),
                label: Text(
                  (buyingControllers["price"]!.text.isEmpty ||
                          buyingControllers["quantity"]!.text.isEmpty)
                      ? "0"
                      : (double.parse(buyingControllers["totalAmount"]!.text) /
                              _buyCalculation.quantity)
                          .toStringAsFixed(2),
                  style: (buyingControllers["price"]!.text.isEmpty ||
                          buyingControllers["quantity"]!.text.isEmpty)
                      ? null
                      : const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                ),
              ),
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              textController: buyingControllers["totalAmount"],
              hintText: "Total Amount",
              labelText: "Total Amount",
              keyboardType: TextInputType.phone,
              prefixText: AppLocale.currencySymbol.getString(context),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  reverseBuyingWidgetBlock() {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: _formKeyReverseBuying,
          child: Column(
            children: [
              // Text(
              //   "Select Calculation Type",
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              // SizedBox(height: 10),
              Center(
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
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
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  isSelected: [
                    _reverseBuyCalculation.isPriceLocked,
                    _reverseBuyCalculation.isQuantityLocked
                  ],
                  onPressed: (index) {
                    if (index == 0) {
                      _reverseBuyCalculation.isPriceLocked = true;
                    } else {
                      _reverseBuyCalculation.isPriceLocked = false;
                    }
                    _resultMessage = calculateMessage;
                    setState(() {});
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("Quantity"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("Buy Price"),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (_reverseBuyCalculation.isPriceLocked) ...[
                investmentMethodField(),
                const SizedBox(
                  height: 10,
                ),
                buyPriceField(false),
                const SizedBox(
                  height: 10,
                ),
                Divider(),
                commisionAndFeesTile(),
                waccTile(),
                const Divider(),
                SizedBox(
                  height: 10,
                ),
                buyQuantityField(true),
                SizedBox(
                  height: 10,
                ),
              ] else ...[
                investmentMethodField(),
                const SizedBox(
                  height: 10,
                ),
                buyQuantityField(false),
                const SizedBox(
                  height: 10,
                ),
                Divider(),
                commisionAndFeesTile(),
                waccTile(),
                const Divider(),
                SizedBox(
                  height: 10,
                ),
                buyPriceField(true),
                SizedBox(
                  height: 10,
                ),
              ],
              Text(
                _resultMessage,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile waccTile() {
    return ListTile(
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
      title: const Text(
        "WACC",
      ),
      trailing: Chip(
        shape: const RoundedRectangleBorder(
          side: BorderSide(style: BorderStyle.none),
          borderRadius: BorderRadius.all(
            Radius.circular(
              20,
            ),
          ),
        ),
        label: Text(
          (reverseBuyingControllers["price"]!.text.isEmpty ||
                  reverseBuyingControllers["quantity"]!.text.isEmpty)
              ? "0"
              : (double.parse(reverseBuyingControllers["totalAmount"]!.text) /
                      _reverseBuyCalculation.quantity)
                  .toStringAsFixed(2),
          style: (reverseBuyingControllers["price"]!.text.isEmpty ||
                  reverseBuyingControllers["quantity"]!.text.isEmpty)
              ? null
              : const TextStyle(
                  decoration: TextDecoration.underline,
                ),
        ),
      ),
    );
  }

  ListTile commisionAndFeesTile() {
    return ListTile(
      onTap: () {
        feeModalSheet(_reverseBuyCalculation.transactionAmount);
      },
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.zero,
      title: const Text(
        "Commission & Fees",
      ),
      trailing: Chip(
        shape: const RoundedRectangleBorder(
          side: BorderSide(style: BorderStyle.none),
          borderRadius: BorderRadius.all(
            Radius.circular(
              20,
            ),
          ),
        ),
        label: Text(
          calculationProvider
              .calculateTotalCharges(_reverseBuyCalculation.transactionAmount)
              .toStringAsFixed(2),
          style: const TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  CustomTextField buyQuantityField(bool isResult) {
    return CustomTextField(
      validator: (value) {
        if (_reverseBuyCalculation.isQuantityLocked &&
            (value == null || value.isEmpty)) {
          return "Number of shares is required.";
        }
        return null;
      },
      textController: reverseBuyingControllers["quantity"],
      hintText: isResult
          ? "Result will be shown here after calculation"
          : "Enter the total shares you want to purchase",
      labelText: "Number of Shares",
      keyboardType: TextInputType.phone,
      readOnly: !_reverseBuyCalculation.isQuantityLocked,
    );
  }

  CustomTextField buyPriceField(bool isResult) {
    return CustomTextField(
      validator: (value) {
        if (_reverseBuyCalculation.isPriceLocked &&
            (value == null || value.isEmpty)) {
          return "Buying price is required.";
        }
        return null;
      },
      hintText: isResult
          ? "Result will be shown here after calculation"
          : "Enter the buying price per share",
      labelText: "Buying Price per Share",
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
          return "Total amount is required.";
        }
        return null;
      },
      textController: reverseBuyingControllers["totalAmount"],
      hintText: "Enter the amount you want to invest",
      labelText: "Investment Amount",
      keyboardType: TextInputType.phone,
      prefixText: AppLocale.currencySymbol.getString(context),
    );
  }

  reverseSellingWidgetBlock() {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: _formKeyReverseSelling,
          child: Column(children: [
            Center(
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(8), // Rounded corners
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
                color: Theme.of(context).textTheme.bodyMedium?.color,
                isSelected: [
                  _reverseSellCalculation.isSellPriceLocked,
                  _reverseSellCalculation.isQuantityLocked
                ],
                onPressed: (index) {
                  if (index == 0) {
                    _reverseSellCalculation.isSellPriceLocked = true;
                  } else {
                    _reverseSellCalculation.isSellPriceLocked = false;
                  }
                  _resultMessage = calculateMessage;

                  setState(() {});
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("Quantity"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("Sell Price"),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            receivableAmountField(),
            const SizedBox(
              height: 10,
            ),
            purchasePriceReverseSell(),
            const SizedBox(
              height: 10,
            ),
            if (_reverseSellCalculation.isSellPriceLocked) ...[
              sellPriceReverseSellField(),
              Divider(),
              commissionAndFeesReverseSell(),
              capitalGainReverseSell(),
              holdingSwitchReverseSell(),
              const Divider(),
              SizedBox(
                height: 10,
              ),
              quantityFieldReverseSell(),
              SizedBox(
                height: 10,
              ),
            ] else ...[
              quantityFieldReverseSell(),
              Divider(),
              commissionAndFeesReverseSell(),
              capitalGainReverseSell(),
              holdingSwitchReverseSell(),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              sellPriceReverseSellField(),
              SizedBox(
                height: 10,
              ),
            ],
            Text(
              _resultMessage,
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ]),
        ),
      ),
    );
  }

  Row holdingSwitchReverseSell() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
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
            invokeReverseSellCalculation();
          },
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                AppLocale.sevenPointFivePercent.getString(context),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                AppLocale.fivePercent.getString(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  ListTile capitalGainReverseSell() {
    return ListTile(
      onTap: () {
        capitalGainModalSheet(
          _reverseSellCalculation.sellTransactionAmount,
        );
      },
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.zero,
      title: Text(
        AppLocale.capitalGain.getString(context) +
            "${_reverseSellCalculation.holdingDays == HoldinDays.lessThanYear ? " ${AppLocale.sevenPointFivePercent.getString(context)} ) " : "( ${AppLocale.fivePercent.getString(context)} )"}",
      ),
      trailing: Chip(
        shape: const RoundedRectangleBorder(
          side: BorderSide(style: BorderStyle.none),
          borderRadius: BorderRadius.all(
            Radius.circular(
              20,
            ),
          ),
        ),
        label: Text(
          calculationProvider
              .calculateCapitalGainTax(
                sellPrice: _reverseSellCalculation.sellingPrice,
                buyPrice: _reverseSellCalculation.buyingPrice,
                quantity: _reverseSellCalculation.quantity,
                // transactionAmount: _sellCalculation.sellTransactionAmount,
                isInstitutional: false,
                holdingDays: _reverseSellCalculation.holdingDays,
              )
              .toStringAsFixed(2),
          style: const TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  ListTile commissionAndFeesReverseSell() {
    return ListTile(
      onTap: () {
        feeModalSheet(_reverseSellCalculation.sellTransactionAmount);
      },
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.zero,
      title: Text(
        AppLocale.commissionFees.getString(context),
      ),
      trailing: Chip(
        shape: const RoundedRectangleBorder(
          side: BorderSide(style: BorderStyle.none),
          borderRadius: BorderRadius.all(
            Radius.circular(
              20,
            ),
          ),
        ),
        label: Text(
          calculationProvider
              .calculateTotalCharges(
                  _reverseSellCalculation.sellTransactionAmount)
              .toStringAsFixed(2),
          style: const TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
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
      labelText: "Sell Price (per Share)",
      keyboardType: TextInputType.number,
      prefixText: AppLocale.currencySymbol.getString(context),
      textController: reverseSellingControllers["sellPrice"],
      validator: (value) {
        if (_reverseSellCalculation.isSellPriceLocked &&
            (value == null || value.isEmpty)) {
          return "Buying price is required.";
        }
        return null;
      },
      readOnly: !_reverseSellCalculation.isSellPriceLocked,
    );
  }

  CustomTextField purchasePriceReverseSell() {
    return CustomTextField(
      hintText: "Enter the price at which you purchased each share",
      labelText: "Buy Price (per Share)",
      keyboardType: TextInputType.number,
      prefixText: AppLocale.currencySymbol.getString(context),
      textController: reverseSellingControllers["buyPrice"],
    );
  }

  CustomTextField receivableAmountField() {
    return CustomTextField(
      hintText:
          "Enter the total amount you want to receive after selling shares",
      labelText: "Receivable Amount",
      keyboardType: TextInputType.number,
      prefixText: AppLocale.currencySymbol.getString(context),
      textController: reverseSellingControllers["netReceivableAmount"],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Total amount is required.";
        }
        return null;
      },
    );
  }

  sellingWidgetBlock() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            hintText: "Enter buy price",
            labelText: "Buy Price (per Share)",
            keyboardType: TextInputType.number,
            prefixText: AppLocale.currencySymbol.getString(context),
            textController: sellingControllers["buyPrice"],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            hintText: "Enter sell price",
            labelText: "Sell Price (per Share)",
            keyboardType: TextInputType.number,
            prefixText: AppLocale.currencySymbol.getString(context),
            textController: sellingControllers["sellPrice"],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            hintText: "Enter total shares",
            labelText: "Total Shares",
            keyboardType: TextInputType.number,
            textController: sellingControllers["quantity"],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          ListTile(
            onTap: () {
              feeModalSheet(_sellCalculation.sellTransactionAmount);
            },
            minLeadingWidth: 0,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Commission & Fees",
            ),
            trailing: Chip(
              shape: const RoundedRectangleBorder(
                side: BorderSide(style: BorderStyle.none),
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    20,
                  ),
                ),
              ),
              label: Text(
                calculationProvider
                    .calculateTotalCharges(
                        _sellCalculation.sellTransactionAmount)
                    .toStringAsFixed(2),
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              capitalGainModalSheet(
                _sellCalculation.sellTransactionAmount,
              );
            },
            minLeadingWidth: 0,
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Capital Gain Tax${_sellCalculation.holdingDays == HoldinDays.lessThanYear ? " ( 7.5% ) " : "( 5% )"}",
            ),
            trailing: Chip(
              shape: const RoundedRectangleBorder(
                side: BorderSide(style: BorderStyle.none),
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    20,
                  ),
                ),
              ),
              label: Text(
                calculationProvider
                    .calculateCapitalGainTax(
                      sellPrice: _sellCalculation.sellingPrice,
                      buyPrice: _sellCalculation.buyingPrice,
                      quantity: _sellCalculation.quantity,
                      // transactionAmount: _sellCalculation.sellTransactionAmount,
                      isInstitutional: false,
                      holdingDays: _sellCalculation.holdingDays,
                    )
                    .toStringAsFixed(2),
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              profitLossModalSheet(
                  calculationProvider.calculateNetReceivableAmount(
                        sellPrice: _sellCalculation.sellingPrice,
                        buyPrice: _sellCalculation.buyingPrice,
                        quantity: _sellCalculation.quantity,
                        isInstitutional: false,
                        holdingDays: _sellCalculation.holdingDays,
                      ) >
                      _sellCalculation.buyTransactionAmount,
                  (calculationProvider.calculateNetReceivableAmount(
                        sellPrice: _sellCalculation.sellingPrice,
                        buyPrice: _sellCalculation.buyingPrice,
                        quantity: _sellCalculation.quantity,
                        isInstitutional: false,
                        holdingDays: _sellCalculation.holdingDays,
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
                    isInstitutional: false,
                    holdingDays: _sellCalculation.holdingDays,
                  ) > _sellCalculation.buyTransactionAmount ? "Net Profit" : "Net Loss"}",
            ),
            trailing: Chip(
              shape: const RoundedRectangleBorder(
                side: BorderSide(style: BorderStyle.none),
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    20,
                  ),
                ),
              ),
              label: Text(
                (calculationProvider.calculateNetReceivableAmount(
                          sellPrice: _sellCalculation.sellingPrice,
                          buyPrice: _sellCalculation.buyingPrice,
                          quantity: _sellCalculation.quantity,
                          isInstitutional: false,
                          holdingDays: _sellCalculation.holdingDays,
                        ) -
                        _sellCalculation.buyTransactionAmount)
                    .abs()
                    .toStringAsFixed(2),
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToggleButtons(
                isSelected: [
                  _sellCalculation.holdingDays == HoldinDays.lessThanYear,
                  _sellCalculation.holdingDays == HoldinDays.moreThanYear,
                ],
                onPressed: (index) {
                  if (index == 0) {
                    _sellCalculation.holdingDays = HoldinDays.lessThanYear;
                  } else {
                    _sellCalculation.holdingDays = HoldinDays.moreThanYear;
                  }
                  invokeCalculation();
                },
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      AppLocale.sevenPointFivePercent.getString(context),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      AppLocale.fivePercent.getString(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            hintText: "Enter net amount",
            labelText: "Net Receivable Amount",
            keyboardType: TextInputType.number,
            prefixText: AppLocale.currencySymbol.getString(context),
            textController: sellingControllers["netReceivableAmount"],
            readOnly: true,
          ),
        ]),
      ),
    );
  }

  bonusWidgetBlock() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomTextField(
              hintText: "Enter the market price before book closure",
              labelText: "Market Price (before book closure)",
              keyboardType: TextInputType.phone,
              prefixText: AppLocale.currencySymbol.getString(context),
              textController: bonusAdjustmentControllers["marketPrice"],
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              hintText: "Enter the bonus share percentage declared",
              labelText: "Bonus Share Percentage",
              keyboardType: TextInputType.phone,
              textController: bonusAdjustmentControllers["bonusPercent"],
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              minLeadingWidth: 0,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                "Adjusted Price",
              ),
              trailing: Chip(
                shape: const RoundedRectangleBorder(
                  side: BorderSide(style: BorderStyle.none),
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      20,
                    ),
                  ),
                ),
                label: Text(
                  "Rs.${calculationProvider.calculateBonusAdjustedPrice(_bonusAdjustmentCalculation.marketPrice, _bonusAdjustmentCalculation.bonusPercent).toStringAsFixed(2)}",
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  rightShareWidgetBlock() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomTextField(
              hintText: "Enter the market price before book closure",
              labelText: "Market Price (before book closure)",
              keyboardType: TextInputType.phone,
              prefixText: AppLocale.currencySymbol.getString(context),
              textController: rightAdjustmentControllers["marketPrice"],
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              hintText: "Enter the right share percentage declared",
              labelText: "Right Share Percentage",
              keyboardType: TextInputType.phone,
              textController: rightAdjustmentControllers["rightPercent"],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Paid-Up Capital"),
                ToggleButtons(
                  isSelected: [
                    _rightShareAdjustmentCalculation.paidUpValue == 10,
                    _rightShareAdjustmentCalculation.paidUpValue == 100,
                  ],
                  onPressed: (index) {
                    _rightShareAdjustmentCalculation.paidUpValue =
                        index == 0 ? 10 : 100;
                    setState(() {});
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("10"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("100"),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            ListTile(
              minLeadingWidth: 0,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                "Adjusted Price",
              ),
              trailing: Chip(
                shape: const RoundedRectangleBorder(
                  side: BorderSide(style: BorderStyle.none),
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      20,
                    ),
                  ),
                ),
                label: Text(
                  "Rs.${calculationProvider.calculateRightAdjustedPrice(_rightShareAdjustmentCalculation.marketPrice, _rightShareAdjustmentCalculation.rightSharePercent, _rightShareAdjustmentCalculation.paidUpValue).toStringAsFixed(2)}",
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
                const ListTile(
                  dense: true,
                  title: Text(
                    'Capital Gain Info',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text(
                    'Capital Gain ',
                  ),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        "${calculationProvider.calculateCapitalGain(
                              sellPrice: _sellCalculation.sellingPrice,
                              buyPrice: _sellCalculation.buyingPrice,
                              quantity: _sellCalculation.quantity,
                              // transactionAmount: _sellCalculation.sellTransactionAmount,
                              isInstitutional: false,
                              holdingDays: _sellCalculation.holdingDays,
                            ).toStringAsFixed(2)}",
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(AppLocale.gainTaxPercentage.getString(context)),
                  trailing: Text(
                    _sellCalculation.holdingDays == HoldinDays.lessThanYear
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
                  title: const Text('Capital Gain Tax'),
                  trailing: Text(AppLocale.currencySymbol.getString(context) +
                      "${calculationProvider.calculateCapitalGainTax(
                            sellPrice: _sellCalculation.sellingPrice,
                            buyPrice: _sellCalculation.buyingPrice,
                            quantity: _sellCalculation.quantity,
                            // transactionAmount: _sellCalculation.sellTransactionAmount,
                            isInstitutional: false,
                            holdingDays: _sellCalculation.holdingDays,
                          ).toStringAsFixed(2)}"),
                ),
                Text(
                  _sellCalculation.holdingDays == HoldinDays.lessThanYear
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
                    isProfit ? "Profit Information" : "Loss Information",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Net Receivalble Amount'),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        calculationProvider
                            .calculateNetReceivableAmount(
                              sellPrice: _sellCalculation.sellingPrice,
                              buyPrice: _sellCalculation.buyingPrice,
                              quantity: _sellCalculation.quantity,
                              isInstitutional: false,
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
                    'Buy Amount',
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
                  title: Text(isProfit ? "Profit Amount" : "Loss Amount"),
                  trailing: Text(AppLocale.currencySymbol.getString(context) +
                      "${amount.abs().toStringAsFixed(2)}"),
                ),
                ListTile(
                  visualDensity: VisualDensity(vertical: -4),
                  subtitle: Text(
                    isProfit
                        ? "You earned a profit of Rs. ${amount.toStringAsFixed(2)}"
                        : "You beared a loss of Rs. ${amount.abs().toStringAsFixed(2)}",
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
                const ListTile(
                  dense: true,
                  title: Text(
                    'WACC Calculation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Total Amount'),
                  trailing: Text(
                    AppLocale.currencySymbol.getString(context) +
                        totalAmount.toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Total Shares'),
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
                  title: const Text(
                    'WACC',
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
                    "Your cost price per share is Rs. ${(totalAmount / quantity).toStringAsFixed(2)}",
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
