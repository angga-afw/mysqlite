import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'db_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD SQLite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CatatanPage(),
    );
  }
}

class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  final _db = DbHelper.instance;
  List<Catatan> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _db.getAll();
    if (!mounted) return;
    setState(() => _items = data);
    debugPrint('Loaded ${_items.length} items');
    debugPrint('Items: ${data.map((e) => e.toMap()).toList()}');
  }

  Future<void> _showForm([Catatan? c]) async {
    final judul = TextEditingController(text: c?.judul);
    final isi = TextEditingController(text: c?.isi);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(c == null ? 'Tambah Catatan' : 'Edit Catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: judul,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: isi,
              decoration: const InputDecoration(labelText: 'Isi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (ok != true || judul.text.trim().isEmpty) return;

    final baru = Catatan(
      id: c?.id,
      judul: judul.text.trim(),
      isi: isi.text.trim(),
    );
    if (c == null) {
      await _db.insert(baru);
    } else {
      await _db.update(baru);
    }
    debugPrint('Saved: ${baru.toMap()}');
    _load();
  }

  Future<void> _hapus(Catatan c) async {
    await _db.delete(c.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('CRUD SQLite'),
      ),
      body: _items.isEmpty
          ? const Center(child: Text('Belum ada catatan'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final c = _items[i];
                return ListTile(
                  title: Text(c.judul),
                  subtitle: Text(c.isi),
                  onTap: () => _showForm(c),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _hapus(c),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        tooltip: 'Tambah',
        child: const Icon(Icons.add),
      ),
    );
  }
}
