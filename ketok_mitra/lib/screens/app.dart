import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KetokMitraApp extends StatelessWidget {
  const KetokMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ketok Mitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFE0177A),
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String _status = 'Belum ada percobaan koneksi.';

  Future<void> _testConnection() async {
    setState(() => _status = 'Menghubungkan ke Supabase...');
    try {
      final response =
          await Supabase.instance.client.from('kategori_layanan').select();
      setState(() => _status = 'Berhasil: $response');
    } catch (e) {
      setState(() => _status = 'Gagal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ketok Mitra')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ketok Mitra App',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _testConnection,
                child: const Text('Test Koneksi Supabase'),
              ),
              const SizedBox(height: 20),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
