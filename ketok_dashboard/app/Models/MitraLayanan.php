<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MitraLayanan extends Model
{
    protected $table = 'mitra_layanan';
    protected $primaryKey = 'id_layanan_mitra';
    public $timestamps = false;

    protected $fillable = [
        'mitra_id',
        'katagori_id',
        'nama_jasa',
        'deskripsi',
        'tarif_mulai',
        'tarif_selesai',
        'satuan_tarif',
        'biaya_kunjungan',
        'aktif',
        'foto_url',
    ];

    public function mitra()
    {
        return $this->belongsTo(User::class, 'mitra_id', 'id_user');
    }

    public function kategori()
    {
        return $this->belongsTo(KategoriLayanan::class, 'katagori_id', 'id_katagori');
    }
}
