-- ============================================================
--  YÜK TALEBİ – Supabase kurulum SQL'i
--  Supabase paneli → SQL Editor → bu içeriği yapıştır → "Run"
-- ============================================================

-- 1) Kullanıcı profilleri tablosu (giriş bilgisi auth.users'ta, geri kalan burada)
create table if not exists public.profiles (
  id             uuid primary key references auth.users(id) on delete cascade,
  username       text unique,
  role           text default 'user',          -- 'user' | 'admin'
  active         boolean default true,          -- pasif kullanıcı giriş yapamaz
  expiry         date,                          -- abonelik bitiş tarihi (boş = süresiz)
  current_session text,                         -- TEK OTURUM kontrolü için
  profile        jsonb default '{}'::jsonb,     -- üst bilgi/QR/logo/tema (uygulamadaki "profile")
  created_at     timestamptz default now()
);

-- 2) Güvenlik (RLS): herkes yalnız KENDİ satırını görür/günceller
alter table public.profiles enable row level security;

drop policy if exists "self read" on public.profiles;
create policy "self read"   on public.profiles for select using (auth.uid() = id);

drop policy if exists "self update" on public.profiles;
create policy "self update" on public.profiles for update using (auth.uid() = id);

-- 3) TEK OTURUM için realtime (başka cihazdan giriş olunca anında haber)
alter publication supabase_realtime add table public.profiles;

-- ============================================================
--  KULLANICI EKLEME (her müşteri için):
--  a) Authentication → Users → "Add user"
--     email  : musteriadi@yuktalebi.app   (kullanıcı adının sonuna @yuktalebi.app)
--     password: müşterinin şifresi
--  b) Aşağıdaki INSERT ile profilini ekle (USER_ID = o kullanıcının auth id'si):
--
--  insert into public.profiles (id, username, role, active, profile) values (
--    'BURAYA_AUTH_USER_ID',
--    'musteriadi',
--    'user',
--    true,
--    '{"company":"Yıldız Nakliyat","phone":"0532 111 22 33","addr":"Merkez Mah.\nİstanbul","email":"info@yildiz.com","qr":"https://yildiz.com","theme":"#1a8c4e","logo":""}'::jsonb
--  );
-- ============================================================
