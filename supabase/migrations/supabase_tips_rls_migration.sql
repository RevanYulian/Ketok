-- Jalankan kode ini di Supabase SQL Editor

-- 1. Pastikan Row Level Security aktif
alter table tips_artikel enable row level security;

-- 2. Buat policy agar semua pengguna (publik maupun yang sudah login) dapat membaca tips & artikel
create policy "Izinkan semua orang membaca tips artikel"
on tips_artikel
for select
using (true);
