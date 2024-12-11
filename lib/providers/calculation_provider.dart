import 'package:easy_nepse_calculator/enums/transaction_type.dart';
import 'package:easy_nepse_calculator/models/buy_calculation.dart';
import 'package:flutter/material.dart';

class CalculationProvider extends ChangeNotifier {
  double buyingPrice = 0;
  double buyQuantity = 0;

  double calculateWacc(double finalPrice, double quantity) {
    return finalPrice / quantity;
  }

  double calculateBuyPrice(double transactionAmount) {
    return transactionAmount + calculateTotalCharges(transactionAmount);
  }

  double calculateNetReceivableAmount({
    required double sellPrice,
    required double buyPrice,
    required double quantity,
    required bool isInstitutional,
    required HoldinDays holdingDays, // Days
  }) {
    double gainTax = calculateCapitalGainTax(
      sellPrice: sellPrice,
      buyPrice: buyPrice,
      quantity: quantity,
      isInstitutional: isInstitutional,
      holdingDays: holdingDays,
    );
    double fees = calculateTotalCharges(sellPrice * quantity);

    return sellPrice * quantity - gainTax - fees;
  }

  double calculateCommission(double transactionAmount) {
    double commission = 0.0;

    if (transactionAmount <= 50000) {
      double percentageCommission = transactionAmount * 0.0036; // 0.36%
      commission = percentageCommission > 10.0 ? percentageCommission : 10.0;
    } else if (transactionAmount <= 500000) {
      commission = transactionAmount * 0.0033; // 0.33%
    } else if (transactionAmount <= 2000000) {
      commission = transactionAmount * 0.0031; // 0.31%
    } else if (transactionAmount <= 10000000) {
      commission = transactionAmount * 0.0027; // 0.27%
    } else {
      commission = transactionAmount * 0.0024; // 0.24%
    }

    return commission;
  }

  String getCommissionMessage(double transactionAmount) {
    if (transactionAmount <= 50000) {
      double percentageCommission = transactionAmount * 0.0036; // 0.36%
      if (percentageCommission > 10.0) {
        return "You fall under the 0.36% slab as the amount is less than or equal to 50,000.";
      } else {
        return "You are charged Rs. 10 as commission because the calculated commission is less than Rs. 10.";
      }
    } else if (transactionAmount <= 500000) {
      double commission = transactionAmount * 0.0033; // 0.33%
      return "You fall under the 0.33% slab as the amount is between 50,001 and 500,000.";
    } else if (transactionAmount <= 2000000) {
      double commission = transactionAmount * 0.0031; // 0.31%
      return "You fall under the 0.31% slab as the amount is between 500,001 and 2,000,000.";
    } else if (transactionAmount <= 10000000) {
      double commission = transactionAmount * 0.0027; // 0.27%
      return "You fall under the 0.27% slab as the amount is between 2,000,001 and 10,000,000.";
    } else {
      double commission = transactionAmount * 0.0024; // 0.24%
      return "You fall under the 0.24% slab as the amount is greater than 10,000,000.";
    }
  }

  // double calculateReverseBuyPrice({
  //   //reverse
  //   required double totalCapital,
  //   required int quantity,
  //   required double commissionRate,
  //   required double sebonFeeRate,
  //   double dpCharges = 25.0,
  // }) {
  //   // Total fees percentage (Commission + SEBON fee)
  //   double totalFeeRate = commissionRate + sebonFeeRate;

  //   // Calculate buy price
  //   double buyPrice =
  //       totalCapital / (quantity * (1 + totalFeeRate) + (dpCharges / quantity));

  //   return buyPrice;
  // }

  BuyCalculation calculateReverseBuy({
    required BuyCalculation buyCalculation,
    required double totalAmount,
    double tolerance = 0.01, // Convergence tolerance
    int maxIterations = 1000, // Max iterations to prevent infinite loops
  }) {
    // Step 1: Validate the state
    if (buyCalculation.isPriceLocked && buyCalculation.isQuantityLocked) {
      throw StateError(
          "Both price and quantity cannot be locked simultaneously.");
    }
    if (!buyCalculation.isPriceLocked && !buyCalculation.isQuantityLocked) {
      throw StateError("At least one of price or quantity must be locked.");
    }

    // Step 2: Deduct fixed charges from the total amount
    double fixedCharges = calculateDpCharges();
    double remainingAmount = totalAmount - fixedCharges;

    if (remainingAmount <= 0) {
      throw ArgumentError("Total amount is too low to cover fixed charges.");
    }

    // Step 3: Initialize variables for iterative calculation
    double previousValue = 0.0; // Previous price/quantity for convergence check
    int iteration = 0;

    do {
      // Step 4: Calculate the transaction amount
      double transactionAmount = buyCalculation.price * buyCalculation.quantity;

      // Step 5: Compute variable charges
      double variableCharges = calculateVariableCharges(transactionAmount);

      // Step 6: Adjust the unlocked value
      if (buyCalculation.isPriceLocked) {
        // Price is locked; calculate quantity
        buyCalculation.quantity =
            (remainingAmount - variableCharges) / buyCalculation.price;
      } else if (buyCalculation.isQuantityLocked) {
        // Quantity is locked; calculate price
        buyCalculation.price =
            (remainingAmount - variableCharges) / buyCalculation.quantity;
      }

      // Step 7: Check for convergence
      double currentValue = buyCalculation.isPriceLocked
          ? buyCalculation.quantity
          : buyCalculation.price;

      if ((currentValue - previousValue).abs() < tolerance) {
        break; // Convergence achieved
      }

      previousValue = currentValue;
      iteration++;

      if (iteration >= maxIterations) {
        throw StateError("Failed to converge after $maxIterations iterations.");
      }
    } while (true);

    // Step 8: Return the updated BuyCalculation object
    return buyCalculation;
  }

  SellCalculation calculateReverseForSell({
    required SellCalculation sellCalculation,
    required bool isSellPriceLocked, // Determines which value is fixed
    double tolerance = 0.01, // Convergence tolerance
    int maxIterations = 100, // Maximum iterations
  }) {
    // Step 1: Initialize variables for iteration
    double previousValue = 0.0; // To track the previous value for convergence
    int iteration = 0;

    // Step 2: Iterative calculation
    do {
      // Step 2.1: Calculate sell transaction amount
      double sellTransactionAmount =
          sellCalculation.sellingPrice * sellCalculation.quantity;

      // Step 2.2: Calculate charges
      double charges = calculateTotalCharges(sellTransactionAmount);

      // Step 2.3: Calculate capital gain tax
      double gainTax = calculateCapitalGainTax(
        sellPrice: sellCalculation.sellingPrice,
        buyPrice: sellCalculation.buyingPrice,
        quantity: sellCalculation.quantity,
        isInstitutional: false, // Assuming individual for now
        holdingDays: sellCalculation.holdingDays,
      );

      // Step 2.4: Adjust the unlocked value
      if (isSellPriceLocked) {
        // Sell price is locked; calculate quantity
        sellCalculation.quantity =
            (sellCalculation.netReceivableAmount + gainTax + charges) /
                sellCalculation.sellingPrice;
      } else {
        // Quantity is locked; calculate sell price
        sellCalculation.sellingPrice =
            (sellCalculation.netReceivableAmount + gainTax + charges) /
                sellCalculation.quantity;
      }

      // Step 2.5: Check for convergence
      double currentValue = isSellPriceLocked
          ? sellCalculation.quantity
          : sellCalculation.sellingPrice;

      if ((currentValue - previousValue).abs() < tolerance) {
        break; // Convergence achieved
      }

      previousValue = currentValue;
      iteration++;

      if (iteration >= maxIterations) {
        throw StateError("Failed to converge after $maxIterations iterations.");
      }
    } while (true);

    // Step 3: Return updated SellCalculation object
    return sellCalculation;
  }

  double calculateVariableCharges(double val) {
    double commission = calculateCommission(val);
    double sebonFee = calculateSebonFee(val);
    return commission + sebonFee;
  }

  double calculateCapitalGainTax({
    required double sellPrice,
    required double buyPrice,
    required double quantity,
    required bool isInstitutional,
    required HoldinDays holdingDays, // Days
  }) {
    double capitalGain = calculateCapitalGain(
      sellPrice: sellPrice,
      buyPrice: buyPrice,
      quantity: quantity,
      isInstitutional: isInstitutional,
      holdingDays: holdingDays,
    );

    double taxRate;
    if (isInstitutional) {
      taxRate = 0.10; // 10% for institutional investors
    } else {
      taxRate = holdingDays == HoldinDays.moreThanYear
          ? 0.05
          : 0.075; // 5% or 7.5% for individuals
    }

    double capitalGainTax = capitalGain * taxRate;

    return capitalGainTax;
  }

  double calculateCapitalGain({
    required double sellPrice,
    required double buyPrice,
    required double quantity,
    required bool isInstitutional,
    required HoldinDays holdingDays, // Days
  }) {
    double profit = (sellPrice - buyPrice) * quantity;
    if (profit <= 0) return 0;
    double commission = calculateCommission(sellPrice * quantity);
    double sebonFee = calculateSebonFee(sellPrice * quantity);

    double capitalGain = profit - (commission + sebonFee);

    return capitalGain;
  }

  double calculateRequiredSellPrice({
    //reverse cal
    required double buyPrice,
    required double desiredProfit,
    required int quantity,
    required double commissionRate,
    required double sebonFeeRate,
    double dpCharges = 25.0,
  }) {
    // Total fees percentage (Commission + SEBON fee)
    double totalFeeRate = commissionRate + sebonFeeRate;

    // Calculate required sell price
    double requiredSellPrice =
        (buyPrice + (desiredProfit / quantity)) * (1 + totalFeeRate);

    return requiredSellPrice;
  }

  double calculateSebonFee(double transactionAmount) {
    return transactionAmount * 0.00015; // 0.015%
  }

  double calculateDpCharges() {
    return 25.0; // Fixed charge of Rs 25
  }

  double calculateTotalCharges(double transactionAmount) {
    double commission = calculateCommission(transactionAmount);
    double sebonFee = calculateSebonFee(transactionAmount);
    double dpCharges = calculateDpCharges();

    return commission + sebonFee + dpCharges;
  }

  double calculateBonusAdjustedPrice(double marketPrice, double bonusPercent) {
    return marketPrice / (1 + (bonusPercent / 100));
  }

  double calculateRightAdjustedPrice(
      double marketPrice, double rightPercent, int paidUpValue) {
    return (marketPrice + (paidUpValue * rightPercent / 100)) /
        (1 + (rightPercent / 100));
  }
}
