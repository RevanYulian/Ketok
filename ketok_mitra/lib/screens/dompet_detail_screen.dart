import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/ketok_colors.dart';

class DompetDetailScreen extends StatefulWidget {
  const DompetDetailScreen({super.key});

  @override
  State<DompetDetailScreen> createState() => _DompetDetailScreenState();
}

class _DompetDetailScreenState extends State<DompetDetailScreen> {
  bool _loading = true;
  String? _errorMessage;
  double _totalIncome = 0;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      _totalIncome = 0;
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) throw Exception('Sesi login tidak ditemukan.');
      final user = await client
          .from('users')
          .select('id_user')
          .eq('auth_uid', authUser.id)
          .maybeSingle();
      if (user == null) throw Exception('Data mitra tidak ditemukan.');

      final orders = await client
          .from('pesanan')
          .select('id_pesanan, status, jadwal, katagori_id')
          .eq('mitra_id', user['id_user'])
          .order('jadwal', ascending: false);
      final transactions = <Map<String, dynamic>>[];
      for (final order in orders) {
        final invoice = await client
            .from('invoice')
            .select('jumlah_biaya, status_bayar')
            .eq('pesanan_id', order['id_pesanan'])
            .maybeSingle();
        final amount = (invoice?['jumlah_biaya'] as num?)?.toDouble() ?? 0;
        if (amount == 0) continue;
        final category = await client
            .from('kategori_layanan')
            .select('nama_katagori')
            .eq('id_katagori', order['katagori_id'])
            .maybeSingle();
        transactions.add({
          'id_pesanan': order['id_pesanan'],
          'status': order['status'],
          'status_bayar': invoice?['status_bayar'],
          'jumlah_biaya': amount,
          'jadwal': order['jadwal'],
          'category_name': category?['nama_katagori'] ?? 'Layanan Ketok',
        });
        if (order['status'] == 'selesai' &&
            invoice?['status_bayar'] == 'lunas') {
          _totalIncome += amount;
        }
      }
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _currency(num value) {
    final formatted = value.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $formatted';
  }

  String _dateLabel(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year}, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KetokColors.bgColor,
      appBar: AppBar(
        title: const Text('Detail Dompet'),
        backgroundColor: KetokColors.bgColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A202C),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total pendapatan selesai',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currency(_totalIncome),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Riwayat transaksi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  if (_transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('Belum ada transaksi.')),
                    )
                  else
                    ..._transactions.map(_buildTransaction),
                ],
              ),
            ),
    );
  }

  Widget _buildTransaction(Map<String, dynamic> transaction) {
    final completed = transaction['status'] == 'selesai';
    final date = DateTime.tryParse(transaction['jadwal']?.toString() ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KetokColors.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                (completed ? const Color(0xFF15803D) : const Color(0xFFB45309))
                    .withValues(alpha: 0.12),
            child: Icon(
              completed ? Icons.arrow_downward_rounded : Icons.schedule_rounded,
              color: completed
                  ? const Color(0xFF15803D)
                  : const Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['category_name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  date == null ? 'Tanggal tidak tersedia' : _dateLabel(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: KetokColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  completed
                      ? 'Pendapatan masuk'
                      : 'Pesanan ${transaction['status']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: KetokColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _currency(transaction['jumlah_biaya'] as num),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: completed
                  ? const Color(0xFF15803D)
                  : KetokColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
