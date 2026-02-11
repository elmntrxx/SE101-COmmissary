// lib/screens/inventory_management/widgets/ingredient_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../database/app_database.dart';
import '../../../utils/design_constants.dart';

/// Dialog for adding or editing an ingredient
class IngredientFormDialog extends StatefulWidget {
  final Ingredient? ingredient;
  final int commissaryId;
  final Function(IngredientsCompanion) onSave;

  const IngredientFormDialog({
    super.key,
    this.ingredient,
    required this.commissaryId,
    required this.onSave,
  });

  @override
  State<IngredientFormDialog> createState() => _IngredientFormDialogState();
}

class _IngredientFormDialogState extends State<IngredientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _stockController = TextEditingController();
  final _costController = TextEditingController();
  final _criticalLevelController = TextEditingController();

  static const _uuid = Uuid();

  bool get isEditing => widget.ingredient != null;

  // Common units
  final List<String> _commonUnits = [
    'grams',
    'kilograms',
    'milliliters',
    'liters',
    'pieces',
    'packs',
    'boxes',
    'bottles',
    'cans',
    'bags',
  ];

  // Units that only accept whole numbers (no decimals)
  static const _wholeNumberUnits = {
    'pieces',
    'packs',
    'boxes',
    'bottles',
    'cans',
    'bags',
  };
  // Conversion Rules:
  // 1. Same group conversions use standard formulas (1 kg = 1000 g)
  // 2. Cross-group conversions use default factors (TODO: update with actual formulas)
  /// Unit groups for determining conversion compatibility
  static const _unitGroups = {
    'weight': ['grams', 'kilograms'],
    'volume': ['milliliters', 'liters'],
    'countable': ['pieces', 'packs', 'boxes', 'bottles', 'cans', 'bags'],
  };

  /// Standard conversion factors TO base unit within same group
  /// - Weight base unit: grams
  /// - Volume base unit: milliliters
  /// - Countable base unit: pieces
  static const _toBaseUnitFactor = {
    // Weight conversions (to grams)
    'grams': 1.0,
    'kilograms': 1000.0,  // 1 kg = 1000 grams
    
    // Volume conversions (to milliliters)
    'milliliters': 1.0,
    'liters': 1000.0,     // 1 liter = 1000 ml
    
    // Countable conversions (to pieces)
    // TODO: Update these when exact formulas are known
    // Currently 1:1 default - each countable unit equals 1 piece
    'pieces': 1.0,
    'packs': 1.0,         // TODO: Define pack size (e.g., 1 pack = 12 pieces)
    'boxes': 1.0,         // TODO: Define box size (e.g., 1 box = 24 pieces)
    'bottles': 1.0,       // TODO: Define bottle equivalent
    'cans': 1.0,          // TODO: Define can equivalent
    'bags': 1.0,          // TODO: Define bag size
  };
  /// TODO: These are placeholder values - update with actual ingredient-specific conversions
  /// Example: If 1 kg of flour = 8 cups, define the formula here
  static const _crossGroupConversion = {
    // Weight to Volume (assuming water density for now - 1g = 1ml)
    // TODO: Update with actual density formulas
    'weight_to_volume': 1.0,  // 1 gram = 1 ml (water density)
    // Weight to Countable
    // TODO: This needs ingredient-specific data (e.g., 1 chicken piece = 200g)
    'weight_to_countable': 1.0,  // Placeholder: 1 gram = 1 piece (NEEDS UPDATE)
    // Volume to Countable
    // TODO: This needs ingredient-specific data (e.g., 1 bottle = 500ml)
    'volume_to_countable': 1.0,  // Placeholder: 1 ml = 1 piece (NEEDS UPDATE)
  };
  /// Get the group name for a unit
  String _getUnitGroup(String unit) {
    for (final entry in _unitGroups.entries) {
      if (entry.value.contains(unit.toLowerCase())) {
        return entry.key;
      }
    }
    return 'unknown';
  }
  /// Convert stock value from one unit to another
  /// Returns the converted value with appropriate rounding for countable units
  double _convertStock(double value, String fromUnit, String toUnit) {
    fromUnit = fromUnit.toLowerCase();
    toUnit = toUnit.toLowerCase();
    
    if (fromUnit == toUnit) return value;
    
    final fromGroup = _getUnitGroup(fromUnit);
    final toGroup = _getUnitGroup(toUnit);
    
    // Get factors
    final fromFactor = _toBaseUnitFactor[fromUnit] ?? 1.0;
    final toFactor = _toBaseUnitFactor[toUnit] ?? 1.0;
    
    double result;
    
    if (fromGroup == toGroup) {
      // Same group conversion (e.g., kg to grams, liters to ml)
      // Formula: convert to base unit, then to target unit
      // Example: 2 kg -> 2 * 1000 = 2000 grams -> 2000 / 1 = 2000 grams
      // Example: 2 kg -> 2 * 1000 = 2000 grams -> 2000 / 1000 = 2 kg (back)
      final baseValue = value * fromFactor;
      result = baseValue / toFactor;
    } else {
      // Cross-group conversion
      // Step 1: Convert from source unit to source base unit
      final sourceBaseValue = value * fromFactor;
      
      // Step 2: Apply cross-group conversion
      // TODO: Update these formulas when exact conversion rates are known
      double crossGroupFactor;
      if (fromGroup == 'weight' && toGroup == 'volume') {
        crossGroupFactor = _crossGroupConversion['weight_to_volume']!;
      } else if (fromGroup == 'volume' && toGroup == 'weight') {
        crossGroupFactor = 1.0 / _crossGroupConversion['weight_to_volume']!;
      } else if (fromGroup == 'weight' && toGroup == 'countable') {
        crossGroupFactor = _crossGroupConversion['weight_to_countable']!;
      } else if (fromGroup == 'countable' && toGroup == 'weight') {
        crossGroupFactor = 1.0 / _crossGroupConversion['weight_to_countable']!;
      } else if (fromGroup == 'volume' && toGroup == 'countable') {
        crossGroupFactor = _crossGroupConversion['volume_to_countable']!;
      } else if (fromGroup == 'countable' && toGroup == 'volume') {
        crossGroupFactor = 1.0 / _crossGroupConversion['volume_to_countable']!;
      } else {
        crossGroupFactor = 1.0;
      }
      
      final targetBaseValue = sourceBaseValue * crossGroupFactor;
      
      // Step 3: Convert from target base unit to target unit
      result = targetBaseValue / toFactor;
    }
    
    // Round to whole number if target is a countable unit
    if (_wholeNumberUnits.contains(toUnit)) {
      result = result.roundToDouble();
    }
    
    return result;
  }

  bool get _requiresWholeNumber =>
      _wholeNumberUnits.contains(_unitController.text.toLowerCase());

  // Number formatter for thousands separator
  static final _numberFormat = NumberFormat('#,##0.##');

  String _formatWithCommas(String value) {
    if (value.isEmpty) return value;
    // Remove commas and get only digits (and decimal point)
    final cleanValue = value.replaceAll(',', '');
    // Extract digits only (before decimal) to check length
    final parts = cleanValue.split('.');
    final integerPart = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
    // Limit to 8 digits
    if (integerPart.length > 8) {
      final truncatedInt = integerPart.substring(0, 8);
      final truncatedValue = parts.length > 1 ? '$truncatedInt.${parts[1]}' : truncatedInt;
      final number = double.tryParse(truncatedValue);
      if (number == null) return value;
      return _numberFormat.format(number);
    }
    final number = double.tryParse(cleanValue);
    if (number == null) return value;
    return _numberFormat.format(number);
  }

  String _removeCommas(String value) {
    return value.replaceAll(',', '');
  }

  @override
  void initState() {
    super.initState();
    if (widget.ingredient != null) {
      _nameController.text = widget.ingredient!.name;
      _unitController.text = widget.ingredient!.unit;
      _stockController.text = _formatWithCommas(widget.ingredient!.stock.toString());
      _costController.text = _formatWithCommas(widget.ingredient!.costPerUnit.toString());
      _criticalLevelController.text = _formatWithCommas(widget.ingredient!.criticalLevel.toString());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _costController.dispose();
    _criticalLevelController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final companion = IngredientsCompanion(
      id: isEditing ? Value(widget.ingredient!.id) : const Value.absent(),
      cloudId: isEditing 
          ? Value(widget.ingredient!.cloudId) 
          : Value(_uuid.v4()),
      name: Value(_nameController.text.trim()),
      unit: Value(_unitController.text.trim()),
      stock: Value(double.tryParse(_removeCommas(_stockController.text)) ?? 0),
      costPerUnit: Value(double.tryParse(_removeCommas(_costController.text)) ?? 0),
      criticalLevel: Value(double.tryParse(_removeCommas(_criticalLevelController.text)) ?? 10),
      commissaryId: Value(widget.commissaryId),
      isActive: const Value(true),
      needsSync: const Value(true),
    );

    widget.onSave(companion);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        isEditing ? Icons.edit : Icons.add_circle,
                        color: Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Edit Ingredient' : 'Add Ingredient',
                        style: const TextStyle(
                          fontFamily: fontAll,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredient Name *',
                      hintText: 'e.g., Chicken Breast, Cooking Oil',
                      prefixIcon: Icon(Icons.inventory_2),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter ingredient name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Unit of measurement
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _unitController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Unit of Measurement *',
                            hintText: 'Select a unit',
                            prefixIcon: Icon(Icons.straighten),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please select a unit';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: PopupMenuButton<String>(
                          tooltip: 'Common units',
                          icon: const Icon(Icons.arrow_drop_down_circle),
                          onSelected: (unit) {
                            setState(() {
                              final previousUnit = _unitController.text;
                              _unitController.text = unit;
                              
                          
                              // Converts stock value from previous unit to new unit
                              // Example: 1 kg -> 1000 grams, 2 liters -> 2000 ml
                              // Uses default 1:1 factor - TODO: update _crossGroupConversion
                              // with actual formulas when known ref: line 101-106
                              if (previousUnit.isNotEmpty) {
                                final currentStock = double.tryParse(_removeCommas(_stockController.text)) ?? 0;
                                if (currentStock > 0) {
                                  final convertedStock = _convertStock(currentStock, previousUnit, unit);
                                  _stockController.text = _formatWithCommas(
                                    _wholeNumberUnits.contains(unit.toLowerCase())
                                        ? convertedStock.toInt().toString()
                                        : convertedStock.toString(),
                                  );
                                }
                              }
                            });
                          },
                          itemBuilder: (context) => _commonUnits
                              .map((unit) => PopupMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cost and Stock row
                  Row(
                    children: [
                      // Cost per unit
                      Expanded(
                        child: TextFormField(
                          controller: _costController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d,.]'),
                            ),
                          ],
                          onChanged: (value) {
                            final cursorPosition = _costController.selection.baseOffset;
                            final oldLength = value.length;
                            final formatted = _formatWithCommas(value);
                            if (formatted != value) {
                              _costController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: cursorPosition + (formatted.length - oldLength),
                                ),
                              );
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Cost per Unit *',
                            hintText: '0',
                            prefixText: '₱ ',
                            prefixIcon: Icon(Icons.attach_money),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter cost';
                            }
                            final cost = double.tryParse(value.replaceAll(',', ''));
                            if (cost == null || cost < 0) {
                              return 'Invalid cost';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Current stock
                      Expanded(
                        child: TextFormField(
                          // Key forces rebuild when unit type changes
                          key: ValueKey('stock_${_requiresWholeNumber}'),
                          controller: _stockController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: !_requiresWholeNumber,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              _requiresWholeNumber
                                  ? RegExp(r'[\d,]')  // No decimal point for whole-number units
                                  : RegExp(r'[\d,.]'),
                            ),
                          ],
                          onChanged: (value) {
                            final cursorPosition = _stockController.selection.baseOffset;
                            final oldLength = value.length;
                            final formatted = _formatWithCommas(value);
                            if (formatted != value) {
                              _stockController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: cursorPosition + (formatted.length - oldLength),
                                ),
                              );
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Current Stock',
                            hintText: '0',
                            ////helperText: _requiresWholeNumber ? 'Whole numbers only' : null,
                            prefixIcon: const Icon(Icons.inventory),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_requiresWholeNumber && value != null) {
                              final stock = double.tryParse(_removeCommas(value)) ?? 0;
                              if (stock != stock.truncate()) {
                                return 'Must be a whole number';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Critical level
                  TextFormField(
                    controller: _criticalLevelController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[\d,.]'),
                      ),
                    ],
                    onChanged: (value) {
                      final cursorPosition = _criticalLevelController.selection.baseOffset;
                      final oldLength = value.length;
                      final formatted = _formatWithCommas(value);
                      if (formatted != value) {
                        _criticalLevelController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: cursorPosition + (formatted.length - oldLength),
                          ),
                        );
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Critical Level (Low Stock Alert)',
                      hintText: '10',
                      helperText: 'Alert when stock falls below this level',
                      prefixIcon: Icon(Icons.warning_amber),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _handleSave,
                        icon: Icon(isEditing ? Icons.save : Icons.add),
                        label: Text(isEditing ? 'Save Changes' : 'Add Ingredient'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
