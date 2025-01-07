import 'package:flutter/material.dart';
import 'package:project_laundry/screens/admin/daftar_jasa_screen.dart';
import 'package:project_laundry/screens/admin/daftar_user_screen.dart';
import 'package:project_laundry/screens/admin/jasa_screen.dart';
import 'package:project_laundry/screens/admin/user_screen.dart';
import 'package:project_laundry/screens/login/login_screen.dart';
import 'package:project_laundry/screens/login/register_screen.dart';
import 'package:project_laundry/screens/menu/cuci_kering_screen.dart';
import 'package:project_laundry/screens/menu/cuci_sepatu_screen.dart';
import 'package:project_laundry/screens/menu/riwayat_screen.dart';
import 'package:project_laundry/screens/menu/setrika_screen.dart';
import 'screens/menu/home_screen.dart';
import 'screens/menu/cuci_setrika_screen.dart';
import 'screens/admin/admin_screen.dart';

class Routes {
  // Nama rute yang digunakan dalam aplikasi
  static const String home = '/home';
  static const String cucisepatu = '/cucisepatu';
  static const String cucikering = '/cucikering';
  static const String cucisetrika = '/cucisetrika';
  static const String setrika = '/setrika';
  static const String admin = '/admin';
  static const String addjasa = '/addjasa';
  static const String adduser = '/adduser';
  static const String listjasa = '/listjasa';
  static const String listuser = '/listuser';
  static const String listtransaksi = '/listtransaksi';
  static const String login = '/login';
  static const String register ='/register';

  // Peta rute yang menghubungkan nama rute dengan widget yang sesuai
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => HomeScreen(),
    cucisepatu: (context) => CuciSepatuScreen(),
    cucikering: (context) => CuciKeringScreen(),
    cucisetrika: (context) => CuciSetrikaScreen(),
    setrika: (context) => SetrikaScreen(),
    admin: (context) => AdminScreen(),
    addjasa: (context) => AddEditJasaScreen(),
    adduser: (context) => AddUserScreen(),
    listjasa: (context) => JasaListScreen(),
    listuser: (context) => UserListScreen(),
    listtransaksi: (context) => TransaksiScreen(),
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
  };

  /// Fungsi untuk menangani navigasi antar halaman.
  ///
  /// [settings] berisi informasi tentang nama rute dan argumen (jika ada).
  /// Fungsi ini akan mengembalikan halaman sesuai rute yang terdaftar,
  /// atau halaman error jika rute tidak ditemukan.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final WidgetBuilder? builder = routes[settings.name];

    if (builder != null) {
      return MaterialPageRoute(builder: builder);
    }

    // Tampilkan halaman error jika rute tidak ditemukan
    return _errorRoute();
  }

  /// Halaman default untuk menangani rute yang tidak ditemukan.
  ///
  /// Menampilkan pesan 404 - Halaman Tidak Ditemukan.
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
        body: const Center(child: Text('404 - Halaman Tidak Ditemukan')),
      ),
    );
  }
}
