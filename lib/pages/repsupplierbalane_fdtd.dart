import 'package:flutter/material.dart';
import 'package:spackerpnext/components/my_dropdownmenu.dart';
class Supplier {
  String id, name, groupId, groupName;
  double debitOpening, creditOpening, openingBalance, debit, credit, closingBalance;
  Supplier(this.id, this.name, this.groupId, this.groupName, this.debitOpening, this.creditOpening, this.openingBalance,
      this.debit, this.credit, this.closingBalance);
}
List<Supplier> suppliers = [
  Supplier("1", "hamza", "1", "Group1", 1000, 500, 500, 200, 300, 400),
  Supplier("2", "Gaza", "2", "Group2", 1500, 1000, 500, 300, 400, 400),
  Supplier("3", "Saeed", "1", "Group1", 2000, 1500, 500, 400, 500, 400),
];
void main() {
  runApp(const RepSupplierBalanceFdtd());
}
class RepSupplierBalanceFdtd extends StatefulWidget {
  const RepSupplierBalanceFdtd({super.key});
  @override
  RepSupplierBalanceFdtdState createState() => RepSupplierBalanceFdtdState();
}
class RepSupplierBalanceFdtdState extends State<RepSupplierBalanceFdtd> {
  String selectedSupplierId = suppliers[0].id;
  String selectedGroupId = suppliers[0].groupId;

  @override
  Widget build(BuildContext context) {
    if (selectedSupplierId == null && suppliers.isNotEmpty) {
      selectedSupplierId = suppliers[0].id;
    }
    if (selectedGroupId == null && suppliers.isNotEmpty) {
      selectedGroupId = suppliers[0].groupId;
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("تقرير الموردين"),
        ),
        body: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("اسم المورد")),
                    DataColumn(label: Text("مجموعة الموردين")),
                    DataColumn(label: Text("الدائن الافتتاحي")),
                    DataColumn(label: Text("المدين الافتتاحي")),
                    DataColumn(label: Text("الرصيد الافتتاحي")),
                    DataColumn(label: Text("المدين")),
                    DataColumn(label: Text("الدائن")),
                    DataColumn(label: Text("الرصيد النهائي")),
                  ],
                  rows: suppliers
                      .where((supplier) =>
                  (supplier.id == selectedSupplierId || selectedSupplierId.isEmpty) &&
                      (supplier.groupId == selectedGroupId || selectedGroupId.isEmpty))
                      .map(
                        (supplier) => DataRow(
                      cells: [
                        DataCell(Text(supplier.name)),
                        DataCell(Text(supplier.groupName)),
                        DataCell(Text(supplier.debitOpening.toString())),
                        DataCell(Text(supplier.creditOpening.toString())),
                        DataCell(Text(supplier.openingBalance.toString())),
                        DataCell(Text(supplier.debit.toString())),
                        DataCell(Text(supplier.credit.toString())),
                        DataCell(Text(supplier.closingBalance.toString())),
                      ],
                      onSelectChanged: (selected) {
                        if (selected ?? false) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(supplier.name),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("مجموعة الموردين: ${supplier.groupName}"),
                                    Text("المدين الافتتاحي: ${supplier.debitOpening}"),
                                    Text("الدائن الافتتاحي: ${supplier.creditOpening}"),
                                    Text("الرصيد الافتتاحي: ${supplier.openingBalance}"),
                                    Text("المدين: ${supplier.debit}"),
                                    Text("الدائن: ${supplier.credit}"),
                                    Text("الرصيد النهائي: ${supplier.closingBalance}"),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
