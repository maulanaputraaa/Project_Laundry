import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Menu'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Pilihan Menu: Tambah/Edit Harga Jasa
            _buildMenuCard(
              context,
              icon: Icons.attach_money,
              iconColor: Colors.green,
              title: 'Tambah Harga Jasa',
              route: '/addjasa',
            ),
            SizedBox(height: 20),
            // Pilihan Menu: Tambah/Edit User
            _buildMenuCard(
              context,
              icon: Icons.person_add,
              iconColor: Colors.orange,
              title: 'Tambah User',
              route: '/adduser',
            ),
            SizedBox(height: 20),
            // Pilihan Menu: Lihat Daftar Jasa
            _buildMenuCard(
              context,
              icon: Icons.list_alt,
              iconColor: Colors.blue,
              title: 'Lihat Daftar Jasa',
              route: '/listjasa',
            ),
            SizedBox(height: 20),
            // Pilihan Menu: Lihat Daftar User
            _buildMenuCard(
              context,
              icon: Icons.list_alt,
              iconColor: Colors.blue,
              title: 'Lihat Daftar User',
              route: '/listuser',
            ),
          ],
        ),
      ),
    );
  }

  /// Membuat widget kartu menu dengan ikon, warna ikon, judul, dan rute navigasi.
  ///
  /// [context] adalah BuildContext untuk navigasi.
  /// [icon] adalah ikon untuk menu.
  /// [iconColor] adalah warna ikon.
  /// [title] adalah teks judul menu.
  /// [route] adalah rute untuk navigasi ke layar yang sesuai.
  Widget _buildMenuCard(BuildContext context,
      {required IconData icon, required Color iconColor, required String title, required String route}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        splashColor: Colors.blueAccent.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
