<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KategoriLayanan extends Model
{
    protected $table = 'kategori_layanan';
    protected $primaryKey = 'id_katagori';
    public $timestamps = false;

    protected $fillable = [
        'nama_katagori',
        'deskripsi',
        'kelompok',
    ];

    public function jasaLayanan()
    {
        return $this->hasMany(JasaLayanan::class, 'katagori_id', 'id_katagori');
    }

    public function mitraLayanan()
    {
        return $this->hasMany(MitraLayanan::class, 'katagori_id', 'id_katagori');
    }

    public function pesanan()
    {
        return $this->hasMany(Pesanan::class, 'katagori_id', 'id_katagori');
    }
}
