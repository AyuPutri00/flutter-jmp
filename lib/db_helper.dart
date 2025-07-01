import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'rotiku.db');
    return openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE roti (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT,
          deskripsi TEXT,
          harga INTEGER,
          path TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE pesanan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_roti TEXT,
          harga INTEGER,
          latitude REAL,
          longitude REAL,
          nama_pemesan TEXT,
          no_hp TEXT,
          alamat TEXT
        )
      ''');

        await db.insert('roti', {
          'nama': 'Roti Coklat',
          'deskripsi': 'Roti isi coklat lezat yang lumer di mulut.',
          'harga': 8000,
          'path': 'assets/img/roticoklat.jpg',
        });
        await db.insert('roti', {
          'nama': 'Roti Keju',
          'deskripsi': 'Roti lembut dengan taburan keju cheddar gurih.',
          'harga': 9000,
          'path': 'assets/img/rotikeju.jpg',
        });
        await db.insert('roti', {
          'nama': 'Roti Sosis',
          'deskripsi': 'Perpaduan roti empuk dengan sosis sapi premium.',
          'harga': 10000,
          'path': 'assets/img/rotisosis.jpg',
        });
        await db.insert('roti', {
          'nama': 'Roti Abon',
          'deskripsi': 'Roti manis dengan topping abon sapi melimpah.',
          'harga': 9500,
          'path': 'assets/img/rotiabon.jpg',
        });
        await db.insert('roti', {
          'nama': 'Roti Pandan',
          'deskripsi': 'Roti wangi aroma pandan dengan isian selai srikaya.',
          'harga': 8500,
          'path': 'assets/img/rotipandan.jpg',
        });
        await db.insert('roti', {
          'nama': 'Roti Kelapa',
          'deskripsi': 'Isian unti kelapa manis yang mengingatkan rasa klasik.',
          'harga': 7500,
          'path': 'assets/img/rotikelapa.jpg',
        });
        await db.insert('roti', {
          'nama': 'Roti Gandum',
          'deskripsi': 'Roti gandum utuh kaya serat untuk pilihan lebih sehat.',
          'harga': 12000,
          'path': 'assets/img/rotigandum.jpg',
        });
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          // Jika tabel sudah ada, ini cara aman untuk menambahkan kolom baru
          // Namun untuk simplicitas, kita drop dan buat ulang
          await db.execute('ALTER TABLE roti ADD COLUMN path TEXT');
          await db.execute('DROP TABLE IF EXISTS pesanan');
          await db.execute('''
            CREATE TABLE pesanan (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nama_roti TEXT,
              harga INTEGER,
              latitude REAL,
              longitude REAL,
              nama_pemesan TEXT,
              no_hp TEXT,
              alamat TEXT
            )
          ''');
        }
      },
    );
  }

  static Future<Database> getDb() async {
    _database ??= await initDb();
    return _database!;
  }

  static Future<List<Map<String, dynamic>>> getAllRoti() async {
    final db = await getDb();
    return await db.query('roti');
  }

  static Future<void> insertPesanan(Map<String, dynamic> data) async {
    final db = await getDb();
    await db.insert('pesanan', data);
  }

  // Fungsi baru untuk mengambil semua data pesanan
  static Future<List<Map<String, dynamic>>> getAllPesanan() async {
    final db = await getDb();
    return await db.query('pesanan', orderBy: 'id DESC');
  }
}
