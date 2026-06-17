# Yük Talebi – Kurulum Kılavuzu

İki konu var: **(A) Masaüstü uygulaması** (hemen, ücretsiz) ve **(B) Online hesap sistemi** (Supabase ile, tek oturum koruması).

---

## A) MASAÜSTÜ UYGULAMASI (kurulabilir – PWA)

Program artık bilgisayara/telefona **uygulama gibi kurulabiliyor** (kendi penceresi, simgesi, çevrimdışı çalışır). Ekstra program gerekmez.

### Nasıl kurulur (Chrome / Edge – bilgisayar)
1. Siteyi tarayıcıda aç.
2. Giriş yap. Üstte **"⬇️ Uygulamayı Kur"** butonu çıkar → tıkla → **Kur**.
   - Buton çıkmazsa: adres çubuğunun sağındaki **kur/yükle** simgesine tıkla, ya da menü → "Uygulamayı yükle".
3. Artık başlat menüsünde/masaüstünde **Yük Talebi** simgesi olur, kendi penceresinde açılır.

### Telefon (Android Chrome / iPhone Safari)
- Android: menü → "Uygulamayı yükle / Ana ekrana ekle".
- iPhone: Paylaş → "Ana Ekrana Ekle".

> Not: Kurulabilmesi için sitenin **https** ile yayında olması gerekir (Vercel/Netlify ücretsiz verir). `file://` ile açılınca kurulum çıkmaz ama yine çalışır.

### İstersen gerçek .exe (sonraki adım, opsiyonel)
PWA çoğu iş için yeterli. "Tam .exe" istersen **Electron** ile paketleriz; o ayrı bir kurulum adımıdır, hazır olduğunda birlikte yaparız.

---

## B) ONLINE HESAP SİSTEMİ (Supabase – ücretsiz)

Şu an program **yerel (cihaz) modunda** çalışır: giriş bilgileri o cihazda durur. Gerçek hesaplar + **aynı anda iki cihazdan girememe (tek oturum)** için aşağıyı uygula. **İlk satışlar için şart değil**, hazır olunca yaparız.

### Adım adım
1. **Hesap aç:** https://supabase.com → ücretsiz kayıt → **New project**.
   - Bölge: **Frankfurt (eu-central)** seç. Veritabanı şifresini bir yere not et.
2. **Tabloyu kur:** Sol menü **SQL Editor** → `supabase-setup.sql` dosyasının içeriğini yapıştır → **Run**.
3. **E-posta girişini aç:** **Authentication → Providers → Email** açık olsun. Kolaylık için **"Confirm email" kapalı** olsun.
4. **Kullanıcı ekle:** **Authentication → Users → Add user**
   - email: `musteriadi@yuktalebi.app`  (kullanıcı adının sonuna `@yuktalebi.app`)
   - password: müşterinin şifresi
   - Eklenen kullanıcının **User UID**'sini kopyala.
5. **Profili ekle:** **Table Editor → profiles → Insert row** (veya SQL'deki örnek INSERT) ile:
   `id` = kopyaladığın UID, `username`, `role`, `active`, `profile` (firma/telefon/adres/QR/tema).
6. **Anahtarları al:** **Project Settings → API** → **Project URL** ve **anon public** anahtarını kopyala.
7. **index.html'i ayarla:**
   - `<head>` içindeki şu satırın yorumunu kaldır:
     `<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>`
   - Script içinde **CLOUD** ayarını doldur:
     ```js
     const CLOUD = { url: 'https://xxxx.supabase.co', anonKey: 'eyJhbGci...' };
     ```
8. **Yayınla:** Dosyaları Vercel/Netlify'a yükle, kendi domainini bağla.
9. **Test:** Aynı hesapla iki cihazdan gir → ikinci giriş yapınca **birinci cihaz "Başka bir cihazdan giriş yapıldı" deyip otomatik çıkar**. ✅

> Online moda geçince giriş artık Supabase üzerinden olur; yerel `admin/admin` devre dışı kalır.
> Müşteri ekleme şimdilik Supabase panelinden yapılır; istersen sonra **uygulama içi** "müşteri ekle" özelliğini de online tarafa taşırız.

---

## KVKK (önemli)
Program isim, TC kimlik, telefon gibi **kişisel veri** tutar. Satış yapacaksan:
- Aydınlatma metni + açık rıza,
- Veriyi güvende tutma sorumluluğu,
- Düzenli satış için en az **şahıs şirketi** + kullanım sözleşmesi gerekir.
