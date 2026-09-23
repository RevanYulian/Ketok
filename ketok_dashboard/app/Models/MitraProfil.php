<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MitraProfil extends Model
{
    protected $table = 'mitra_profil';
    protected $primaryKey = 'id_profil';
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'katagori_id',
        'nama_usaha',
        'sub_kategori',
        'keahlian',
        'wilayah_operasional',
        'status_online',
        'provinsi',
        'kota',
        'kecamatan',
        'kelurahan',
        'status_verifikasi',
        'foto_ktp',
        'nik',
        'catatan_verifikasi',
    ];

    public function getWilayahTampilAttribute()
    {
        $parts = array_filter([
            $this->kelurahan ? 'Kel. ' . $this->kelurahan : null,
            $this->kecamatan ? 'Kec. ' . $this->kecamatan : null,
            $this->kota,
        ]);

        if (!empty($parts)) {
            return implode(', ', $parts);
        }

        return $this->wilayah_operasional ?? $this->kota ?? 'Malang Raya';
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id_user');
    }

    public function kategori()
    {
        return $this->belongsTo(KategoriLayanan::class, 'katagori_id', 'id_katagori');
    }
}
