import 'package:flutter/services.dart';

const Set<String> indianVehicleStateCodes = {
  'AN',
  'AP',
  'AR',
  'AS',
  'BR',
  'CG',
  'CH',
  'DD',
  'DL',
  'DN',
  'GA',
  'GJ',
  'HP',
  'HR',
  'JH',
  'JK',
  'KA',
  'KL',
  'LA',
  'LD',
  'MH',
  'ML',
  'MN',
  'MP',
  'MZ',
  'NL',
  'OD',
  'OR',
  'PB',
  'PY',
  'RJ',
  'SK',
  'TG',
  'TN',
  'TR',
  'TS',
  'UA',
  'UK',
  'UP',
  'WB',
};

String? validateVehicleNumber(String? value) {
  final vehicleNumber = value?.trim().toUpperCase() ?? '';

  if (vehicleNumber.isEmpty) {
    return 'Vehicle number is required';
  }

  final regex = RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{0,3}\d{1,4}$');
  if (!regex.hasMatch(vehicleNumber)) {
    return 'Enter a valid vehicle registration number';
  }

  final stateCode = vehicleNumber.substring(0, 2);
  if (!indianVehicleStateCodes.contains(stateCode)) {
    return 'Enter a valid vehicle registration number';
  }

  return null;
}

String? validateIndianMobileNumber(String? value) {
  final phone = value?.trim() ?? '';

  if (phone.isEmpty) {
    return 'Phone number is required';
  }

  if (phone.length != 10) {
    return 'Phone number must be 10 digits';
  }

  if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
    return 'Enter a valid Indian mobile number';
  }

  return null;
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class VehicleNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    final filtered = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;
    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}

/// Keeps numeric input usable for decimal amounts such as charges.
///
/// Everything except digits and a single `.` is stripped as it is typed, so
/// negative signs, letters and a second decimal point can never enter the
/// field. At most [maxDecimalPlaces] digits are kept after the point, which
/// matches the currency precision the database stores.
class DecimalTextFormatter extends TextInputFormatter {
  const DecimalTextFormatter({this.maxDecimalPlaces = 2});

  final int maxDecimalPlaces;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final firstDot = text.indexOf('.');
    if (firstDot != -1) {
      // Keep only the first decimal point.
      final whole = text.substring(0, firstDot + 1);
      var fraction = text.substring(firstDot + 1).replaceAll('.', '');
      if (fraction.length > maxDecimalPlaces) {
        fraction = fraction.substring(0, maxDecimalPlaces);
      }
      text = '$whole$fraction';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class GSTNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    final filtered = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final limited = filtered.length > 15 ? filtered.substring(0, 15) : filtered;
    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}
