import 'package:flutter/material.dart';

import '../../../customer/domain/entities/customer.dart';
import 'master_lookup_dialog.dart';

/// Opens the customer master as the legacy weighbridge software presented it.
///
/// The counterpart to [MaterialMasterDialog], reached from the search icon
/// beside CUSTOMER CODE. Mobile number and GST number are folded into the
/// filter without becoming columns, matching the legacy grid's three columns
/// while still letting an operator find a party by either number.
class CustomerMasterDialog {
  const CustomerMasterDialog._();

  static const String dialogTitle = 'SELECT CUSTOMER';

  static Future<Customer?> show(
    BuildContext context, {
    required List<Customer> customers,
    Customer? selectedCustomer,
  }) {
    return MasterLookupDialog.show<Customer>(
      context,
      title: dialogTitle,
      items: customers,
      selectedItem: selectedCustomer,
      searchHint: 'Search by code or name',
      emptyMessage: 'No customers found',
      searchTerms: _searchTerms,
      columns: const [
        MasterLookupColumn<Customer>(
          title: 'Customer Code',
          value: _code,
          flex: 3,
          align: TextAlign.center,
          bold: true,
        ),
        MasterLookupColumn<Customer>(
          title: 'Customer Name',
          value: _name,
          flex: 5,
          bold: true,
        ),
      ],
    );
  }

  static String _code(Customer item) => item.customerCode;

  static String _name(Customer item) => item.name;

  static Iterable<String> _searchTerms(Customer item) {
    return [
      if (item.contactPerson != null) item.contactPerson!,
      if (item.mobile != null) item.mobile!,
      if (item.gstNumber != null) item.gstNumber!,
      if (item.city != null) item.city!,
    ];
  }
}
