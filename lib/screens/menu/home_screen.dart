import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _role = '';

  // Fungsi untuk memuat role pengguna dari SharedPreferences
  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Amalia Laundry',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 4,
        backgroundColor: Colors.blueAccent,
        actions: [
          // Menampilkan tombol hanya jika role adalah 'admin'
          if (_role == 'admin')
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/admin');
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang!',
                  style: TextStyles.headingStyle.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Temukan layanan laundry terbaik untukmu.',
                  style: TextStyles.subHeadingStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildServiceCard(
                        context,
                        title: 'Cuci & Setrika',
                        icon: Icons.local_laundry_service,
                        gradientColors: [Colors.blue.shade400, Colors.blue.shade800],
                        onTap: () {
                          Navigator.pushNamed(context, '/cucisetrika');
                        },
                      ),
                      _buildServiceCard(
                        context,
                        title: 'Cuci Kering',
                        icon: Icons.dry_cleaning,
                        gradientColors: [Colors.teal.shade400, Colors.teal.shade800],
                        onTap: () {
                          Navigator.pushNamed(context, '/cucikering');
                        },
                      ),
                      _buildServiceCard(
                        context,
                        title: 'Cuci Sepatu',
                        icon: Icons.snowshoeing_sharp,
                        gradientColors: [Colors.orange.shade400, Colors.orange.shade800],
                        onTap: () {
                          Navigator.pushNamed(context, '/cucisepatu');
                        },
                      ),
                      _buildServiceCard(
                        context,
                        title: 'Setrika',
                        icon: Icons.iron,
                        gradientColors: [Colors.purple.shade400, Colors.purple.shade800],
                        onTap: () {
                          Navigator.pushNamed(context, '/setrika');
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                _buildHistoryContainer(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue.shade400, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyles.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryContainer(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/listtransaksi');
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.history,
              color: Colors.orange.shade800,
              size: 40,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Lihat Riwayat Transaksi',
                style: TextStyles.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.orange.shade800,
            ),
          ],
        ),
      ),
    );
  }
}
