import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class JasaListScreen extends StatefulWidget {
  @override
  _JasaListScreenState createState() => _JasaListScreenState();
}

class _JasaListScreenState extends State<JasaListScreen> {
  final TextEditingController _jasaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  List<Map<String, dynamic>> _jasaList = [];
  bool _isEditing = false;
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _fetchJasaList();
  }

  /// Mengambil daftar jasa dari database dan memperbarui tampilan.
  Future<void> _fetchJasaList() async {
    final dbHelper = DatabaseHelper.instance;
    final jasaList = await dbHelper.getAllJasa();
    setState(() {
      _jasaList = jasaList;
    });
  }

  /// Menambahkan atau memperbarui data jasa di database.
  Future<void> _addOrUpdateJasa() async {
    final jasa = _jasaController.text.trim();
    final harga = double.tryParse(_hargaController.text.trim());

    if (jasa.isEmpty || harga == null) {
      _showErrorDialog('Nama jasa atau harga tidak valid.');
      return;
    }

    final dbHelper = DatabaseHelper.instance;

    if (_isEditing && _editingId != null) {
      await dbHelper.updateJasa(_editingId!, jasa, harga);
    } else {
      await dbHelper.insertJasa(jasa, harga);
    }

    _clearForm();
    _fetchJasaList();
  }

  /// Memulai mode edit untuk data jasa tertentu.
  void _editJasa(Map<String, dynamic> jasa) {
    setState(() {
      _isEditing = true;
      _editingId = jasa['id'];
      _jasaController.text = jasa['namaJasa'];
      _hargaController.text = jasa['harga'].toString();
    });
  }

  /// Menghapus data jasa dari database berdasarkan ID.
  Future<void> _deleteJasa(int id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteJasa(id);
    _fetchJasaList();
  }

  /// Membersihkan form dan mengatur ulang mode edit.
  void _clearForm() {
    setState(() {
      _isEditing = false;
      _editingId = null;
      _jasaController.clear();
      _hargaController.clear();
    });
  }

  /// Menampilkan dialog error dengan pesan tertentu.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Jasa'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form untuk tambah atau edit jasa
            if (_isEditing)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _jasaController,
                        decoration: InputDecoration(
                          labelText: 'Nama Jasa',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _hargaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga (Rp)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addOrUpdateJasa,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreenAccent,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Perbarui Jasa',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      TextButton(
                        onPressed: _clearForm,
                        child: Text('Batal', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),

            // Daftar jasa yang diambil dari database
            Expanded(
              child: ListView.builder(
                itemCount: _jasaList.length,
                itemBuilder: (context, index) {
                  final jasa = _jasaList[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(jasa['namaJasa']),
                      subtitle: Text('Harga: Rp ${jasa['harga']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editJasa(jasa),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteJasa(jasa['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
