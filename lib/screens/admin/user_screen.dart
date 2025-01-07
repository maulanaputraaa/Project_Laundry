import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../database/database_helper.dart';

// Widget untuk layar tambah user baru
class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  // Controller untuk input username dan password
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Menyimpan role yang dipilih oleh pengguna
  String? _selectedRole = 'admin';

  // Fungsi untuk menambahkan user baru ke database
  void _addUser() async {
    // Ambil data dari form
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String role = _selectedRole!;

    // Validasi form, pastikan username dan password tidak kosong
    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Username dan Password tidak boleh kosong!');
      return;
    }

    // Menambahkan user baru ke dalam database
    try {
      final int userId = await DatabaseHelper.instance.insertUser(username, password, role);
      print('User berhasil ditambahkan dengan ID: $userId');

      // Menampilkan notifikasi toast jika berhasil menambahkan user
      Fluttertoast.showToast(
        msg: "User berhasil ditambahkan",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Mengosongkan form setelah berhasil menambahkan user
      _clearForm();
    } catch (e) {
      print("Error saat menambahkan user: $e");
      _showErrorDialog('Terjadi kesalahan saat menambahkan user.');
    }
  }

  // Menampilkan dialog error jika terjadi kesalahan atau input kosong
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

  // Fungsi untuk mengosongkan form setelah data berhasil disimpan
  void _clearForm() {
    setState(() {
      _usernameController.clear();
      _passwordController.clear();
      _selectedRole = 'admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah User Baru'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Input Username
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Input Password
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true, // Menyembunyikan karakter password
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Pilihan Role (Admin/Karyawan)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Pilih Role',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['admin', 'karyawan'].map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 30),

            // Tombol untuk menambahkan user baru
            Center(
              child: ElevatedButton(
                onPressed: _addUser, // Memanggil fungsi untuk menambahkan user
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Tambah User', // Teks tombol
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Ekstensi untuk string agar bisa mengubah huruf pertama menjadi kapital
extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1).toLowerCase();
  }
}
