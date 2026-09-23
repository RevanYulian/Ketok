<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class Admin extends Authenticatable
{
    use Notifiable;

    protected $table = 'admins';
    protected $primaryKey = 'id_admin';
    public $timestamps = false;

    protected $fillable = [
        'nama',
        'email',
        'password',
        'level_akses',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
        ];
    }

    /**
     * Cek apakah admin memiliki salah satu dari peran yang ditentukan.
     * Super Admin selalu memiliki semua hak akses.
     */
    public function hasRole(string|array $roles): bool
    {
        if ($this->level_akses === 'Super Admin') {
            return true;
        }

        if (is_string($roles)) {
            $roles = array_map('trim', explode(',', $roles));
        } elseif (is_array($roles)) {
            $roles = array_map('trim', $roles);
        }

        return in_array($this->level_akses, $roles);
    }

    /**
     * Cek apakah admin dapat mengakses menu tertentu
     */
    public function canAccess(string $menu): bool
    {
        if ($this->level_akses === 'Super Admin') {
            return true;
        }

        return match ($menu) {
            'dashboard' => true,
            'admins' => false,
            'pengguna' => in_array($this->level_akses, ['Customer Service']),
            'mitra', 'mitra_layanan', 'kategori', 'artikel', 'wilayah' => in_array($this->level_akses, ['Operasional']),
            'pesanan' => in_array($this->level_akses, ['Operasional', 'Customer Service', 'Keuangan']),
            'keuangan' => in_array($this->level_akses, ['Keuangan']),
            'ulasan' => in_array($this->level_akses, ['Customer Service']),
            'notifikasi' => in_array($this->level_akses, ['Operasional', 'Customer Service']),
            'tampilan_aplikasi' => false,
            default => false,
        };
    }

    /**
     * Dapatkan warna indikator badge untuk peran admin
     */
    public function getRoleColor(): string
    {
        return match ($this->level_akses) {
            'Super Admin' => '#A855F7',
            'Operasional' => '#0284C7',
            'Customer Service' => '#D97706',
            'Keuangan' => '#059669',
            default => '#6B7280',
        };
    }
}
