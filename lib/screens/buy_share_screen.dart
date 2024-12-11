import 'package:easy_nepse_calculator/models/buy_calculation.dart';
import 'package:easy_nepse_calculator/providers/calculation_provider.dart';
import 'package:easy_nepse_calculator/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuyShareScreen extends StatefulWidget {
  const BuyShareScreen({super.key});

  @override
  State<BuyShareScreen> createState() => _BuyShareScreenState();
}

class _BuyShareScreenState extends State<BuyShareScreen> {
  double commissionAndFees = 0;
  late CalculationProvider calculationProvider;
  final BuyCalculation _buyCalculation = BuyCalculation(
    quantity: 0,
    price: 0,
    totalAmount: 0,
    isPriceLocked: true,
  );
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  TextEditingController totalAmountController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState

    quantityController.addListener(() {
      if (quantityController.text == "") {
        _buyCalculation.quantity = 0;
        totalAmountController.text = ((_buyCalculation.transactionAmount +
                calculationProvider
                    .calculateTotalCharges(_buyCalculation.transactionAmount)))
            .toStringAsFixed(2);

        setState(() {});
        return;
      }
      _buyCalculation.quantity = double.parse(quantityController.text);
      totalAmountController.text = ((_buyCalculation.transactionAmount +
              calculationProvider
                  .calculateTotalCharges(_buyCalculation.transactionAmount)))
          .toStringAsFixed(2);
      setState(() {});
    });

    priceController.addListener(() {
      if (priceController.text == "") {
        _buyCalculation.price = 0;
        totalAmountController.text = ((_buyCalculation.transactionAmount +
                calculationProvider
                    .calculateTotalCharges(_buyCalculation.transactionAmount)))
            .toStringAsFixed(2);

        setState(() {});
        return;
      }

      _buyCalculation.price = double.parse(priceController.text);
      totalAmountController.text = ((_buyCalculation.transactionAmount +
              calculationProvider
                  .calculateTotalCharges(_buyCalculation.transactionAmount)))
          .toStringAsFixed(2);
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    calculationProvider = Provider.of<CalculationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Calculation"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: buyingWidgetBlock(),
        ),
      ),
    );
  }

  feeModalSheet() {
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
                        .calculateSebonFee(_buyCalculation.transactionAmount)
                        .toStringAsFixed(2),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Broker Commission'),
                  trailing: Text(
                    calculationProvider
                        .calculateCommission(_buyCalculation.transactionAmount)
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
                        .calculateTotalCharges(
                            _buyCalculation.transactionAmount)
                        .toStringAsFixed(2),
                  ),
                ),
                const Text(
                  "You fall under the 0.34% broker commision slab as the transaction amount is above 25000",
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          );
        });
  }

  buyingWidgetBlock() {
    return [
      SizedBox(
        height: 10,
      ),
      CustomTextField(
        hintText: "Enter the buying price per share",
        labelText: "Buying Price per Share",
        keyboardType: TextInputType.phone,
        prefixText: "Rs. ",
        textController: priceController,
      ),
      const SizedBox(
        height: 10,
      ),
      CustomTextField(
        textController: quantityController,
        hintText: "Enter the total shares you're purchasing",
        labelText: "Number of Shares",
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(
        height: 10,
      ),
      const Divider(),
      ListTile(
        onTap: feeModalSheet,
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
            (priceController.text == "" || quantityController.text == "")
                ? "0"
                : (double.parse(totalAmountController.text) /
                        _buyCalculation.quantity)
                    .toStringAsFixed(2),
          ),
        ),
      ),
      const Divider(),
      const SizedBox(
        height: 10,
      ),
      CustomTextField(
        readOnly: true,
        textController: totalAmountController,
        hintText: "Total Amount",
        labelText: "Total Amount",
        keyboardType: TextInputType.phone,
        prefixText: "Rs. ",
      ),
    ];
  }
}
