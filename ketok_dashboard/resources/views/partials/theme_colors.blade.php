{{-- 
    ======================================================================
    FILE KONFIGURASI WARNA TEMA (PALET WARNA KETOK PLATFORM)
    Semua warna dashboard dan halaman admin terpusat di file ini.
    Cukup ubah nilai warna di file ini, seluruh halaman admin akan otomatis berubah.
    ======================================================================
--}}

{{-- 1. CSS Custom Properties / Variables (:root) --}}
<style>
    :root {
        --color-brand-primary: #030813;      /* Warna utama gelap / Dark Primary */
        --color-brand-dark: #030813;         /* Warna gelap */
        --color-brand-dark-sec: #1A202C;     /* Warna gelap sekunder */
        --color-brand-bg: #F8F9FB;           /* Background halaman */
        --color-brand-surface: #FFFFFF;      /* Latar kartu / putih */
        --color-brand-surface-low: #F3F4F6;  /* Background badge / surface tipis */
        --color-brand-card: #FFFFFF;         /* Warna latar kartu */
        --color-brand-border: #E7E8EA;       /* Border / garis pemisah */
        --color-brand-text: #191C1E;         /* Teks utama */
        --color-brand-muted: #76777C;        /* Teks abu-abu / keterangan */
        --color-brand-success: #18A673;      /* Status sukses / aktif (Hijau) */
        --color-brand-danger: #E53E3E;       /* Peringatan / titik notif / error (Merah) */
        --color-brand-warning: #E09A00;      /* Status warning / pending (Ketok App) */
        --color-brand-accent: #0284C7;       /* Aksen biru / info */
    }
</style>

{{-- 2. Konfigurasi Tailwind CSS untuk Class 'brand-*' --}}
<script>
    tailwind.config = {
        theme: {
            extend: {
                fontFamily: {
                    sans: ['"Plus Jakarta Sans"', 'ui-sans-serif', 'system-ui', 'sans-serif'],
                },
                colors: {
                    brand: {
                        primary: '#030813',      // KetokColors.darkPrimary
                        dark: '#030813',         // KetokColors.darkPrimary
                        darkSec: '#1A202C',      // KetokColors.primary
                        bg: '#F8F9FB',           // KetokColors.bgColor
                        surface: '#FFFFFF',      // KetokColors.surfaceCard
                        surfaceLow: '#F3F4F6',   // KetokColors.surfaceLow
                        card: '#FFFFFF',
                        border: '#E7E8EA',       // KetokColors.borderColor
                        text: '#191C1E',         // KetokColors.onSurface
                        muted: '#76777C',        // KetokColors.onSurfaceVariant
                        success: '#18A673',      // Ketok status online / success
                        danger: '#E53E3E',       // Ketok notification dot / alert
                        warning: '#E09A00',      // KetokColors.warning (Ketok App)
                        accent: '#0284C7',       // Status info / blue accent
                    }
                }
            }
        }
    }
</script>
