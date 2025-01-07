import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_helper.dart';

class CuciSetrikaScreen extends StatefulWidget {
  @override
  _CuciSetrikaState createState() => _CuciSetrikaState();
}

class _CuciSetrikaState extends State<CuciSetrikaScreen> {
  // Controller untuk form input
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  double _totalCost = 0.0;
  double? _pricePerKg;
  int? _userId;

  // Fungsi untuk mengambil harga dari database berdasarkan nama layanan
  Future<void> _getPriceFromDatabase(String namaLayanan) async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    double? harga = await dbHelper.getHargaByNamaJasa(namaLayanan);

    if (harga == null) {
      // Menampilkan dialog error jika harga tidak ditemukan
      _showErrorDialog("Harga untuk layanan $namaLayanan tidak ditemukan di database.");
    } else {
      setState(() {
        _pricePerKg = harga;
      });
    }
  }

  // Fungsi untuk menampilkan dialog error dengan pesan spesifik
  void _showErrorDialog(String pesan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(pesan),
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

  // Fungsi untuk menghitung total biaya berdasarkan berat
  void _calculateTotalCost() {
    final double weight = double.tryParse(_weightController.text) ?? 0.0;
    if (_pricePerKg != null) {
      setState(() {
        _totalCost = weight * _pricePerKg!;
      });
    }
  }

  // Fungsi untuk mengambil ID pengguna yang sedang login dari SharedPreferences
  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  // Fungsi untuk menyimpan data transaksi ke database
  Future<void> _saveToDatabase() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;

    final namaPelanggan = _nameController.text.trim();
    final alamatPelanggan = _addressController.text.trim();
    final beratSetrika = double.tryParse(_weightController.text) ?? 0.0;

    // Validasi inputan
    if (namaPelanggan.isEmpty || alamatPelanggan.isEmpty || beratSetrika <= 0) {
      _showErrorDialog('Formulir tidak lengkap!');
      return;
    }

    // Pastikan userId tersedia
    if (_userId == null) {
      _showErrorDialog('User tidak ditemukan! Harap login terlebih dahulu.');
      return;
    }

    try {
      final jenisJasa = 'Cuci Setrika';
      final hargaPerItem = _pricePerKg ?? 0.0;
      final totalHarga = _totalCost;
      final tanggal = DateTime.now().toIso8601String();

      // Menyimpan transaksi ke database
      await dbHelper.insertTransaksi(
        userId: _userId!,
        jenisJasa: jenisJasa,
        jumlah: beratSetrika.toInt(),
        hargaPerItem: hargaPerItem,
        totalHarga: totalHarga,
        tanggal: tanggal,
        namaPelanggan: namaPelanggan,
        alamatPelanggan: alamatPelanggan,
      );

      // Menampilkan pesan berhasil menggunakan toast
      Fluttertoast.showToast(
        msg: "Proses Cuci Setrika berhasil!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Reset form setelah berhasil
      _nameController.clear();
      _addressController.clear();
      _weightController.clear();
      setState(() {
        _totalCost = 0.0;
      });
    } catch (e) {
      // Menampilkan pesan error jika terjadi kegagalan
      Fluttertoast.showToast(
        msg: "Proses Cuci Setrika gagal: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserId();  // Ambil userId ketika halaman dimuat
    _getPriceFromDatabase('cuci setrika');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuci Setrika'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.lightBlue.shade400, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              // Header untuk form
              Text(
                'Masukkan Detail Layanan',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Form Nama Pelanggan
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Pelanggan',
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Form Alamat Pelanggan
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Form Berat Cucian
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Berat Cucian (kg)',
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                    ),
                    style: TextStyle(fontSize: 18),
                    onChanged: (value) {
                      _calculateTotalCost();
                    },
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Card untuk menampilkan total biaya
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: Colors.green,
                        size: 50,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Biaya:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Text(
                            'Rp ${_totalCost.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Tombol untuk memproses pesanan
              ElevatedButton(
                onPressed: _saveToDatabase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Proses Pesanan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
