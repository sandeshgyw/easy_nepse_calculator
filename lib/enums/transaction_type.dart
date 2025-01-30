enum TransactionTypes {
  buying,
  selling,
  rightShareAdjustment,
  bonusShareAdjustment,
  merger,
  reverseBuying,
  reverseSelling,
}

enum HoldinDays {
  lessThanYear,
  moreThanYear,
}

enum ReverseCalculationTypes {
  priceCalculation,
  quantityCalculation,
}

getTransactionType(String type) {
  switch (type) {
    case "buying":
      return TransactionTypes.buying;
    case "selling":
      return TransactionTypes.selling;

    case "rightShareAdjustment":
      return TransactionTypes.rightShareAdjustment;

    case "bonusShareAdjustment":
      return TransactionTypes.bonusShareAdjustment;

    case "merger":
      return TransactionTypes.merger;

    case "reverseBuying":
      return TransactionTypes.reverseBuying;

    case "reverseSelling":
      return TransactionTypes.reverseSelling;

    default:
      return TransactionTypes.buying;
  }
}

getString(TransactionTypes type) {
  switch (type) {
    case TransactionTypes.buying:
      return "Buying";

    case TransactionTypes.selling:
      return "Selling";

    case TransactionTypes.rightShareAdjustment:
      return "Right Share Adjustment";

    case TransactionTypes.bonusShareAdjustment:
      return "Bonus Share Adjustment";

    case TransactionTypes.merger:
      return "Merger";

    case TransactionTypes.reverseBuying:
      return "Reverse Buying";

    case TransactionTypes.reverseSelling:
      return "Reverse Selling";

    default:
      return "Buying";
  }
}
