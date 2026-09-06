import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KetokApp extends StatelessWidget {
  const KetokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ketok',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ketok App'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final response = await Supabase.instance.client
                        .from('kategori_layanan')
                        .select();
                    print('Berhasil: $response');
                  } catch (e) {
                    print('Gagal: $e');
                  }
                },
                child: Text('Test Koneksi Supabase'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}