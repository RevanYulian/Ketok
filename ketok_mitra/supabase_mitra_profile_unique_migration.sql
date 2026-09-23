-- Jalankan di Supabase SQL Editor untuk memastikan satu profil per mitra.
-- Query aplikasi memakai maybeSingle(), sehingga user_id harus unik.

-- Pertahankan profil paling lama untuk setiap mitra dan hapus duplikatnya.
delete from mitra_profil duplicate_profile
using mitra_profil kept_profile
where duplicate_profile.user_id = kept_profile.user_id
  and duplicate_profile.id_profil > kept_profile.id_profil;

create unique index if not exists uq_mitra_profil_user_id
  on mitra_profil (user_id);

notify pgrst, 'reload schema';