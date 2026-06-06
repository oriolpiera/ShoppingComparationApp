import 'package:flutter/material.dart';

import '../../../core/normalization/family_normalization.dart';
import '../../persistence/domain/entities/product_family.dart';

void showValidationSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Widget buildFamilyAutocompleteField({
  required TextEditingController familyController,
  required Iterable<ProductFamily> families,
  String? helperText,
}) {
  return Autocomplete<String>(
    optionsBuilder: (textEditingValue) {
      final query = textEditingValue.text.trim();
      if (query.length < 3) {
        return const Iterable<String>.empty();
      }
      final normalizedQuery = normalizeFamilySearchText(query);
      final names = families.map((f) => f.name).toSet().toList()..sort();
      return names
          .where(
            (name) => normalizeFamilySearchText(name).contains(normalizedQuery),
          )
          .take(8);
    },
    onSelected: (selection) {
      familyController.text = selection;
    },
    fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
      if (textController.text != familyController.text) {
        textController.value = TextEditingValue(
          text: familyController.text,
          selection: TextSelection.collapsed(
            offset: familyController.text.length,
          ),
        );
      }
      return TextField(
        controller: textController,
        focusNode: focusNode,
        onChanged: (value) => familyController.text = value,
        decoration: InputDecoration(
          labelText: 'Family',
          helperText: _buildFamilyFieldHelperText(extraContext: helperText),
          helperMaxLines: 2,
        ),
      );
    },
  );
}

String? _buildFamilyFieldHelperText({String? extraContext}) {
  const suggestionHint = 'Suggestions from 3 chars';
  if (extraContext == null || extraContext.isEmpty) {
    return suggestionHint;
  }
  return '$extraContext\n$suggestionHint';
}
