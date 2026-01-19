import 'package:flutter/material.dart';
import 'package:sharp_cut/core/database/database_helper.dart';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends State<DatabaseViewerScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> _tables = [];
  String? _selectedTable;
  List<Map<String, dynamic>> _tableData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTables();
  }

  Future<void> _fetchTables() async {
    setState(() {
      _isLoading = true;
    });
    final tables = await _dbHelper.getTables();
    setState(() {
      _tables = tables;
      _isLoading = false;
    });
  }

  Future<void> _fetchTableData(String tableName) async {
    setState(() {
      _isLoading = true;
      _selectedTable = tableName;
    });
    final data = await _dbHelper.getTableData(tableName);
    setState(() {
      _tableData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Database Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_selectedTable != null) {
                _fetchTableData(_selectedTable!);
              } else {
                _fetchTables();
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Side: Table List
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  width: double.infinity,
                  child: const Text(
                    "Tables",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: _isLoading && _tables.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _tables.length,
                          itemBuilder: (context, index) {
                            final table = _tables[index];
                            final isSelected = table == _selectedTable;
                            return ListTile(
                              title: Text(table),
                              selected: isSelected,
                              selectedTileColor: Colors.blue.shade50,
                              onTap: () => _fetchTableData(table),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // Right Side: Data Table
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  width: double.infinity,
                  child: Text(
                    _selectedTable != null
                        ? "Data: $_selectedTable (${_tableData.length} rows)"
                        : "Select a table to view data",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading && _selectedTable != null
                      ? const Center(child: CircularProgressIndicator())
                      : _selectedTable == null
                      ? const Center(child: Text("No table selected"))
                      : _tableData.isEmpty
                      ? const Center(child: Text("No data in this table"))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: _tableData.first.keys
                                  .map((key) => DataColumn(label: Text(key)))
                                  .toList(),
                              rows: _tableData.map((row) {
                                return DataRow(
                                  cells: row.values
                                      .map(
                                        (value) => DataCell(
                                          Text(value?.toString() ?? "NULL"),
                                        ),
                                      )
                                      .toList(),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
