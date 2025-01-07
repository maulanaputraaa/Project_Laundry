import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../database/database_helper.dart';

class AddEditJasaScreen extends StatefulWidget {
  final int? jasaId;
  final String? initialNamaJasa;
  final double? initialHarga;

  AddEditJasaScreen({this.jasaId, this.initialNamaJasa, this.initialHarga});

  @override
  _AddEditJasaScreenState createState() => _AddEditJasaScreenState();
}

class _AddEditJasaScreenState extends State<AddEditJasaScreen> {
  final TextEditingController _jasaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Jika dalam mode edit, isi form dengan data awal
    if (widget.initialNamaJasa != null) {
      _jasaController.text = widget.initialNamaJasa!;
    }
    if (widget.initialHarga != null) {
      _hargaController.text = widget.initialHarga!.toStringAsFixed(0);
    }
  }

  // Fungsi untuk menyimpan jasa baru atau memperbarui jasa yang ada
  Future<void> _saveJasa() async {
    // Validasi form terlebih dahulu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final namaJasa = _jasaController.text.trim();
    final harga = double.parse(_hargaController.text.trim());
    final dbHelper = DatabaseHelper.instance;

    bool isSuccess;
    String message;

    if (widget.jasaId != null) {
      // Jika mode edit, perbarui jasa
      int result = await dbHelper.updateJasa(widget.jasaId!, namaJasa, harga);
      isSuccess = result > 0;
      message = isSuccess ? 'Jasa berhasil diperbarui!' : 'Gagal memperbarui jasa.';
    } else {
      // Jika mode tambah, tambahkan jasa baru
      int result = await dbHelper.insertJasa(namaJasa, harga);
      isSuccess = result > 0;
      message = isSuccess ? 'Jasa berhasil ditambahkan!' : 'Gagal menambahkan jasa.';
    }

    // Tampilkan notifikasi menggunakan toast
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    if (isSuccess) {
      _clearForm();
    }
  }

  // Fungsi untuk mengosongkan form
  void _clearForm() {
    setState(() {
      _jasaController.clear();
      _hargaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jasaId == null ? 'Tambah Jasa' : 'Edit Jasa'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.jasaId == null ? 'Tambah Jasa Baru' : 'Edit Jasa',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),
              // Input untuk nama jasa
              TextFormField(
                controller: _jasaController,
                decoration: InputDecoration(
                  labelText: 'Nama Jasa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama jasa tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Input untuk harga jasa
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga (Rp)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              // Tombol untuk menyimpan jasa
              Center(
                child: ElevatedButton(
                  onPressed: _saveJasa,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    widget.jasaId == null ? 'Tambah Jasa' : 'Simpan Perubahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
