<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class JasaLayanan extends Model
{
    protected $table = 'jasa_layanan';
    protected $primaryKey = 'id_jasa';
    public $timestamps = false;

    protected $fillable = [
        'katagori_id',
        'kategori_menu',
        'nama_jasa',
        'deskripsi',
        'harga_mulai',
        'aktif',
    ];

    public function kategori()
    {
        return $this->belongsTo(KategoriLayanan::class, 'katagori_id', 'id_katagori');
    }
}
