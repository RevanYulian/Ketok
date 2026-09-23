<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pesanan extends Model
{
    protected $table = 'pesanan';
    protected $primaryKey = 'id_pesanan';
    public $timestamps = false;

    protected $fillable = [
        'pengguna_id',
        'mitra_id',
        'katagori_id',
        'status',
        'lokasi',
        'jadwal',
        'catatan',
        'biaya_kunjungan',
        'status_persetujuan_biaya',
    ];

    public function pengguna()
    {
        return $this->belongsTo(User::class, 'pengguna_id', 'id_user');
    }

    public function mitra()
    {
        return $this->belongsTo(User::class, 'mitra_id', 'id_user');
    }

    public function kategori()
    {
        return $this->belongsTo(KategoriLayanan::class, 'katagori_id', 'id_katagori');
    }

    public function invoice()
    {
        return $this->hasOne(Invoice::class, 'pesanan_id', 'id_pesanan');
    }

    public function ulasan()
    {
        return $this->hasOne(Ulasan::class, 'pesanan_id', 'id_pesanan');
    }
}
