<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use Illuminate\Http\Request;

class KeuanganController extends Controller
{
    public function index(Request $request)
    {
        $query = Invoice::with(['pesanan.pengguna', 'pesanan.mitra', 'pesanan.kategori']);

        if ($request->filled('status_bayar')) {
            $query->where('status_bayar', $request->status_bayar);
        }

        $invoices = $query->orderBy('id_invoice', 'desc')->paginate(15);

        // Agregasi Keuangan
        $totalPendapatan = Invoice::where('status_bayar', 'lunas')->sum('jumlah_biaya') ?? 0;
        $totalKomisi = $totalPendapatan * 0.10; // 10% Platform fee Ketok
        $totalPendapatanMitra = $totalPendapatan * 0.90; // 90% Hak mitra
        $pendingBayar = Invoice::where('status_bayar', 'menunggu')->sum('jumlah_biaya') ?? 0;

        return view('admin.keuangan.index', compact(
            'invoices',
            'totalPendapatan',
            'totalKomisi',
            'totalPendapatanMitra',
            'pendingBayar'
        ));
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status_bayar' => 'required|in:menunggu,lunas,kadaluarsa',
        ]);

        $invoice = Invoice::findOrFail($id);
        $invoice->status_bayar = $request->status_bayar;
        $invoice->save();

        return back()->with('success', "Status invoice #INV-{$invoice->id_invoice} berhasil diperbarui.");
    }

    public function exportCsv()
    {
        $invoices = Invoice::with(['pesanan.pengguna', 'pesanan.mitra'])->get();

        $filename = "laporan_komisi_ketok_" . date('Ymd_His') . ".csv";
        $handle = fopen('php://output', 'w');

        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename="' . $filename . '"');

        fputcsv($handle, ['ID Pesanan', 'Pelanggan', 'Mitra', 'Total Biaya', 'Komisi Platform (10%)', 'Hak Bersih Mitra (90%)', 'Status Bayar']);

        foreach ($invoices as $inv) {
            $total = $inv->jumlah_biaya ?? 0;
            fputcsv($handle, [
                'KTK-' . ($inv->pesanan_id ?? '-'),
                $inv->pesanan->pengguna->nama ?? 'Pelanggan',
                $inv->pesanan->mitra->nama ?? 'Mitra',
                $total,
                $total * 0.10,
                $total * 0.90,
                $inv->status_bayar ?? 'menunggu'
            ]);
        }

        fclose($handle);
        exit;
    }
}
