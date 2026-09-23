ALTER TABLE public.invoice
ADD COLUMN IF NOT EXISTS metode_bayar VARCHAR(50) DEFAULT 'tunai';

NOTIFY pgrst, 'reload schema';
