import requests
import urllib.parse
import re
import sys

# ================= CẤU HÌNH THÔNG TIN =================
# Link Google Web App quản lý key của bạn (dùng để hiển thị key sau khi vượt link)
GAS_WEBAPP_URL = "https://script.google.com/macros/s/AKfycbyNJMv06-cA6jO1-k8I3L1Tsm9QMTQId7FONhOqcg9xj1m6mR2WEbPgFxXj-FCDc2wG/exec"

# Link API & Token của bạn trên Link4M
LINK4M_API_URL = "https://link4m.co/api-shorten/v2"
API_TOKEN = "666163972a84477da6246ed1"
# ====================================================

def shorten_key(key):
    # Tạo link đích hiển thị key khi người dùng vượt link rút gọn xong
    dest_url = f"{GAS_WEBAPP_URL}?action=showKey&key={key}"
    encoded_url = urllib.parse.quote(dest_url)

    # Gọi Link4M API để rút gọn link
    shorten_api = f"{LINK4M_API_URL}?api={API_TOKEN}&url={encoded_url}"
    try:
        res_short = requests.get(shorten_api)
        res_short.raise_for_status()
        short_data = res_short.json()
        if short_data.get("status") == "success":
            return short_data.get("shortenedUrl")
        else:
            return f"❌ Lỗi Link4M: {short_data.get('message', 'Không rõ nguyên nhân')}"
    except Exception as e:
        return f"❌ Lỗi kết nối API Link4M: {e}"

def main():
    print("=== CÔNG CỤ RÚT GỌN HÀNG LOẠT KEY QUA LINK4M ===")
    print("-> Nhập hoặc DÁN danh sách các key của bạn vào đây.")
    print("-> Bạn có thể phân tách các key bằng dấu phẩy (,), dấu cách, hoặc xuống dòng.")
    print("-> Nhập xong nhấn ENTER, sau đó nhấn Ctrl+Z (Windows) hoặc Ctrl+D (Mac/Linux) rồi nhấn ENTER để bắt đầu:\n")

    # Đọc dữ liệu từ người dùng (hỗ trợ dán nhiều dòng)
    lines = []
    while True:
        try:
            line = input()
            lines.append(line)
        except EOFError:
            break

    # Gộp và phân tách key dựa trên dấu cách, dấu phẩy, dấu chấm phẩy, hoặc xuống dòng
    raw_content = " ".join(lines)
    keys = [k.strip() for k in re.split(r'[,\s;]+', raw_content) if k.strip()]

    if not keys:
        print("[!] Không tìm thấy key nào để xử lý.")
        return

    print(f"\n[*] Phát hiện {len(keys)} key. Đang tiến hành tạo các link rút gọn, vui lòng chờ...")
    print("=" * 70)

    results = []
    for i, key in enumerate(keys, 1):
        print(f"[{i}/{len(keys)}] Đang rút gọn key: {key}...", end="", flush=True)
        short_url = shorten_key(key)
        print(" Xong!")
        results.append((key, short_url))

    # In kết quả dạng bảng đẹp mắt
    print("\n" + "=" * 25 + " DANH SÁCH LINK RÚT GỌN " + "=" * 25)
    print(f"{'STT':<4} | {'KEY':<18} | {'LINK RÚT GỌN (LINK4M)'}")
    print("-" * 70)
    for idx, (key, url) in enumerate(results, 1):
        print(f"{idx:<4} | {key:<18} | {url}")
    print("=" * 70)

if __name__ == "__main__":
    main()
