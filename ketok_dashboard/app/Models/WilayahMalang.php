<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WilayahMalang extends Model
{
    protected $table = 'wilayah_malang';
    protected $primaryKey = 'id_wilayah';
    public $timestamps = false;

    protected $fillable = [
        'nama',
        'tipe',
        'parent_nama',
    ];
}
