<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Yükleme Fişi Oluşturucu</title>
<script src="https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"></script>
<style>
  @import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap');
  :root {
    /* Dark UI tokens */
    --ui-bg:       #0f1117;
    --ui-surface:  #181c24;
    --ui-panel:    #1e2330;
    --ui-border:   #2a3045;
    --ui-border2:  #353d55;
    --ui-text:     #e2e6f0;
    --ui-text2:    #8892a8;
    --ui-accent:   #4f8ef7;
    --ui-accent2:  #1a4fa3;
    --ui-danger:   #e05555;
    --ui-success:  #3ecf8e;
    --ui-glow:     rgba(79,142,247,0.18);
    /* Form tokens (editor inputs) */
    --ink:#1a1a1a; --ink2:#444; --border:#bbb; --border-light:#ddd;
    --surface:#f7f6f3; --surface2:#eeede9; --white:#fff;
    --accent:#1a4fa3; --accent-light:#e8eef8; --danger:#b92b2b; --success:#1a7a3a;
    --radius:6px;
  }
  html { height:100%; }
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:'IBM Plex Sans', sans-serif; background:var(--ui-bg); color:var(--ui-text); height:100vh; overflow:hidden; }



  /* ── HEADER ── */
  .app-header {
    background:var(--ui-surface);
    border-bottom:1px solid var(--ui-border);
    color:var(--ui-text);
    padding:0 24px;
    display:flex; align-items:center; justify-content:space-between; gap:16px; height:56px;
    box-shadow:0 1px 0 var(--ui-border);
  }
  .app-header-left { display:flex; align-items:center; gap:14px; }
  .app-header-logo {
    width:32px; height:32px; border-radius:8px;
    background:linear-gradient(135deg,var(--ui-accent),#2563eb);
    display:flex; align-items:center; justify-content:center;
    font-size:16px; box-shadow:0 0 12px var(--ui-glow);
  }
  .app-header h1 { font-size:15px; font-weight:600; letter-spacing:.02em; color:var(--ui-text); }
  .app-header-badge {
    font-size:11px; font-weight:500; color:var(--ui-accent);
    background:rgba(79,142,247,.12); border:1px solid rgba(79,142,247,.25);
    padding:2px 8px; border-radius:20px; font-family:'IBM Plex Mono',monospace;
  }

  /* ── LAYOUT ── */
  .app-body { display:grid; grid-template-columns:520px 1fr; height:calc(100vh - 56px); overflow:hidden; }

  /* ── EDITOR (sol panel) ── */
  .editor {
    background:var(--ui-panel);
    border-right:1px solid var(--ui-border);
    overflow-y:auto; padding:20px; height:100%; min-height:0;
    scrollbar-width:thin; scrollbar-color:var(--ui-border2) transparent;
    position:relative;
  }
  /* Silik logo editor'un altında */
  .editor::after {
    content:'';
    position:sticky;
    bottom:0; left:0;
    display:block;
    width:100%; height:80px;
    background:url('https://reva.com.tr/wp-content/uploads/2022/06/reva-logo-2.png') center/160px auto no-repeat;
    opacity:0.06;
    pointer-events:none;
    filter:invert(1);
    margin-top:12px;
  }
  .editor::-webkit-scrollbar { width:5px; }
  .editor::-webkit-scrollbar-thumb { background:var(--ui-border2); border-radius:3px; }
  /* Editor section title */
  .section-title {
    font-size:10px; font-weight:700; letter-spacing:.1em; text-transform:uppercase;
    color:var(--ui-accent); margin:0 0 10px; padding-bottom:6px;
    border-bottom:1px solid var(--ui-border);
  }
  /* Editor inputs — dark */
  label { display:block; font-size:11px; font-weight:500; color:var(--ui-text2); margin-bottom:3px; }
  input[type=text], input[type=date], textarea, select {
    width:100%; font-family:inherit; font-size:13px; padding:8px 10px;
    border:1px solid var(--ui-border2); border-radius:var(--radius);
    background:var(--ui-surface); color:var(--ui-text); outline:none;
    transition:border-color .15s, box-shadow .15s;
  }
  input:focus, textarea:focus, select:focus {
    border-color:var(--ui-accent);
    box-shadow:0 0 0 3px rgba(79,142,247,.15);
  }
  .divider { border:none; border-top:1px solid var(--ui-border); margin:16px 0; }
  /* Customer card */
  .customer-card {
    background:var(--ui-surface); border:1px solid var(--ui-border);
    border-radius:10px; padding:14px; margin-bottom:12px;
    box-shadow:0 2px 8px rgba(0,0,0,.25);
  }
  .customer-card-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:10px; }
  .customer-card-header span {
    font-size:11px; font-weight:600; color:var(--ui-accent);
    background:rgba(79,142,247,.12); border:1px solid rgba(79,142,247,.2);
    padding:3px 9px; border-radius:20px;
  }
  .btn-remove {
    font-size:11px; background:none; border:1px solid rgba(224,85,85,.4);
    color:var(--ui-danger); padding:3px 8px; border-radius:4px; cursor:pointer; font-family:inherit;
    transition:all .15s;
  }
  .btn-remove:hover { background:rgba(224,85,85,.12); border-color:var(--ui-danger); }
  .products-label { font-size:10px; font-weight:700; color:var(--ui-text2); text-transform:uppercase; letter-spacing:.07em; margin:10px 0 6px; }
  .product-row { display:grid; grid-template-columns:1fr 55px 90px 24px; gap:5px; margin-bottom:5px; align-items:center; }
  .product-row input { font-size:12px; padding:5px 8px; }
  .btn-del-row {
    width:24px; height:28px; background:none; border:1px solid var(--ui-border2);
    border-radius:4px; color:var(--ui-text2); cursor:pointer; font-size:14px;
    display:flex; align-items:center; justify-content:center; transition:all .12s;
  }
  .btn-del-row:hover { background:rgba(224,85,85,.12); border-color:var(--ui-danger); color:var(--ui-danger); }
  .btn-add-row {
    font-size:12px; background:none; border:1px dashed var(--ui-border2); color:var(--ui-text2);
    padding:5px 10px; border-radius:4px; cursor:pointer; width:100%; margin-top:3px; font-family:inherit;
    transition:all .15s;
  }
  .btn-add-row:hover { background:rgba(79,142,247,.08); border-color:var(--ui-accent); color:var(--ui-accent); }
  .btn-add-customer {
    width:100%; padding:10px; border:none; border-radius:var(--radius);
    font-family:inherit; font-size:13px; font-weight:600; cursor:pointer; margin-top:4px;
    background:linear-gradient(135deg,var(--ui-accent),#2563eb);
    color:#fff; box-shadow:0 2px 12px rgba(79,142,247,.3);
    transition:all .15s;
  }
  .btn-add-customer:hover { opacity:.9; box-shadow:0 4px 18px rgba(79,142,247,.45); }

  /* ── PREVIEW (sağ panel) ── */
  .preview {
    background:var(--ui-bg);
    background-image:
      radial-gradient(ellipse at 20% 0%, rgba(79,142,247,.06) 0%, transparent 60%),
      radial-gradient(ellipse at 80% 100%, rgba(37,99,235,.05) 0%, transparent 60%);
    padding:28px; overflow-y:auto; display:flex; flex-direction:column; align-items:center; gap:0;
    height:100%; min-height:0;
    scrollbar-width:thin; scrollbar-color:var(--ui-border2) transparent;
    position:relative;
  }
  .preview::before {
    content:'';
    position:fixed;
    bottom:40px; right:40px;
    width:220px; height:90px;
    background:url('https://reva.com.tr/wp-content/uploads/2022/06/reva-logo-2.png') center/contain no-repeat;
    opacity:0.045;
    pointer-events:none;
    z-index:0;
    filter:invert(1);
  }
  .preview::-webkit-scrollbar { width:5px; }
  .preview::-webkit-scrollbar-thumb { background:var(--ui-border2); border-radius:3px; }
  .preview-controls { width:100%; max-width:640px; display:flex; gap:8px; margin-bottom:16px; align-items:center; justify-content:space-between; }
  .preview-controls-right { display:flex; gap:8px; align-items:center; }
  .btn-print {
    background:linear-gradient(135deg,var(--ui-accent),#2563eb);
    color:#fff; border:none; padding:9px 20px; border-radius:var(--radius);
    font-family:inherit; font-size:13px; font-weight:600; cursor:pointer;
    display:flex; align-items:center; gap:7px;
    box-shadow:0 2px 12px rgba(79,142,247,.3); transition:all .15s;
  }
  .btn-print:hover { opacity:.9; box-shadow:0 4px 18px rgba(79,142,247,.45); }
  .btn-print svg { width:15px; height:15px; }
  /* Fiche kağıt gölge dark bg'de güzel durur */
  .fiche-page {
    background:var(--white); width:620px;
    box-shadow:0 4px 32px rgba(0,0,0,.6), 0 1px 4px rgba(0,0,0,.4);
    font-family:Arial, sans-serif; font-size:11px; color:#000;
    padding:16px 14px 14px; border-radius:2px;
    display:flex; flex-direction:column;
  }

  /* ── OCR BUTTON ── */
  .btn-ocr {
    width:100%; padding:10px 14px; margin-bottom:14px;
    background:transparent; color:var(--ui-accent);
    border:1px dashed rgba(79,142,247,.5); border-radius:var(--radius);
    font-family:inherit; font-size:13px; font-weight:600; cursor:pointer;
    display:flex; align-items:center; justify-content:center; gap:8px;
    transition:all .15s;
  }
  .btn-ocr:hover { background:rgba(79,142,247,.08); border-color:var(--ui-accent); }

  /* ── PAGE NAVIGATOR ── */
  .page-nav {
    display:none; /* render() gösterir/gizler */
    align-items:center; gap:6px;
    background:var(--ui-surface); border:1px solid var(--ui-border);
    border-radius:8px; padding:4px 6px;
  }
  .page-nav.visible { display:flex; }
  .page-nav-label { font-size:11px; color:var(--ui-text2); margin-right:4px; font-family:'IBM Plex Mono',monospace; }
  .page-btn {
    font-size:11px; font-weight:600; padding:4px 10px;
    border:1px solid var(--ui-border2); border-radius:5px;
    background:var(--ui-panel); color:var(--ui-text2);
    cursor:pointer; font-family:inherit; transition:all .12s;
  }
  .page-btn.active {
    background:var(--ui-accent); color:#fff;
    border-color:var(--ui-accent); box-shadow:0 0 8px rgba(79,142,247,.4);
  }
  .page-btn:hover:not(.active) { background:var(--ui-border); color:var(--ui-text); }
  /* section-title: dark tema root'ta tanımlı */
  .field-row { display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-bottom:8px; }
  .field-full { margin-bottom:8px; }
  .fiche-page { background:var(--white); width:620px; box-shadow:0 2px 16px rgba(0,0,0,0.13); font-family:Arial, sans-serif; font-size:11px; color:#000; padding:16px 14px 14px; border:1px solid #ccc; display:flex; flex-direction:column; }
  .fiche-table { flex:1; }
  .fiche-table { width:100%; border-collapse:collapse; border:2px solid #000; table-layout:fixed; flex:1; }
  .fiche-table td, .fiche-table th { border:1px solid #000; padding:4px 6px; font-size:11px; height:18px; vertical-align:middle; word-wrap:break-word; }
  /* Müşteri satırı: sadece etiket bold, değer normal */
  .row-musteri td { font-weight:400; background:#e8e8e8 !important; -webkit-print-color-adjust:exact !important; print-color-adjust:exact !important; }
  .row-musteri .lbl { font-weight:700; }
  .row-address td { font-weight:700; font-size:10.5px; background:#e8e8e8 !important; -webkit-print-color-adjust:exact !important; print-color-adjust:exact !important; }
  .row-address td:nth-child(2), .row-address td:nth-child(3) { text-align:center; }
  .row-colhdr td { text-align:center; font-weight:900; background:#d0d0d0 !important; -webkit-print-color-adjust:exact !important; print-color-adjust:exact !important; }
  .row-product td:nth-child(2), .row-product td:nth-child(3) { text-align:center; }
  .row-product.is-resantre td { font-weight:400; }
  .row-empty td { color:transparent; }
  .fiche-header-gray { background:#d8d8d8 !important; -webkit-print-color-adjust:exact !important; print-color-adjust:exact !important; }
  .fiche-footer { display:grid; grid-template-columns:55% 20% 25%; border:2px solid #000; border-top:none; }
  .fiche-footer div { padding:0; font-size:11px; font-weight:700; text-align:center; border-right:1px solid #000; min-height:70px; display:flex; flex-direction:column; align-items:center; }
  .fiche-footer .flbl { padding:5px 6px 0; font-weight:700; text-decoration:underline; }
  .fiche-footer .fval { font-weight:400; margin:auto 6px; }
  .fiche-footer div:last-child { border-right:none; }
  .fiche-footer .fval { font-weight:400; }
  #print-sheet { display:none; }
  @page { size:A4 landscape; margin:6mm; }
  @media print {
    html, body { background:white !important; min-height:0 !important; height:auto !important; margin:0 !important; padding:0 !important; overflow:visible !important; }
    .app-header, .app-body, .preview-controls, .ocr-modal-backdrop { display:none !important; }
    #print-sheet { display:block !important; width:100%; margin:0; padding:0; }
    .print-page { width:100%; height:100vh; display:grid; grid-template-columns:1fr 1fr; gap:6mm; page-break-after:always; break-after:page; margin:0; padding:0; box-sizing:border-box; }
    .print-page:last-child { page-break-after:avoid; break-after:avoid; }
    .print-page .fiche-page { width:100% !important; height:100% !important; box-shadow:none !important; border:none !important; padding:0 !important; margin:0 !important; display:flex !important; flex-direction:column !important; }
    .print-page .fiche-page .fiche-table { flex:1 !important; }
  }
  /* OCR */
  .btn-ocr { width:100%; padding:10px 12px; margin-bottom:14px; background:#fff; color:var(--accent); border:1px dashed var(--accent); border-radius:var(--radius); font-family:inherit; font-size:13px; font-weight:600; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:8px; }
  .btn-ocr:hover { background:var(--accent-light); }
  .ocr-modal-backdrop { display:none; position:fixed; inset:0; background:rgba(0,0,0,0.55); z-index:1000; align-items:center; justify-content:center; padding:24px; }
  .ocr-modal-backdrop.open { display:flex; }
  .ocr-modal { background:#fff; border-radius:10px; width:min(1100px, 100%); max-height:94vh; display:flex; flex-direction:column; overflow:hidden; box-shadow:0 10px 40px rgba(0,0,0,0.3); }
  .ocr-modal-header { background:var(--ink); color:#fff; padding:14px 20px; display:flex; align-items:center; justify-content:space-between; }
  .ocr-modal-header h2 { font-size:15px; font-weight:600; }
  .ocr-modal-header button { background:none; border:none; color:#fff; font-size:22px; cursor:pointer; line-height:1; }
  .ocr-modal-body { padding:14px 18px; overflow-y:auto; display:flex; flex-direction:column; gap:12px; }
  .ocr-drop { border:2px dashed var(--border); border-radius:8px; padding:18px; text-align:center; color:var(--ink2); font-size:13px; cursor:pointer; background:var(--surface); }
  .ocr-drop.drag { border-color:var(--accent); background:var(--accent-light); }
  .ocr-region-toolbar { display:flex; flex-wrap:wrap; align-items:center; gap:6px; padding:8px; background:var(--surface); border-radius:6px; }
  .ocr-rbtn { padding:6px 10px; border:1px solid var(--border); background:#fff; border-radius:5px; cursor:pointer; font-family:inherit; font-size:12px; font-weight:600; display:flex; align-items:center; gap:5px; }
  .ocr-rbtn .dot { width:10px; height:10px; border-radius:2px; display:inline-block; }
  .ocr-rbtn.set { background:var(--surface2); }
  .ocr-rbtn.active { border-color:var(--accent); box-shadow:0 0 0 2px rgba(26,79,163,0.2); }
  .ocr-rbtn-meta { padding:6px 10px; border:1px solid var(--border); background:#fff; border-radius:5px; cursor:pointer; font-family:inherit; font-size:12px; }
  .ocr-rbtn-meta:hover { background:var(--surface); }
  .ocr-instructions { font-size:12px; color:var(--ink2); padding:6px 10px; background:#fffbe6; border:1px solid #fde68a; border-radius:5px; }
  .ocr-image-wrap { position:relative; display:inline-block; max-width:100%; line-height:0; }
  .ocr-image-wrap img { max-width:100%; height:auto; display:block; user-select:none; -webkit-user-drag:none; }
  .ocr-image-wrap canvas { position:absolute; top:0; left:0; cursor:default; }
  .ocr-image-wrap.selecting canvas { cursor:crosshair; }
  .ocr-progress { height:6px; background:var(--border-light); border-radius:3px; overflow:hidden; }
  .ocr-progress > div { height:100%; width:0%; background:var(--accent); transition:width .2s; }
  .ocr-status { font-size:12px; color:var(--ink2); }
  .ocr-review-grid { display:grid; grid-template-columns:1fr 1fr; gap:8px; }
  .ocr-review-grid .full { grid-column:1 / -1; }
  .ocr-prod-row { display:grid; grid-template-columns:1fr 70px 24px; gap:5px; margin-bottom:5px; }
  .ocr-modal-footer { padding:12px 18px; border-top:1px solid var(--border-light); display:flex; gap:8px; justify-content:flex-end; background:var(--surface); flex-wrap:wrap; }
  .ocr-modal-footer button { padding:8px 14px; border-radius:var(--radius); font-family:inherit; font-size:13px; cursor:pointer; border:1px solid var(--border); background:#fff; color:var(--ink); }
  .ocr-modal-footer button.primary { background:var(--accent); color:#fff; border-color:var(--accent); }
  .ocr-modal-footer button:disabled { opacity:0.5; cursor:not-allowed; }
</style>
</head>

<body>
<header class="app-header">
  <div class="app-header-left">
    <img src="https://reva.com.tr/wp-content/uploads/2022/06/reva-logo-2.png" alt="Reva" style="height:32px;width:auto;object-fit:contain;filter:brightness(0) invert(1);">
    <h1>Yükleme Fişi Oluşturucu</h1>
  </div>
  <span class="app-header-badge">FRM 29/00</span>
</header>
<div class="app-body">
  <aside class="editor" id="editor">
    <button class="btn-ocr" type="button" onclick="openOcrModal()">📷 Görüntüden Veri Aktar</button>
    <p class="section-title">Genel Bilgiler</p>
    <div class="field-row">
      <div><label>Tarih</label><input type="date" id="g-tarih" oninput="render()"></div>
      <div><label>Plaka</label><input type="text" id="g-plaka" placeholder="34 ABC 123" oninput="render()"></div>
    </div>
    <div class="field-full"><label>Bölge</label><input type="text" id="g-bolge" placeholder="Bölge giriniz" oninput="render()"></div>
    <hr class="divider">
    <p class="section-title">Müşteri &amp; Ürünler</p>
    <div id="customers-container"></div>
    <button class="btn-add-customer" onclick="addCustomer()">+ Yeni Müşteri Ekle</button>
    <hr class="divider">
    <div class="field-full"><label>Not</label><textarea id="g-not" rows="2" placeholder="Fiş notu..." oninput="render()"></textarea></div>
    <div class="field-full"><label>Toplam KG</label><input type="text" id="g-kg" placeholder="0" oninput="render()"></div>
  </aside>
  <main class="preview" id="preview-area">
    <div class="preview-controls">
      <div class="page-nav" id="page-nav">
        <span class="page-nav-label">Sayfa</span>
        <div id="page-btns"></div>
      </div>
      <div class="preview-controls-right">
        <button class="btn-print" onclick="printFiche()">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
          Yazdır / PDF
        </button>
      </div>
    </div>
    <div class="fiche-page" id="fiche-output"></div>
  </main>
</div>
<div id="print-sheet" aria-hidden="true"></div>

<!-- OCR modal -->
<div class="ocr-modal-backdrop" id="ocr-modal" onclick="if(event.target===this)closeOcrModal()">
  <div class="ocr-modal">
    <div class="ocr-modal-header">
      <h2>Görüntüden Veri Aktar — Bölge Seçimli OCR</h2>
      <button type="button" onclick="closeOcrModal()" aria-label="Kapat">×</button>
    </div>
    <div class="ocr-modal-body">
      <div class="ocr-drop" id="ocr-drop" tabindex="0">
        <strong>Adım 1.</strong> Görseli buraya sürükleyin, tıklayıp seçin veya panodan yapıştırın (Ctrl+V).
        <input type="file" id="ocr-file" accept="image/*" hidden>
      </div>

      <div id="ocr-stage" hidden>
        <div class="ocr-region-toolbar">
          <span style="font-size:12px;font-weight:600;color:#333">Adım 2. Alan seç → resim üzerinde dikdörtgen çiz:</span>
          <button type="button" class="ocr-rbtn" data-region="adres"><span class="dot" style="background:#ffd54f"></span>Adres</button>
          <button type="button" class="ocr-rbtn" data-region="il"><span class="dot" style="background:#81c784"></span>İl</button>
          <button type="button" class="ocr-rbtn" data-region="ilce"><span class="dot" style="background:#64b5f6"></span>İlçe</button>
          <button type="button" class="ocr-rbtn" data-region="urun"><span class="dot" style="background:#ce93d8"></span>Ürün adları</button>
          <button type="button" class="ocr-rbtn" data-region="miktar"><span class="dot" style="background:#ffb74d"></span>Miktarlar</button>
          <span style="flex:1"></span>
          <button type="button" class="ocr-rbtn-meta" onclick="clearAllRegions()">🗑️ Temizle</button>
          <button type="button" class="ocr-rbtn-meta" onclick="saveTemplate()">💾 Şablonu Kaydet</button>
          <button type="button" class="ocr-rbtn-meta" onclick="loadTemplate()">📂 Yükle</button>
        </div>
        <div class="ocr-instructions" id="ocr-instructions">Bir alan seçin, sonra resim üzerinde fareyi sürükleyerek dikdörtgen çizin. İşaretli bölge yeniden çizilebilir.</div>
        <div class="ocr-image-wrap" id="ocr-image-wrap">
          <img id="ocr-img-disp" alt="">
          <canvas id="ocr-canvas"></canvas>
        </div>
      </div>

      <div class="ocr-progress" hidden id="ocr-progress-bar"><div></div></div>
      <div class="ocr-status" id="ocr-status"></div>

      <div id="ocr-review" hidden>
        <p class="section-title" style="margin-top:6px">Adım 4. Bulunan veriler — kontrol edin / düzenleyin:</p>
        <div class="ocr-review-grid">
          <div class="full"><label>Adres</label><input type="text" id="ocr-adres"></div>
          <div><label>İlçe</label><input type="text" id="ocr-ilce"></div>
          <div><label>İl</label><input type="text" id="ocr-il"></div>
        </div>
        <div style="margin-top:12px">
          <label style="font-weight:600">Ürünler</label>
          <div id="ocr-products"></div>
          <button type="button" class="btn-add-row" onclick="ocrAddProduct()">+ Ürün satırı ekle</button>
        </div>
      </div>
    </div>
    <div class="ocr-modal-footer">
      <button type="button" onclick="closeOcrModal()">İptal</button>
      <button type="button" id="ocr-run" class="primary" onclick="runOcr()" disabled>Adım 3. OCR'yi Başlat</button>
      <button type="button" id="ocr-apply-new" class="primary" onclick="applyOcr('new')" hidden>Yeni Müşteri Olarak Ekle</button>
      <button type="button" id="ocr-apply-merge" onclick="applyOcr('merge')" hidden>Aktif Müşteriye Ekle</button>
    </div>
  </div>
</div>

<script>
/* ─────────── Fiş çekirdeği ─────────── */
let customers = [];
let nextCId = 1;
function formatDate(val) { if (!val) return ''; const [y,m,d] = val.split('-'); return `${d}.${m}.${y}`; }
function addCustomer(data) {
  const id = nextCId++;
  const c = data || { id, musteri:'', adres:'', ilce:'', il:'', products:[{urun:'', miktar:'', ambalaj:''}] };
  c.id = id;
  c.products = (c.products || []).map(p => ({ urun:p.urun||'', miktar:p.miktar||'', ambalaj:p.ambalaj||'' }));
  customers.push(c); renderEditor(); render();
}
function removeCustomer(id) { customers = customers.filter(c => c.id !== id); renderEditor(); render(); }
function addProductRow(cid) { const c = customers.find(x => x.id === cid); if (c) c.products.push({urun:'', miktar:'', ambalaj:''}); renderEditor(); render(); }
function removeProductRow(cid, idx) { const c = customers.find(x => x.id === cid); if (c && c.products.length > 1) { c.products.splice(idx, 1); renderEditor(); render(); } }
function getVal(id) { const el = document.getElementById(id); return el ? el.value : ''; }
function syncCustomer(id) {
  const c = customers.find(x => x.id === id); if (!c) return;
  c.musteri = getVal(`c-${id}-musteri`);
  c.adres   = getVal(`c-${id}-adres`);
  c.ilce    = getVal(`c-${id}-ilce`);
  c.il      = getVal(`c-${id}-il`);
  c.products.forEach((p, i) => {
    p.urun    = getVal(`c-${id}-p-${i}-urun`);
    p.miktar  = getVal(`c-${id}-p-${i}-miktar`);
    p.ambalaj = getVal(`c-${id}-p-${i}-ambalaj`);
  });
  render();
}
function renderEditor() {
  document.getElementById('customers-container').innerHTML = customers.map((c, ci) => `
    <div class="customer-card">
      <div class="customer-card-header"><span>Müşteri ${ci+1}</span><button class="btn-remove" onclick="removeCustomer(${c.id})">× Sil</button></div>
      <div class="field-full"><label>Müşteri Adı</label><input type="text" id="c-${c.id}-musteri" value="${esc(c.musteri)}" oninput="syncCustomer(${c.id})"></div>
      <div class="field-full"><label>Adres</label><input type="text" id="c-${c.id}-adres" value="${esc(c.adres)}" oninput="syncCustomer(${c.id})"></div>
      <div class="field-row">
        <div><label>İlçe</label><input type="text" id="c-${c.id}-ilce" value="${esc(c.ilce)}" oninput="syncCustomer(${c.id})"></div>
        <div><label>İl</label><input type="text" id="c-${c.id}-il" value="${esc(c.il)}" oninput="syncCustomer(${c.id})"></div>
      </div>
      <div class="products-label">Ürünler</div>
      ${c.products.map((p, i) => `
        <div class="product-row">
          <input type="text" id="c-${c.id}-p-${i}-urun" value="${esc(p.urun)}" placeholder="Ürün" oninput="syncCustomer(${c.id})">
          <input type="text" id="c-${c.id}-p-${i}-miktar" value="${esc(p.miktar)}" placeholder="Adet" oninput="syncCustomer(${c.id})">
          <input type="text" id="c-${c.id}-p-${i}-ambalaj" value="${esc(p.ambalaj)}" placeholder="Ambalaj" oninput="syncCustomer(${c.id})">
          <button class="btn-del-row" onclick="removeProductRow(${c.id},${i})">×</button>
        </div>`).join('')}
      <button class="btn-add-row" onclick="addProductRow(${c.id})">+ Ürün ekle</button>
    </div>`).join('');
}
function esc(s) { return (s||'').replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function escHtml(s) { return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function isResantre(s) { return /resantre/i.test(s||''); }
function printFiche() {
  render(); /* print-sheet'i güncelle */
  const oldTitle = document.title;
  document.title = 'Yükleme Fişi';
  const restore = () => { document.title = oldTitle; window.removeEventListener('afterprint', restore); };
  window.addEventListener('afterprint', restore);
  window.print();
}
function buildHeader(tarih, plaka, bolge) {
  return `<table style="width:100%;border-collapse:collapse;border:2px solid #000;border-bottom:none;-webkit-print-color-adjust:exact;print-color-adjust:exact">
    <colgroup><col style="width:55%"><col style="width:45%"></colgroup>
    <tr>
      <td class="fiche-header-gray" style="border-right:2px solid #000;padding:8px;vertical-align:middle">
        <div style="font-size:16px;font-weight:900;text-align:center">YÜKLEME FİŞİ</div>
        <div style="font-size:14px;font-weight:900;text-align:center">(FRM 29/00)</div>
      </td>
      <td class="fiche-header-gray" style="padding:0;vertical-align:top">
        <table style="width:100%;border-collapse:collapse">
          <tr><td class="fiche-header-gray" style="font-weight:700;padding:4px 6px;border-bottom:1px solid #000;border-right:1px solid #000">TARİH:</td><td class="fiche-header-gray" style="padding:4px 6px;border-bottom:1px solid #000;text-align:center">${escHtml(tarih)}</td></tr>
          <tr><td class="fiche-header-gray" style="font-weight:700;padding:4px 6px;border-bottom:1px solid #000;border-right:1px solid #000">PLAKA:</td><td class="fiche-header-gray" style="padding:4px 6px;border-bottom:1px solid #000">${escHtml(plaka)}</td></tr>
          <tr><td class="fiche-header-gray" style="font-weight:700;padding:4px 6px;border-right:1px solid #000">BÖLGE:</td><td class="fiche-header-gray" style="padding:4px 6px">${escHtml(bolge)}</td></tr>
        </table>
      </td>
    </tr>
  </table>`;
}

function buildFiche(tarih, plaka, bolge, rows, not, kg) {
  const TOTAL = 22;
  const filled = [...rows];
  while (filled.length < TOTAL) filled.push({ html:`<tr class="row-empty"><td>&nbsp;</td><td></td><td></td></tr>` });
  return buildHeader(tarih, plaka, bolge) + `
    <table class="fiche-table">
      <colgroup><col style="width:55%"><col style="width:20%"><col style="width:25%"></colgroup>
      <tbody>${filled.map(r => r.html).join('')}</tbody>
    </table>
    <div class="fiche-footer">
      <div><span class="flbl">NOT</span>${not ? '<span class="fval">' + escHtml(not) + '</span>' : ''}</div>
      <div><span class="flbl">KG</span>${kg ? '<span class="fval">' + escHtml(kg) + '</span>' : ''}</div>
      <div><span class="flbl">YÜKLEYEN İMZA</span></div>
    </div>`;
}

function render() {
  const tarih = formatDate(getVal('g-tarih'));
  const plaka = getVal('g-plaka');
  const bolge = getVal('g-bolge');
  const not   = getVal('g-not');
  const kg    = getVal('g-kg');
  const ROWS_PER_PAGE = 22;

  let allRows = [];
  customers.forEach(c => {
    /* MÜŞTERİ ADI: etiket bold, değer normal, alt çizgi yok */
    allRows.push({ html:`<tr class="row-musteri"><td colspan="3"><span class="lbl">MÜŞTERİ ADI:</span>${c.musteri ? '&nbsp;' + escHtml(c.musteri) : ''}</td></tr>` });
    allRows.push({ html:`<tr class="row-address"><td><strong>ADRES:</strong>&nbsp;${escHtml(c.adres)}</td><td>${escHtml(c.ilce)}</td><td>${escHtml(c.il)}</td></tr>` });
    allRows.push({ html:`<tr class="row-colhdr"><td>MALIN CİNSİ</td><td>MİKTARI</td><td>AMBALAJ DURUMU</td></tr>` });
    c.products.forEach(p => {
      allRows.push({ html:`<tr class="row-product"><td>${escHtml(p.urun)}</td><td>${escHtml(p.miktar)}</td><td>${escHtml(p.ambalaj)}</td></tr>` });
    });
  });

  /* Satırları sayfalara böl */
  const pages = [];
  let page = [];
  allRows.forEach(row => {
    page.push(row);
    if (page.length >= ROWS_PER_PAGE) { pages.push([...page]); page = []; }
  });
  if (page.length > 0 || pages.length === 0) pages.push(page);

  /* Preview: aktif sayfayı göster + navigator */
  const nav = document.getElementById('page-nav');
  const btns = document.getElementById('page-btns');
  if (pages.length <= 1) {
    nav.classList.remove('visible');
    // currentPage sıfırla
    window._currentPage = 0;
  } else {
    nav.classList.add('visible');
    // currentPage sınırda kalmasını sağla
    if (!window._currentPage || window._currentPage >= pages.length) window._currentPage = 0;
    btns.innerHTML = pages.map((_, i) => `
      <button class="page-btn${i === window._currentPage ? ' active' : ''}"
              onclick="setPage(${i})">
        ${i + 1}
      </button>`).join('');
  }
  document.getElementById('fiche-output').innerHTML =
    buildFiche(tarih, plaka, bolge, pages[window._currentPage || 0], not, kg);

  /* Print: tüm sayfalar */
  document.getElementById('print-sheet').innerHTML = pages.map(rows => `
    <div class="print-page">
      <div class="fiche-page">${buildFiche(tarih, plaka, bolge, rows, not, kg)}</div>
      <div class="fiche-page">${buildFiche(tarih, plaka, bolge, rows, not, kg)}</div>
    </div>`).join('');
}

function setPage(i) {
  window._currentPage = i;
  render();
}

window.addEventListener('DOMContentLoaded', function() {
  document.getElementById('g-tarih').value = new Date().toISOString().split('T')[0];
});
addCustomer({ id:0, musteri:'', adres:'', ilce:'', il:'', products:[{urun:'', miktar:'', ambalaj:''}] });
</script>

<script>
/* ─────────── OCR (Bölge seçimli, tamamen yerel, API yok) ─────────── */
const REGION_KEYS = ['adres','il','ilce','urun','miktar'];
const REGION_LABELS = { adres:'Adres', il:'İl', ilce:'İlçe', urun:'Ürün adları', miktar:'Miktarlar' };
const REGION_COLORS = { adres:'#ffd54f', il:'#81c784', ilce:'#64b5f6', urun:'#ce93d8', miktar:'#ffb74d' };
const TEMPLATE_KEY = 'yfo_ocr_template_v1';

let ocrFile = null;
let ocrBitmap = null;
let ocrNatW = 0, ocrNatH = 0;
let ocrRegions = { adres:null, il:null, ilce:null, urun:null, miktar:null };
let activeRegion = null;
let drawing = false, drawStart = null, drawCurrent = null;
let _ocrResizeObs = null;

function openOcrModal() {
  document.getElementById('ocr-modal').classList.add('open');
  resetOcrModal();
  document.addEventListener('paste', ocrPasteHandler);
}
function closeOcrModal() {
  document.getElementById('ocr-modal').classList.remove('open');
  document.removeEventListener('paste', ocrPasteHandler);
  if (_ocrResizeObs) { _ocrResizeObs.disconnect(); _ocrResizeObs = null; }
}
function resetOcrModal() {
  ocrFile = null; ocrBitmap = null; ocrNatW = ocrNatH = 0;
  ocrRegions = { adres:null, il:null, ilce:null, urun:null, miktar:null };
  activeRegion = null;
  document.getElementById('ocr-stage').hidden = true;
  document.getElementById('ocr-progress-bar').hidden = true;
  document.querySelector('#ocr-progress-bar > div').style.width = '0%';
  document.getElementById('ocr-status').textContent = '';
  document.getElementById('ocr-review').hidden = true;
  document.getElementById('ocr-run').disabled = true;
  document.getElementById('ocr-apply-new').hidden = true;
  document.getElementById('ocr-apply-merge').hidden = true;
  document.getElementById('ocr-file').value = '';
  document.querySelectorAll('.ocr-rbtn').forEach(b => { b.classList.remove('active'); b.classList.remove('set'); });
  document.getElementById('ocr-image-wrap').classList.remove('selecting');
}

function ocrPasteHandler(e) {
  if (!document.getElementById('ocr-modal').classList.contains('open')) return;
  const items = (e.clipboardData || e.originalEvent.clipboardData).items;
  for (const it of items) {
    if (it.type.indexOf('image') === 0) { ocrSetFile(it.getAsFile()); e.preventDefault(); break; }
  }
}

async function ocrSetFile(file) {
  if (!file || !file.type.startsWith('image/')) return;
  ocrFile = file;
  try { ocrBitmap = await createImageBitmap(file); }
  catch(e) { ocrBitmap = null; }

  const url = URL.createObjectURL(file);
  const img = document.getElementById('ocr-img-disp');
  await new Promise((res, rej) => { img.onload = res; img.onerror = rej; img.src = url; });
  ocrNatW = img.naturalWidth; ocrNatH = img.naturalHeight;

  // ── KRİTİK: ÖNCE stage'i göster, SONRA canvas'ı ölç ──
  // Stage hidden iken clientWidth=0 → canvas 0×0 → çizilemez.
  document.getElementById('ocr-stage').hidden = false;
  // Layout için bir/iki frame bekle.
  await new Promise(r => requestAnimationFrame(r));
  if (!img.clientWidth) await new Promise(r => requestAnimationFrame(r));

  fitCanvasToImage();
  document.getElementById('ocr-run').disabled = false;
  document.getElementById('ocr-status').textContent = 'Görüntü yüklendi. Bir alan seçip resim üzerinde dikdörtgen çizin. Kayıtlı şablon varsa "Yükle" ile getirebilirsiniz.';

  // Otomatik şablon yükle (varsa)
  try {
    const s = localStorage.getItem(TEMPLATE_KEY);
    if (s) {
      const saved = JSON.parse(s);
      let count = 0;
      for (const k of REGION_KEYS) if (saved[k]) { ocrRegions[k] = saved[k]; count++; }
      if (count) {
        document.getElementById('ocr-status').textContent = `Görüntü yüklendi. ${count} bölge kayıtlı şablondan otomatik yüklendi — gerekirse düzenleyin, sonra OCR'yi başlatın.`;
        updateRegionButtons();
        redrawRegions();
      }
    }
  } catch(e) { /* yoksay */ }

  // Resim sonradan boyut değiştirirse (modal animasyonu, pencere yeniden boyutlandırma vb.) canvas'ı tekrar fit et.
  if (window.ResizeObserver) {
    if (_ocrResizeObs) _ocrResizeObs.disconnect();
    _ocrResizeObs = new ResizeObserver(() => fitCanvasToImage());
    _ocrResizeObs.observe(img);
  }
}

function fitCanvasToImage() {
  const img = document.getElementById('ocr-img-disp');
  const canvas = document.getElementById('ocr-canvas');
  const w = img.clientWidth, h = img.clientHeight;
  if (!w || !h) return;            // hâlâ layout yok → bir sonraki olayda dene
  canvas.width = w; canvas.height = h;
  canvas.style.width = w + 'px';
  canvas.style.height = h + 'px';
  redrawRegions();
}

(function wireUI() {
  // Drop zone
  const drop = document.getElementById('ocr-drop');
  const fileInp = document.getElementById('ocr-file');
  drop.addEventListener('click', () => fileInp.click());
  drop.addEventListener('keydown', e => { if (e.key === 'Enter') fileInp.click(); });
  fileInp.addEventListener('change', e => ocrSetFile(e.target.files[0]));
  ['dragenter','dragover'].forEach(ev => drop.addEventListener(ev, e => { e.preventDefault(); drop.classList.add('drag'); }));
  ['dragleave','drop'].forEach(ev => drop.addEventListener(ev, e => { e.preventDefault(); drop.classList.remove('drag'); }));
  drop.addEventListener('drop', e => { if (e.dataTransfer.files.length) ocrSetFile(e.dataTransfer.files[0]); });

  // Region buttons
  document.querySelectorAll('.ocr-rbtn').forEach(btn => {
    btn.addEventListener('click', () => {
      activeRegion = btn.dataset.region;
      document.querySelectorAll('.ocr-rbtn').forEach(b => b.classList.toggle('active', b === btn));
      document.getElementById('ocr-image-wrap').classList.add('selecting');
      document.getElementById('ocr-instructions').textContent =
        `🎯 ${REGION_LABELS[activeRegion]} alanını seçmek için resim üzerinde fareyi sürükleyin. Tekrar çizerseniz üzerine yazılır.`;
      // Canvas hâlâ 0×0 ise tekrar fit dene (savunma amaçlı).
      const c = document.getElementById('ocr-canvas');
      if (!c.width || !c.height) fitCanvasToImage();
    });
  });

  // Canvas drawing
  const canvas = document.getElementById('ocr-canvas');
  canvas.addEventListener('mousedown', startDraw);
  canvas.addEventListener('mousemove', moveDraw);
  canvas.addEventListener('mouseup', endDraw);
  canvas.addEventListener('mouseleave', () => { if (drawing) endDraw(null); });

  // Window resize → reflow canvas
  window.addEventListener('resize', () => {
    if (!document.getElementById('ocr-stage').hidden) fitCanvasToImage();
  });
})();

function getCanvasPos(e) {
  const canvas = document.getElementById('ocr-canvas');
  const rect = canvas.getBoundingClientRect();
  return { x: e.clientX - rect.left, y: e.clientY - rect.top };
}
function startDraw(e) {
  if (!activeRegion) return;
  drawing = true; drawStart = getCanvasPos(e); drawCurrent = drawStart;
}
function moveDraw(e) { if (!drawing) return; drawCurrent = getCanvasPos(e); redrawRegions(); }
function endDraw(e) {
  if (!drawing) return; drawing = false;
  if (e) drawCurrent = getCanvasPos(e);
  const canvas = document.getElementById('ocr-canvas');
  const W = canvas.width, H = canvas.height;
  const x0 = Math.max(0, Math.min(drawStart.x, drawCurrent.x));
  const y0 = Math.max(0, Math.min(drawStart.y, drawCurrent.y));
  const x1 = Math.min(W, Math.max(drawStart.x, drawCurrent.x));
  const y1 = Math.min(H, Math.max(drawStart.y, drawCurrent.y));
  if (x1 - x0 >= 6 && y1 - y0 >= 6) {
    ocrRegions[activeRegion] = { x:x0/W, y:y0/H, w:(x1-x0)/W, h:(y1-y0)/H };
    updateRegionButtons();
  }
  drawStart = drawCurrent = null;
  redrawRegions();
}

function updateRegionButtons() {
  document.querySelectorAll('.ocr-rbtn').forEach(btn => {
    btn.classList.toggle('set', !!ocrRegions[btn.dataset.region]);
  });
}

function redrawRegions() {
  const canvas = document.getElementById('ocr-canvas');
  if (!canvas.width || !canvas.height) return;
  const ctx = canvas.getContext('2d');
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  for (const k of REGION_KEYS) {
    const r = ocrRegions[k]; if (!r) continue;
    const x = r.x*canvas.width, y = r.y*canvas.height, w = r.w*canvas.width, h = r.h*canvas.height;
    ctx.strokeStyle = REGION_COLORS[k];
    ctx.lineWidth = 2;
    ctx.fillStyle = REGION_COLORS[k] + '55';
    ctx.fillRect(x, y, w, h);
    ctx.strokeRect(x, y, w, h);
    ctx.fillStyle = '#000';
    ctx.font = 'bold 11px sans-serif';
    const lbl = REGION_LABELS[k];
    const padding = 3;
    const tw = ctx.measureText(lbl).width;
    ctx.fillStyle = REGION_COLORS[k];
    ctx.fillRect(x, y, tw + padding*2, 16);
    ctx.fillStyle = '#000';
    ctx.fillText(lbl, x + padding, y + 12);
  }
  if (drawing && drawStart && drawCurrent) {
    const x0 = Math.min(drawStart.x, drawCurrent.x);
    const y0 = Math.min(drawStart.y, drawCurrent.y);
    const x1 = Math.max(drawStart.x, drawCurrent.x);
    const y1 = Math.max(drawStart.y, drawCurrent.y);
    ctx.strokeStyle = activeRegion ? REGION_COLORS[activeRegion] : '#000';
    ctx.lineWidth = 2; ctx.setLineDash([5,3]);
    ctx.strokeRect(x0, y0, x1-x0, y1-y0);
    ctx.setLineDash([]);
  }
}

function clearAllRegions() {
  ocrRegions = { adres:null, il:null, ilce:null, urun:null, miktar:null };
  updateRegionButtons(); redrawRegions();
}
function saveTemplate() {
  try {
    localStorage.setItem(TEMPLATE_KEY, JSON.stringify(ocrRegions));
    document.getElementById('ocr-status').textContent = '✓ Şablon kaydedildi. Aynı düzendeki sonraki ekran görüntülerinde otomatik yüklenecek.';
  } catch(e) { alert('Şablon kaydedilemedi: ' + e.message); }
}
function loadTemplate() {
  try {
    const s = localStorage.getItem(TEMPLATE_KEY);
    if (!s) { alert('Kayıtlı şablon bulunamadı. Önce alanları seçip "Şablonu Kaydet"e basın.'); return; }
    const saved = JSON.parse(s);
    for (const k of REGION_KEYS) ocrRegions[k] = saved[k] || null;
    updateRegionButtons(); redrawRegions();
    document.getElementById('ocr-status').textContent = '✓ Şablon yüklendi.';
  } catch(e) { alert('Şablon yüklenemedi: ' + e.message); }
}

/* ── OCR çalıştır ── */
async function runOcr() {
  if (!ocrBitmap) { alert('Görüntü yüklenmedi veya tarayıcı bu görseli okuyamadı. Başka bir görsel deneyin.'); return; }
  const setRegions = REGION_KEYS.filter(k => ocrRegions[k]);
  if (!setRegions.length) {
    alert('Hiç bölge seçilmedi. Önce en az "Adres" alanını çizin.'); return;
  }
  const runBtn = document.getElementById('ocr-run');
  runBtn.disabled = true;
  document.getElementById('ocr-progress-bar').hidden = false;
  const bar = document.querySelector('#ocr-progress-bar > div');
  const status = document.getElementById('ocr-status');

  let worker = null;
  try {
    status.textContent = 'OCR motoru başlatılıyor (ilk seferde Türkçe veri ~10 MB indirilebilir)…';
    worker = await Tesseract.createWorker('tur+eng', 1, {
      logger: m => {
        if (m.status) status.textContent = m.status + (typeof m.progress === 'number' ? ' — ' + Math.round(m.progress*100) + '%' : '');
      }
    });

    const results = {};
    for (let i = 0; i < setRegions.length; i++) {
      const key = setRegions[i];
      status.textContent = `(${i+1}/${setRegions.length}) ${REGION_LABELS[key]} alanı taranıyor…`;
      bar.style.width = ((i / setRegions.length) * 100) + '%';
      const dataUrl = await cropAndPreprocess(ocrRegions[key]);
      const r = await worker.recognize(dataUrl);
      results[key] = r.data;
    }
    bar.style.width = '100%';
    status.textContent = '✓ OCR tamamlandı. Aşağıdaki alanları kontrol edin / düzenleyin.';
    fillReview(results);
    document.getElementById('ocr-review').hidden = false;
    document.getElementById('ocr-apply-new').hidden = false;
    document.getElementById('ocr-apply-merge').hidden = false;
  } catch (err) {
    status.textContent = '✗ Hata: ' + (err.message || err);
  } finally {
    if (worker) try { await worker.terminate(); } catch(e){}
    runBtn.disabled = false;
  }
}

/* Kırpma + ön işlem (3x büyüt + grayscale + kontrast) — OCR doğruluğu için kritik */
async function cropAndPreprocess(region) {
  const sx = Math.max(0, Math.floor(region.x * ocrNatW));
  const sy = Math.max(0, Math.floor(region.y * ocrNatH));
  const sw = Math.max(1, Math.floor(region.w * ocrNatW));
  const sh = Math.max(1, Math.floor(region.h * ocrNatH));

  const scale = 3;
  const dw = sw * scale, dh = sh * scale;
  const c = document.createElement('canvas');
  c.width = dw; c.height = dh;
  const cx = c.getContext('2d');
  cx.imageSmoothingEnabled = true;
  cx.imageSmoothingQuality = 'high';
  cx.drawImage(ocrBitmap, sx, sy, sw, sh, 0, 0, dw, dh);

  // Grayscale + kontrast (yumuşak otsu yaklaşımı)
  const imgData = cx.getImageData(0, 0, dw, dh);
  const d = imgData.data;
  let sum = 0;
  for (let i = 0; i < d.length; i += 4) sum += 0.299*d[i] + 0.587*d[i+1] + 0.114*d[i+2];
  const avg = sum / (d.length / 4);
  for (let i = 0; i < d.length; i += 4) {
    const g = 0.299*d[i] + 0.587*d[i+1] + 0.114*d[i+2];
    let v;
    if (g < avg - 8)      v = Math.max(0, g - 35);
    else if (g > avg + 8) v = Math.min(255, g + 35);
    else                  v = g;
    d[i] = d[i+1] = d[i+2] = v;
  }
  cx.putImageData(imgData, 0, 0);
  return c.toDataURL('image/png');
}

function fillReview(results) {
  const cleanText = (data) => {
    if (!data || !data.text) return '';
    return data.text.replace(/\s+/g, ' ').replace(/[|\\]/g, '').trim();
  };
  document.getElementById('ocr-adres').value = cleanText(results.adres);
  document.getElementById('ocr-il').value    = cleanText(results.il);
  document.getElementById('ocr-ilce').value  = cleanText(results.ilce);

  // Ürünler: "urun" satırlarını ve "miktar" satırlarını sıraya göre eşleştir.
  const urunLines   = results.urun   ? linesOf(results.urun)   : [];
  const miktarLines = results.miktar ? linesOf(results.miktar) : [];

  const wrap = document.getElementById('ocr-products');
  wrap.innerHTML = '';
  const n = Math.max(urunLines.length, miktarLines.length);
  let added = 0;
  for (let i = 0; i < n; i++) {
    const urun = (urunLines[i] || '').replace(/\s+/g,' ').trim();
    const m = (miktarLines[i] || '').match(/-?\d+(?:[.,]\d+)?/);
    const miktar = m ? m[0].replace(',', '.') : '';
    if (!urun && !miktar) continue;
    addOcrProductRow({ urun, miktar });
    added++;
  }
  if (!added) addOcrProductRow({ urun:'', miktar:'' });
}

function linesOf(data) {
  if (data.lines && data.lines.length) {
    return data.lines
      .slice()
      .sort((a, b) => a.bbox.y0 - b.bbox.y0)
      .map(l => l.text)
      .filter(t => t && t.trim().length > 0);
  }
  return (data.text || '').split(/\r?\n/).map(s => s.trim()).filter(Boolean);
}

function addOcrProductRow(pr) {
  const wrap = document.getElementById('ocr-products');
  const row = document.createElement('div');
  row.className = 'ocr-prod-row';
  row.innerHTML = `
    <input type="text" class="ocr-pn" placeholder="Ürün adı" value="${esc(pr.urun || '')}">
    <input type="text" class="ocr-pq" placeholder="Miktar" value="${esc(pr.miktar || '')}" style="text-align:center">
    <button type="button" class="btn-del-row" onclick="this.parentNode.remove()">×</button>`;
  wrap.appendChild(row);
}
function ocrAddProduct() { addOcrProductRow({ urun:'', miktar:'' }); }

function applyOcr(mode) {
  const adres = document.getElementById('ocr-adres').value.trim();
  const il    = document.getElementById('ocr-il').value.trim();
  const ilce  = document.getElementById('ocr-ilce').value.trim();
  const products = [...document.querySelectorAll('#ocr-products .ocr-prod-row')]
    .map(r => ({ urun: r.querySelector('.ocr-pn').value.trim(), miktar: r.querySelector('.ocr-pq').value.trim(), ambalaj:'' }))
    .filter(p => p.urun || p.miktar);

  if (mode === 'new') {
    addCustomer({ id:0, musteri:'', adres, il, ilce,
      products: products.length ? products : [{urun:'', miktar:'', ambalaj:''}] });
  } else {
    if (!customers.length) {
      addCustomer({ id:0, musteri:'', adres, il, ilce,
        products: products.length ? products : [{urun:'', miktar:'', ambalaj:''}] });
    } else {
      const c = customers[customers.length - 1];
      if (!c.adres) c.adres = adres;
      if (!c.il)    c.il    = il;
      if (!c.ilce)  c.ilce  = ilce;
      if (c.products.length === 1 && !c.products[0].urun && !c.products[0].miktar) c.products = [];
      products.forEach(p => c.products.push(p));
      if (!c.products.length) c.products = [{urun:'', miktar:'', ambalaj:''}];
      renderEditor(); render();
    }
  }
  closeOcrModal();
}
</script>
</body>
</html>
