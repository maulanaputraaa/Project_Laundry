import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class TransaksiScreen extends StatefulWidget {
  @override
  _TransaksiScreenState createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  // List untuk menyimpan data transaksi
  List<Map<String, dynamic>> _transaksiList = [];

  @override
  void initState() {
    super.initState();
    _fetchTransaksi();
  }

  // Fungsi untuk mengambil data transaksi dari database
  Future<void> _fetchTransaksi() async {
    final dbHelper = DatabaseHelper.instance;
    final transaksiList = await dbHelper.getAllTransaksi();
    setState(() {
      _transaksiList = transaksiList;
    });
  }

  // Fungsi untuk mengambil nama user berdasarkan userId
  Future<String> _getUserNameById(int userId) async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.getUserNameById(userId);
  }

  // Fungsi untuk menentukan satuan berdasarkan jenis jasa
  String _getSatuan(String jenisJasa) {
    if (jenisJasa == "Setrika" ||
        jenisJasa == "Cuci Kering" ||
        jenisJasa == "Cuci Setrika") {
      return "kg";
    } else if (jenisJasa == "Cuci Sepatu") {
      return "pasang";
    } else {
      return "NULL";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semua Transaksi'),
      ),
      body: _transaksiList.isEmpty
          ? Center(
        child: Text('Belum ada transaksi.'),
      )
          : ListView.builder(
        itemCount: _transaksiList.length,
        itemBuilder: (context, index) {
          final transaksi = _transaksiList[index];
          final satuan = _getSatuan(transaksi['jenisJasa']);

          // Ambil nama user yang menginputkan transaksi dengan FutureBuilder
          return FutureBuilder<String>(
            future: _getUserNameById(transaksi['userId']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final userName = snapshot.data!;

                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Jenis Jasa: ${transaksi['jenisJasa']}'),
                    subtitle: Text(
                      'Jumlah: ${transaksi['jumlah']} $satuan\n'
                          'Harga Per Item: Rp ${transaksi['hargaPerItem']}\n'
                          'Total Harga: Rp ${transaksi['totalHarga']}\n'
                          'Dinput oleh: $userName',
                    ),
                    trailing: Text('Tanggal: ${transaksi['tanggal']}'),
                  ),
                );
              } else {
                return Center(child: Text('Nama user tidak ditemukan.'));
              }
            },
          );
        },
      ),
    );
  }
}
