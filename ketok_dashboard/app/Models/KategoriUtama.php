<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KategoriUtama extends Model
{
    protected $table = 'kategori_utama';
    protected $primaryKey = 'id_kelompok';
    public $timestamps = false;

    protected $fillable = [
        'nama_kelompok',
    ];

    public function kategori()
    {
        return $this->hasMany(KategoriLayanan::class, 'kelompok', 'nama_kelompok');
    }
}
