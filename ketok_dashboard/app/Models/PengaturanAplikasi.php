<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PengaturanAplikasi extends Model
{
    protected $table = 'pengaturan_aplikasi';
    protected $primaryKey = 'id';
    public $timestamps = false;

    protected $fillable = [
        'tipe_app',
        'nama_aplikasi',
        'tagline',
        'logo_url',
        'splash_url',
        'banner_promo_url',
        'kontak_cs',
        'email_bantuan',
        'versi_aplikasi',
        'status_maintenance',
        'pesan_maintenance',
        'diperbarui_pada',
    ];

    protected $casts = [
        'status_maintenance' => 'boolean',
    ];

    /**
     * Ambil pengaturan berdasarkan tipe (ketok_app / ketok_mitra)
     */
    public static function getByTipe(string $tipe): self
    {
        return static::firstOrCreate(
            ['tipe_app' => $tipe],
            [
                'nama_aplikasi' => $tipe === 'ketok_app' ? 'Ketok' : 'Ketok Mitra',
                'tagline' => $tipe === 'ketok_app' 
                    ? 'Solusi Cepat & Terpercaya Tukang Pertukangan Rumah' 
                    : 'Aplikasi Khusus Tukang & Mitra Profesional Ketok',
                'logo_url' => '/ketok.png',
                'kontak_cs' => '081234567890',
                'email_bantuan' => 'support@ketok.id',
                'versi_aplikasi' => '1.0.0',
                'status_maintenance' => false,
            ]
        );
    }
}
