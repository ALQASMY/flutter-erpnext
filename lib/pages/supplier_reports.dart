import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:spackerpnext/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Supplier {
  String supplier, supplierGroup;
  double openingDebit, openingCredit, openingBalance, debit, credit, closingDebit, closingCredit, closingBalance;
  Supplier(this.supplier, this.supplierGroup, this.openingDebit, this.openingCredit, this.openingBalance, this.debit, this.credit, this.closingDebit, this.closingCredit, this.closingBalance);
}

List<Supplier> suppliers = [];

void main() {
  runApp(const RepSupplierBalanceFdtd());
}

class RepSupplierBalanceFdtd extends StatefulWidget {
  const RepSupplierBalanceFdtd({super.key});
  @override
  RepSupplierBalanceFdtdState createState() => RepSupplierBalanceFdtdState();
}

class RepSupplierBalanceFdtdState extends State<RepSupplierBalanceFdtd> {
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  String supplier = '';
  String supplierGroup = '';

  @override
  void initState() {
    super.initState();
    loginAndGetHeader().then((header) {
      getData(header).then((data) {
        setState(() {
          suppliers = data;
        });
      });
    });
  }


  Future<String> loginAndGetHeader() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? header = prefs.getString('header');
    if (header != null) {
      return header;
    } else {
      logout();
      return '';
    }
  }
  Future<List<Supplier>> getData(String header) async {
    var baseUrl = "http://192.168.56.101:8000";
    var from_date = selectedFromDate.toIso8601String();
    var to_date = selectedToDate.toIso8601String();
    var response = await http.get(
      Uri.parse(baseUrl +"/api/method/erpnext.accounts.report.repsupplierbalancefdtd.api.get_supplier_data?from_date=$from_date&to_date=$to_date&supplier=$supplier&supplier_group=$supplierGroup"),
      headers: {
        "Cookie": header,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body)['message'];
      List<Supplier> suppliers = [];
      for (var item in jsonResponse) {
        suppliers.add(Supplier(item['supplier'], item['supplier_group'], item['opening_debit'], item['opening_credit'], item['opening_balance'], item['debit'], item['credit'], item['closing_debit'], item['closing_credit'], item['closing_balance']));
      }
      return suppliers;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return [];
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('header');
    var pushReplacement = Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("تقرير الموردين"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: logout,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    supplier = value;
                  });
                },

                decoration: InputDecoration(
                  labelText: "المورد",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),


              TextField(
                onChanged: (value) {
                  setState(() {
                    supplierGroup = value;

                  });
                },
                decoration: InputDecoration(
                  labelText: "مجموعة الموردين",
                  fillColor: Colors.green,
                  hoverColor:Colors.green ,
                  border: OutlineInputBorder(),

                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: selectedFromDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  ).then((date) {
                    setState(() {
                      selectedFromDate = date ?? selectedFromDate;
                    });
                  });
                },
                child: Text('من تاريخ: ${selectedFromDate.toLocal()}'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: selectedToDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  ).then((date) {
                    setState(() {
                      selectedToDate = date ?? selectedToDate;
                    });
                  });
                },
                child: Text('إلى تاريخ: ${selectedToDate.toLocal()}'),
              ),
              SizedBox(height: 8),

              ElevatedButton(
                onPressed: () {
                  loginAndGetHeader().then((header) {
                    getData(header).then((data) {
                      setState(() {
                        suppliers = data;
                      });
                    });
                  });
                },
                child: Text('إرسال'),
              ),
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
                        .map(
                          (supplier) => DataRow(
                        cells: [
                          DataCell(Text(supplier.supplier)),
                          DataCell(Text(supplier.supplierGroup)),
                          DataCell(Text(supplier.openingDebit.toString())),
                          DataCell(Text(supplier.openingCredit.toString())),
                          DataCell(Text(supplier.openingBalance.toString())),
                          DataCell(Text(supplier.debit.toString())),
                          DataCell(Text(supplier.credit.toString())),
                          DataCell(Text(supplier.closingBalance.toString())),
                        ],onSelectChanged: (selected) {
                            if (selected ?? false) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(supplier.supplier),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("مجموعة الموردين: ${supplier.supplierGroup}"),
                                        Text("المدين الافتتاحي: ${supplier.openingDebit}"),
                                        Text("الدائن الافتتاحي: ${supplier.openingCredit}"),
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
                    )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
