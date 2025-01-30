import 'package:easy_nepse_calculator/enums/transaction_type.dart';

class Calculation {
  double quantity;
  double price;

  Calculation({
    required this.quantity,
    required this.price,
  });

  toMap() {
    return {
      "quantity": quantity,
      "price": price,
    };
  }

  fromMap(Map? json) {
    if (json == null) return;
    return Calculation(
      quantity: json["quantity"],
      price: json["price"],
    );
  }
}

class BuyCalculation extends Calculation {
  bool isPriceLocked;
  double totalAmount;
  BuyCalculation({
    required super.quantity,
    required super.price,
    required this.isPriceLocked,
    required this.totalAmount,
  });

  double get transactionAmount => quantity * price;
  bool get isQuantityLocked => !isPriceLocked;

  @override
  fromMap(Map? json) {
    // TODO: implement fromMap
    return super.fromMap(json);
  }

  @override
  toMap() {
    // TODO: implement toMap
    return super.toMap();
  }

  double getWacc(double finalPrice) {
    return finalPrice / quantity;
  }
}

class SellCalculation extends Calculation {
  double buyingPrice;
  double sellingPrice;
  double netReceivableAmount;
  HoldinDays holdingDays;

  bool isSellPriceLocked;

  double get sellTransactionAmount => quantity * sellingPrice;

  bool get isQuantityLocked => !isSellPriceLocked;

  double get buyTransactionAmount => quantity * buyingPrice;

  SellCalculation({
    required super.quantity,
    required super.price,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.netReceivableAmount,
    required this.isSellPriceLocked,
    required this.holdingDays,
  });
}

class BonusAdjustMentCalculation {
  double marketPrice;
  double bonusPercent;
  BonusAdjustMentCalculation({
    required this.marketPrice,
    required this.bonusPercent,
  });
}

class RightShareAdjustmentCalculation {
  double marketPrice;
  int paidUpValue;
  double rightSharePercent;
  RightShareAdjustmentCalculation({
    required this.marketPrice,
    required this.paidUpValue,
    required this.rightSharePercent,
  });
}
