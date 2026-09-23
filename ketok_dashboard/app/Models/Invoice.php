<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    protected $table = 'invoice';
    protected $primaryKey = 'id_invoice';
    public $timestamps = false;

    protected $fillable = [
        'pesanan_id',
        'jumlah_biaya',
        'status_bayar',
        'biaya_jasa',
        'biaya_sparepart',
    ];

    public function pesanan()
    {
        return $this->belongsTo(Pesanan::class, 'pesanan_id', 'id_pesanan');
    }
}
