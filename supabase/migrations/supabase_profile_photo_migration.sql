-- Jalankan sekali di Supabase SQL Editor.
alter table users add column if not exists foto_profil text;

insert into storage.buckets (id, name, public)
values ('profile-photos', 'profile-photos', true)
on conflict (id) do update set public = true;

create policy "Mitra dapat mengunggah foto profil"
on storage.objects for insert
to authenticated
with check (bucket_id = 'profile-photos' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Mitra dapat mengganti foto profil"
on storage.objects for update
to authenticated
using (bucket_id = 'profile-photos' and (storage.foldername(name))[1] = auth.uid()::text)
with check (bucket_id = 'profile-photos' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Foto profil dapat dilihat"
on storage.objects for select
to public
using (bucket_id = 'profile-photos');

notify pgrst, 'reload schema';