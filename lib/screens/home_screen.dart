import 'package:easy_nepse_calculator/enums/transaction_type.dart';
import 'package:easy_nepse_calculator/models/buy_calculation.dart';
import 'package:easy_nepse_calculator/providers/calculation_provider.dart';
import 'package:easy_nepse_calculator/providers/theme_provider.dart';
import 'package:easy_nepse_calculator/screens/buy_share_screen.dart';
import 'package:easy_nepse_calculator/services/navigation.dart';
import 'package:easy_nepse_calculator/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TransactionTypes currentTransactionType = TransactionTypes.buying;
  double commissionAndFees = 0;
  late CalculationProvider calculationProvider;

  final BuyCalculation _buyCalculation = BuyCalculation(
      quantity: 0, price: 0, isPriceLocked: true, totalAmount: 0);
  BuyCalculation _reverseBuyCalculation = BuyCalculation(
      quantity: 0, price: 0, isPriceLocked: true, totalAmount: 0);

  Map<String, TextEditingController> buyingControllers = {
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
  Map<String, TextEditingController> reverseBuyingControllers = {
    "quantity": TextEditingController(),
    "price": TextEditingController(),
    "totalAmount": TextEditingController(),
  };

  final SellCalculation _sellCalculation = SellCalculation(
    quantity: 0,
    price: 0,
    buyingPrice: 0,
    sellingPrice: 0,
    netReceivableAmount: 0,
    holdingDays: HoldinDays.lessThanYear,
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

  @override
  void initState() {
    super.initState();

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

        if (reverseBuyingControllers["totalAmount"]!.text.isNotEmpty) {
          _reverseBuyCalculation = calculationProvider.calculateReverseBuy(
              buyCalculation: _reverseBuyCalculation,
              totalAmount:
                  double.parse(reverseBuyingControllers["totalAmount"]!.text));
          print(_reverseBuyCalculation);

          if (_reverseBuyCalculation.isPriceLocked) {
            reverseBuyingControllers["price"]!.text =
                _reverseBuyCalculation.price.toStringAsFixed(2);
          } else if (_reverseBuyCalculation.isQuantityLocked) {
            reverseBuyingControllers["quantity"]!.text =
                _reverseBuyCalculation.quantity.toStringAsFixed(2);
          }
        }

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

  @override
  Widget build(BuildContext context) {
    ThemeProvider _themeProvider = Provider.of<ThemeProvider>(context);
    calculationProvider = Provider.of<CalculationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text(
                "test name",
              ),
              accountEmail: Text(
                "test email",
              ),
            ),
            ListTile(
              title: const Text("Buy Calculation"),
              leading: const Icon(Icons.burst_mode),
              onTap: () {
                navigateToPage(
                  context: context,
                  pageName: const BuyShareScreen(),
                );
              },
            ),
            const Divider(height: 0),
            ListTile(
              title: _themeProvider.isDarkMode
                  ? const Text(
                      "Dark Mode",
                    )
                  : const Text("Light Mode"),
              leading: _themeProvider.isDarkMode
                  ? const Icon(
                      Icons.dark_mode,
                    )
                  : const Icon(Icons.light_mode),
              onTap: () {
                _themeProvider.changeTheme(!_themeProvider.isDarkMode);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: TransactionTypes.buying.name, // Default value
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              items: [
                DropdownMenuItem(
                  value: TransactionTypes.buying.name,
                  child: const Text('Buying'),
                ),
                DropdownMenuItem(
                  value: TransactionTypes.selling.name,
                  child: const Text('Selling'),
                ),
                DropdownMenuItem(
                  value: TransactionTypes.reverseBuying.name,
                  child: const Text(
                    'Reverse Buying',
                  ),
                ),
                DropdownMenuItem(
                  value: TransactionTypes.bonusShareAdjustment.name,
                  child: const Text('Bonus Share Adjustment'),
                ),
                DropdownMenuItem(
                  value: TransactionTypes.rightShareAdjustment.name,
                  child: const Text('Right Share Adjustment'),
                ),
                DropdownMenuItem(
                  value: TransactionTypes.merger.name,
                  child: const Text('Merger'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  currentTransactionType = getTransactionType(value!);
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
            else if (currentTransactionType == TransactionTypes.reverseBuying)
              reverseBuyingWidgetBlock(),
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
              prefixText: "Rs. ",
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
              title: const Text(
                "WACC",
              ),
              trailing: Text(
                (buyingControllers["price"]!.text.isEmpty ||
                        buyingControllers["quantity"]!.text.isEmpty)
                    ? "0"
                    : (double.parse(buyingControllers["totalAmount"]!.text) /
                            _buyCalculation.quantity)
                        .toStringAsFixed(2),
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
              prefixText: "Rs. ",
              readOnly: _buyCalculation.isPriceLocked ==
                  _buyCalculation.isQuantityLocked,
            ),
          ],
        ),
      ),
    );
  }

  reverseBuyingWidgetBlock() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            CustomTextField(
              hintText: "Enter the buying price per share",
              labelText: "Buying Price per Share",
              keyboardType: TextInputType.phone,
              prefixText: "Rs. ",
              textController: reverseBuyingControllers["price"],
              suffixWidget: IconButton(
                icon: Icon(
                  _reverseBuyCalculation.isPriceLocked
                      ? MdiIcons.lock
                      : MdiIcons.lockOpenVariant,
                ),
                onPressed: () {
                  setState(() {
                    _reverseBuyCalculation.isPriceLocked =
                        !_reverseBuyCalculation.isPriceLocked;
                  });
                },
              ),
              readOnly: _reverseBuyCalculation.isPriceLocked,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              textController: reverseBuyingControllers["quantity"],
              hintText: "Enter the total shares you're purchasing",
              labelText: "Number of Shares",
              keyboardType: TextInputType.phone,
              readOnly: _reverseBuyCalculation.isQuantityLocked,
              suffixWidget: IconButton(
                icon: Icon(
                  _reverseBuyCalculation.isQuantityLocked
                      ? MdiIcons.lock
                      : MdiIcons.lockOpenVariant,
                ),
                onPressed: () {
                  setState(() {
                    _reverseBuyCalculation.isPriceLocked =
                        !_reverseBuyCalculation.isPriceLocked;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
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
                      .calculateTotalCharges(
                          _reverseBuyCalculation.transactionAmount)
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
              title: const Text(
                "WACC",
              ),
              trailing: Text(
                (reverseBuyingControllers["price"]!.text.isEmpty ||
                        reverseBuyingControllers["quantity"]!.text.isEmpty)
                    ? "0"
                    : (double.parse(
                                reverseBuyingControllers["totalAmount"]!.text) /
                            _reverseBuyCalculation.quantity)
                        .toStringAsFixed(2),
              ),
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              textController: reverseBuyingControllers["totalAmount"],
              hintText: "Total Amount",
              labelText: "Total Amount",
              keyboardType: TextInputType.phone,
              prefixText: "Rs. ",
            ),
            TextButton(
                onPressed: () {
                  // BuyCalculation val = calculationProvider.calculateReverseBuy(
                  //   buyCalculation: BuyCalculation(
                  //       quantity: 2000,
                  //       price: 0,
                  //       isPriceLocked: false,
                  //       isQuantityLocked: true),
                  //   totalAmount: 250887.5,
                  // );
                  SellCalculation sellval =
                      calculationProvider.calculateReverseForSell(
                          sellCalculation: SellCalculation(
                            quantity: 1000,
                            price: 0,
                            buyingPrice: 170,
                            sellingPrice: 250,
                            netReceivableAmount: 100000,
                            holdingDays: HoldinDays.lessThanYear,
                          ),
                          isSellPriceLocked: true);
                  print(sellval.quantity);
                },
                child: Text("asd")),
          ],
        ),
      ),
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
            prefixText: "Rs. ",
            textController: sellingControllers["buyPrice"],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            hintText: "Enter sell price",
            labelText: "Sell Price (per Share)",
            keyboardType: TextInputType.number,
            prefixText: "Rs. ",
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
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("7.5%"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("5%"),
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
            prefixText: "Rs. ",
            textController: sellingControllers["netReceivableAmount"],
          ),
          TextButton(
              onPressed: () {
                // BuyCalculation val = calculationProvider.calculateReverseBuy(
                //   buyCalculation: BuyCalculation(
                //       quantity: 2000,
                //       price: 0,
                //       isPriceLocked: false,
                //       isQuantityLocked: true),
                //   totalAmount: 250887.5,
                // );
                SellCalculation sellval =
                    calculationProvider.calculateReverseForSell(
                  sellCalculation: SellCalculation(
                    quantity: 1000,
                    price: 0,
                    buyingPrice: 170,
                    sellingPrice: 0,
                    netReceivableAmount: 100000,
                    holdingDays: HoldinDays.lessThanYear,
                  ),
                  isSellPriceLocked: false,
                );
                print(sellval.sellingPrice);
              },
              child: Text("asd")),
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
              prefixText: "Rs. ",
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
              prefixText: "Rs. ",
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
            padding: const EdgeInsets.all(16.0),
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
                    "Rs. ${calculationProvider.calculateCapitalGain(
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
                  title: const Text('Gain Tax %'),
                  trailing: Text(
                      _sellCalculation.holdingDays == HoldinDays.lessThanYear
                          ? "7.5%"
                          : "5%"),
                ),
                const Divider(
                  color: Colors.grey,
                  indent: 10,
                  endIndent: 10,
                ),
                ListTile(
                  dense: true,
                  title: const Text('Capital Gain Tax'),
                  trailing:
                      Text("Rs. ${calculationProvider.calculateCapitalGainTax(
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
                      ? "You fall under the 7.5% capital gain tax slab as the holding period is more than 1 year"
                      : "You fall under the 5% capital gain tax slab as the holding period is less than 1 year",
                  style: const TextStyle(fontSize: 11),
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
            padding: const EdgeInsets.all(16.0),
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
                    calculationProvider.calculateDpCharges().toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('SEBON Commission'),
                  trailing: Text(
                    calculationProvider
                        .calculateSebonFee(transactionAmount)
                        .toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Broker Commission'),
                  trailing: Text(
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
                    calculationProvider
                        .calculateTotalCharges(transactionAmount)
                        .toStringAsFixed(2),
                  ),
                ),
                Text(
                  calculationProvider.getCommissionMessage(transactionAmount),
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
