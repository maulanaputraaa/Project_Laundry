import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../database/database_helper.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  // Controller untuk input pada form
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Daftar role yang bisa dipilih
  final List<String> _roles = ['admin', 'karyawan'];
  String? _selectedRole;

  // List untuk menyimpan data user dari database
  List<Map<String, dynamic>> _userList = [];

  // Flag untuk menentukan mode edit atau tambah
  bool _isEditing = false;
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _fetchUserList();
  }

  // Mengambil daftar user dari database
  Future<void> _fetchUserList() async {
    final dbHelper = DatabaseHelper.instance;
    final userList = await dbHelper.getAllUsers();
    setState(() {
      _userList = userList;
    });
  }

  // Menambahkan atau memperbarui user di database
  Future<void> _addOrUpdateUser() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    if (username.isEmpty || password.isEmpty || role == null) {
      _showErrorDialog('Username, Password, dan Role tidak boleh kosong.');
      return;
    }

    final dbHelper = DatabaseHelper.instance;

    if (_isEditing && _editingId != null) {
      // Memperbarui data user
      await dbHelper.updateUser(_editingId!, username, password, role);
      Fluttertoast.showToast(
        msg: "User berhasil diperbarui",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      // Menambahkan data user baru
      await dbHelper.insertUser(username, password, role);
      Fluttertoast.showToast(
        msg: "User berhasil ditambahkan",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    _clearForm();
    _fetchUserList();
  }

  // Mengisi form untuk mode edit
  void _editUser(Map<String, dynamic> user) {
    setState(() {
      _isEditing = true;
      _editingId = user['id'];
      _usernameController.text = user['username'];
      _passwordController.text = user['password'];
      _selectedRole = user['role'];
    });
  }

  // Menghapus user dari database
  Future<void> _deleteUser(int id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteUser(id);
    Fluttertoast.showToast(
      msg: "User berhasil dihapus",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    _fetchUserList();
  }

  // Membersihkan form setelah selesai
  void _clearForm() {
    setState(() {
      _isEditing = false;
      _editingId = null;
      _usernameController.clear();
      _passwordController.clear();
      _selectedRole = null;
    });
  }

  // Menampilkan dialog error jika ada validasi gagal
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
        title: Text('Kelola User'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form untuk menambah atau mengedit user
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
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Dropdown untuk memilih role
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Role harus dipilih';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addOrUpdateUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreenAccent,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Perbarui User',
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

            // Daftar User
            Expanded(
              child: ListView.builder(
                itemCount: _userList.length,
                itemBuilder: (context, index) {
                  final user = _userList[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(user['username']),
                      subtitle: Text('Role: ${user['role']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editUser(user),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user['id']),
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
