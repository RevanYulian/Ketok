<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Ulasan;
use Illuminate\Http\Request;

class UlasanController extends Controller
{
    public function index(Request $request)
    {
        $query = Ulasan::with(['pesanan.pengguna', 'pesanan.mitra', 'pesanan.kategori']);

        if ($request->filled('rating')) {
            $query->where('rating', $request->rating);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where('komentar', 'ilike', "%{$search}%");
        }

        $reviews = $query->orderBy('id_ulasan', 'desc')->paginate(15);
        $avgRating = Ulasan::avg('rating') ?? 0;
        $totalReviews = Ulasan::count();

        return view('admin.ulasan.index', compact('reviews', 'avgRating', 'totalReviews'));
    }

    public function destroy($id)
    {
        $review = Ulasan::findOrFail($id);
        $review->delete();

        return back()->with('success', 'Ulasan berhasil dihapus.');
    }
}
