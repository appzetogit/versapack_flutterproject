import '../utils/currency_formatter.dart';

extension NumFormatting on num {
  String get asCurrency => CurrencyFormatter.format(this);
  String get asCurrencyPrecise =>
      CurrencyFormatter.format(this, decimals: true);

  /// Percentage saved when [this] is the selling price and [mrp] the strike price.
  int discountPercentFrom(num? mrp) {
    if (mrp == null || mrp <= 0 || mrp <= this) return 0;
    return (((mrp - this) / mrp) * 100).round();
  }
}

extension DoubleRounding on double {
  double roundTo(int places) {
    final f = [1, 10, 100, 1000][places.clamp(0, 3)];
    return (this * f).round() / f;
  }
}
