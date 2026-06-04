import 'package:flutter/material.dart';

import '../../../core/normalization/family_unit_normalization.dart';
import '../../persistence/domain/entities/product_family.dart';

String? validateItemForFamily({
  required ProductFamily family,
  required double quantity,
  required String unitType,
}) {
  final shoppingUnit =
      family.shoppingUnit ?? inferShoppingUnitFromUnitType(unitType);
  final purchaseMode =
      family.purchaseMode ?? inferPurchaseModeFromUnitType(unitType);

  return validateItemSemantics(
    shoppingUnit: shoppingUnit,
    purchaseMode: purchaseMode,
    packageQuantityAmount: quantity,
    packageQuantityUnit: unitType,
  );
}

void showValidationSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
