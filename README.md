# Treasure Hunter - Auto Mod & Stone Merge Studio 💎

Dự án mod tiện ích tự động (tweak iOS) và công cụ studio tạo công thức ghép đá tự động cho tựa game **Treasure Hunter**.

---

## 🌟 Tính Năng Chính

### 1. Tweak iOS (`tweak.mm`)
- **Tự động đào kho báu (Auto Dig)**: Quét ô đất gần nhất, bám mục tiêu thông minh, cơ chế chống kẹt và tránh quái vật khi đào.
- **Tự động di chuyển & quay lại bãi farm (Campfire Return)**:
  - Khi trong túi có đủ đá khớp với công thức đã nạp, tự động tìm lửa trại gần nhất và di chuyển tới đó để ghép đá.
  - Sau khi ghép đá xong (hoặc hết nguyên liệu), tự động nhớ vị trí bãi farm ban đầu và di chuyển quay trở lại để tiếp tục farm mà không bị kẹt ở lửa trại.
  - Tương thích hoàn toàn với chế độ **Khóa vị trí (Lock Dig Pos)**.
- **Tự động bán chìa khóa (Auto Sell Key)**: Tự động bán chìa khóa đào được trong rương để dọn dẹp túi đồ.
- **Tự động đánh quái & né quái (Auto Attack & Avoid Mobs)**: Bộ lọc quái vật nâng cao (theo ID, HP min/max, Boss, danh mục).
- **Tự động bơm máu (Auto HP Potion)**: Tự động dùng bình máu khi máu dưới ngưỡng an toàn.
- **Hệ thống bản quyền & kích hoạt**: Xác thực mã thiết bị (UDID) và License Key trực tiếp qua Google Sheets.

---

### 2. Studio Ghép Đá Tự Động Web (`/web`)
- 🌐 **Link trực tuyến**: [https://shiuliuliu.github.io/treasurehunter/web/](https://shiuliuliu.github.io/treasurehunter/web/)
- Giao diện trực quan, hiện đại, hiển thị đầy đủ icon 28 loại đá và vật phẩm phụ trợ.
- Hỗ trợ tạo nhóm đá (Groups), công thức ghép (Formulas), tính toán chi phí nguyên liệu.
- Mã hóa / Giải mã nhị phân Base64 tương thích 100% với định dạng công thức trong game và tweak.
- Tích hợp nút **"🌐 Mở trang tạo công thức"** trực tiếp ngay trong menu tweak của game.

---

## 🚀 Cấu Trúc Thư Mục

```
treasurehunter/
├── tweak.mm            # Mã nguồn chính tweak iOS
├── Makefile            # File build Theos
├── control             # Thông tin gói Debian (.deb)
├── dump.cs             # IL2CPP dump reference
├── patcher.py          # Script vá binary
├── crc32_patcher.py    # Script cập nhật CRC32
├── create_key.bat      # Batch launcher cho công cụ tạo key
├── tools/              # Công cụ tạo và quản lý key bản quyền
│   ├── create_key.py
│   └── create_key_gui.py
└── web/                # Studio tạo công thức ghép đá (GitHub Pages)
    ├── index.html
    ├── style.css
    ├── app.js
    ├── run_web.bat
    └── images/         # Icons các loại đá và vật phẩm
```

---

## ⚙️ Hướng Dẫn Sử Dụng

### Cài đặt công thức ghép đá vào Game:
1. Mở trang [Treasure Hunter Studio](https://shiuliuliu.github.io/treasurehunter/web/).
2. Chọn hoặc tạo các công thức ghép đá theo nhu cầu.
3. Bấm **"📋 Sao Chép Mã"** để copy chuỗi Base64.
4. Mở menu cheat trong game -> Mục **Ghép đá theo công thức (Web)** -> Bấm **Nhập Công Thức** -> Dán mã từ Clipboard và bấm **Áp dụng**.
5. Bật nút gạt **Tự động tìm lửa trại** để nhân vật tự động tìm đến lửa trại ghép đá rồi quay về bãi farm!
