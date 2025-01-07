import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Nama dan versi database
  static const _databaseName = "laundry.db";
  static const _databaseVersion = 1;

  // Nama-nama tabel
  static const tableJasa = 'jasa';
  static const tableUser = 'user';
  static const tableTransaksi = 'transaksi';

  // Kolom untuk tabel jasa
  static const columnId = 'id';
  static const columnNamaJasa = 'namaJasa';
  static const columnHarga = 'harga';

  // Kolom untuk tabel user
  static const columnUserId = 'id';
  static const columnUsername = 'username';
  static const columnPassword = 'password';
  static const columnRole = 'role';

  // Kolom untuk tabel transaksi
  static const columnTransaksiId = 'id';
  static const columnUserIdFK = 'userId';
  static const columnNamaPelanggan = 'namaPelanggan';
  static const columnAlamatPelanggan = 'alamatPelanggan';
  static const columnJenisJasa = 'jenisJasa';
  static const columnJumlah = 'jumlah';
  static const columnHargaPerItem = 'hargaPerItem';
  static const columnTotalHarga = 'totalHarga';
  static const columnTanggal = 'tanggal';
  static const columnKeterangan = 'keterangan';

  // Singleton untuk mengelola instance DatabaseHelper
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  // Konstruktor privat untuk singleton
  DatabaseHelper._privateConstructor();

  // Mendapatkan instance database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inisialisasi database dan membuka koneksi
  Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Membuat tabel-tabel dalam database saat pertama kali
  Future<void> _onCreate(Database db, int version) async {
    print("Creating tables...");

    // Membuat tabel jasa
    await db.execute(''' 
      CREATE TABLE $tableJasa (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNamaJasa TEXT NOT NULL,
        $columnHarga REAL NOT NULL
      )
    ''');

    // Membuat tabel user
    await db.execute(''' 
      CREATE TABLE $tableUser (
        $columnUserId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUsername TEXT NOT NULL UNIQUE,
        $columnPassword TEXT NOT NULL,
        $columnRole TEXT NOT NULL
      )
    ''');

    // Membuat tabel transaksi
    await db.execute(''' 
      CREATE TABLE $tableTransaksi (
        $columnTransaksiId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUserIdFK INTEGER NOT NULL,
        $columnNamaPelanggan TEXT NOT NULL,
        $columnAlamatPelanggan TEXT NOT NULL,
        $columnJenisJasa TEXT NOT NULL,
        $columnJumlah INTEGER NOT NULL,
        $columnHargaPerItem REAL NOT NULL,
        $columnTotalHarga REAL NOT NULL,
        $columnTanggal TEXT NOT NULL,
        $columnKeterangan TEXT,
        FOREIGN KEY ($columnUserIdFK) REFERENCES $tableUser($columnUserId)
      )
    ''');

    print("Tables created.");
  }

  // Fungsi untuk menambahkan jasa baru
  Future<int> insertJasa(String namaJasa, double harga) async {
    Database db = await database;
    return await db.insert(tableJasa, {
      columnNamaJasa: namaJasa,
      columnHarga: harga,
    });
  }

  // Fungsi untuk menambahkan user baru
  Future<int> insertUser(String username, String password, String role) async {
    Database db = await database;
    return await db.insert(tableUser, {
      columnUsername: username,
      columnPassword: password,
      columnRole: role,
    });
  }

  // Fungsi untuk mengambil semua jasa
  Future<List<Map<String, dynamic>>> getAllJasa() async {
    Database db = await database;
    return await db.query(tableJasa);
  }

  // Fungsi untuk mengambil semua user
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    Database db = await database;
    return await db.query(tableUser);
  }

  // Fungsi untuk memperbarui user berdasarkan ID dan role
  Future<int> updateUser(int id, String username, String password, String role) async {
    Database db = await database;
    return await db.update(
      tableUser,
      {
        columnUsername: username,
        columnPassword: password,
        columnRole: role,
      },
      where: '$columnUserId = ?',
      whereArgs: [id],
    );
  }

  // Menambahkan fungsi untuk memeriksa kredensial user di database
  Future<Map<String, dynamic>?> getUserByCredentials(String username, String password) async {
    Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      tableUser,
      where: '$columnUsername = ? AND $columnPassword = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Fungsi untuk menghapus user berdasarkan ID
  Future<int> deleteUser(int id) async {
    Database db = await database;
    return await db.delete(
      tableUser,
      where: '$columnUserId = ?',
      whereArgs: [id],
    );
  }

  // Fungsi untuk memperbarui jasa berdasarkan ID
  Future<int> updateJasa(int id, String namaJasa, double harga) async {
    Database db = await database;
    return await db.update(
      tableJasa,
      {
        columnNamaJasa: namaJasa,
        columnHarga: harga,
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Fungsi untuk menghapus jasa berdasarkan ID
  Future<int> deleteJasa(int id) async {
    Database db = await database;
    return await db.delete(
      tableJasa,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Fungsi untuk mengambil harga berdasarkan nama jasa
  Future<double?> getHargaByNamaJasa(String namaJasa) async {
    Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      tableJasa,
      columns: ['harga'],
      where: '$columnNamaJasa = ?',
      whereArgs: [namaJasa],
    );

    if (result.isNotEmpty) {
      return result.first['harga'] as double;
    } else {
      return null;
    }
  }

  // Fungsi untuk menambahkan transaksi
  Future<int> insertTransaksi({
    required int userId,
    required String namaPelanggan,
    required String alamatPelanggan,
    required String jenisJasa,
    required int jumlah,
    required double hargaPerItem,
    required double totalHarga,
    required String tanggal,
    String? keterangan,
  }) async {
    Database db = await database;
    return await db.insert(tableTransaksi, {
      columnUserIdFK: userId,
      columnNamaPelanggan: namaPelanggan,
      columnAlamatPelanggan: alamatPelanggan,
      columnJenisJasa: jenisJasa,
      columnJumlah: jumlah,
      columnHargaPerItem: hargaPerItem,
      columnTotalHarga: totalHarga,
      columnTanggal: tanggal,
      columnKeterangan: keterangan,
    });
  }

  // Fungsi untuk mengambil semua transaksi
  Future<List<Map<String, dynamic>>> getAllTransaksi() async {
    Database db = await database;
    return await db.query(tableTransaksi, orderBy: '$columnTanggal DESC');
  }

  // Fungsi untuk mengambil nama by id
  Future<String> getUserNameById(int userId) async {
    final db = await database;
    final result = await db.query(
      'User',
      columns: ['Username'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first['username'] as String;
    } else {
      return 'Unknown User';
    }
  }

  // Menghapus database jika perlu (untuk debugging)
  Future<void> deleteDatabaseFile() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);
    await deleteDatabase(path);
    print("Database deleted");
  }
}
