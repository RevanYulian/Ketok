<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    protected $table = 'users';
    protected $primaryKey = 'id_user';
    public $timestamps = false;

    protected $fillable = [
        'nama',
        'email',
        'role',
        'status_mitra',
        'auth_uid',
        'foto_profil',
        'no_hp',
        'terakhir_aktif',
    ];

    protected $casts = [
        'terakhir_aktif' => 'datetime',
    ];

    public function mitraProfil()
    {
        return $this->hasOne(MitraProfil::class, 'user_id', 'id_user');
    }


    public function mitraLayanan()
    {
        return $this->hasMany(MitraLayanan::class, 'mitra_id', 'id_user');
    }

    public function pesananSebagaiPengguna()
    {
        return $this->hasMany(Pesanan::class, 'pengguna_id', 'id_user');
    }

    public function pesananSebagaiMitra()
    {
        return $this->hasMany(Pesanan::class, 'mitra_id', 'id_user');
    }

    public function notifikasi()
    {
        return $this->hasMany(Notifikasi::class, 'user_id', 'id_user');
    }
}