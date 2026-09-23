import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import requests
import urllib.parse
import re
import threading

# ================= CẤU HÌNH THÔNG TIN =================
GAS_WEBAPP_URL = "https://script.google.com/macros/s/AKfycbyNJMv06-cA6jO1-k8I3L1Tsm9QMTQId7FONhOqcg9xj1m6mR2WEbPgFxXj-FCDc2wG/exec"
LINK4M_API_URL = "https://link4m.co/api-shorten/v2"
API_TOKEN = "666163972a84477da6246ed1"
# ====================================================

class LinkShortenerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Link4M Key Shortener Tool - VIP")
        self.geometry("900x660")
        self.resizable(True, True)
        self._build_ui()

    def _build_ui(self):
        # Catppuccin Mocha Color Palette
        BG  = "#1e1e2e"     # Base background
        BG2 = "#2a2a3e"     # Secondary background (widgets)
        FG  = "#cdd6f4"     # Text foreground
        ACC = "#cba6f7"     # Accent color (Mauve)
        BTN = "#45475a"     # Button background
        ERR = "#f38ba8"     # Error color (Red)
        OK  = "#a6e3a1"     # Success color (Green)
        WRN = "#f9e2af"     # Warning color (Yellow)
        
        self.configure(bg=BG)

        # Style Configurations
        sty = ttk.Style(self)
        sty.theme_use("clam")
        sty.configure("TFrame",        background=BG)
        sty.configure("TLabel",        background=BG, foreground=FG, font=("Segoe UI", 10))
        sty.configure("TEntry",        fieldbackground=BG2, foreground=FG, insertcolor=FG, font=("Segoe UI", 10))
        sty.configure("TButton",       background=BTN, foreground=FG, font=("Segoe UI", 10, "bold"), padding=6)
        sty.map("TButton",             background=[("active", ACC)], foreground=[("active", BG)])
        
        sty.configure("Accent.TButton",background=ACC, foreground=BG, font=("Segoe UI", 10, "bold"), padding=8)
        sty.map("Accent.TButton",      background=[("active", "#b4befe")])
        
        sty.configure("TLabelframe",   background=BG, foreground=ACC, font=("Segoe UI", 10, "bold"))
        sty.configure("TLabelframe.Label", background=BG, foreground=ACC)
        sty.configure("TProgressbar",  troughcolor=BG2, background=ACC, thickness=12)
        sty.configure("TNotebook",     background=BG)
        sty.configure("TNotebook.Tab", background=BTN, foreground=FG, padding=[12, 5], font=("Segoe UI", 10, "bold"))
        sty.map("TNotebook.Tab",       background=[("selected", ACC)], foreground=[("selected", BG)])
        
        # Treeview styling (Result Table)
        sty.configure("Treeview", background=BG2, fieldbackground=BG2, foreground=FG, font=("Segoe UI", 10), rowheight=24)
        sty.configure("Treeview.Heading", background=BTN, foreground=FG, font=("Segoe UI", 10, "bold"))
        sty.map("Treeview", background=[("selected", ACC)], foreground=[("selected", BG)])

        # 1. Header Area
        hdr = tk.Frame(self, bg="#181825", pady=12)
        hdr.pack(fill="x")
        tk.Label(hdr, text="Link4M Key Shortener Tool", bg="#181825", fg=ACC, font=("Segoe UI", 16, "bold")).pack()
        tk.Label(hdr, text="Tự động hóa tạo link rút gọn key thông qua API của Link4M", bg="#181825", fg="#6c7086", font=("Segoe UI", 9)).pack()

        # 2. Main Navigation Notebook
        nb = ttk.Notebook(self)
        nb.pack(fill="both", expand=True, padx=10, pady=6)

        # ============================================================
        # TAB 1: RÚT GỌN LINK
        # ============================================================
        t1 = ttk.Frame(nb)
        nb.add(t1, text="  Rút Gọn Link  ")

        # Split layout: Upper panel for input/actions, Lower panel for table
        top_frame = tk.Frame(t1, bg=BG)
        top_frame.pack(fill="x", padx=10, pady=(10, 4))

        # Left side of top: Key Input box
        f_input = ttk.LabelFrame(top_frame, text="  Nhập Key thủ công  ", padding=10)
        f_input.pack(side="left", fill="both", expand=True, padx=(0, 6))
        
        lbl_hint = tk.Label(f_input, text="Dán hoặc gõ danh sách key (mỗi key cách nhau bằng dấu cách/phẩy/newline):", font=("Segoe UI", 9), fg="#6c7086", bg=BG, justify=tk.LEFT)
        lbl_hint.pack(anchor="w", pady=(0, 4))
        
        self.input_text = scrolledtext.ScrolledText(f_input, bg=BG2, fg=FG, insertbackground=FG, font=("Consolas", 10), wrap="word", height=6)
        self.input_text.pack(fill="both", expand=True)

        # Right side of top: Operations / Control
        f_ctrl = ttk.LabelFrame(top_frame, text="  Trình điều khiển  ", padding=10)
        f_ctrl.pack(side="right", fill="both", padx=(6, 0))
        
        self.btn_run = ttk.Button(f_ctrl, text="  Bắt đầu Rút Gọn", style="Accent.TButton", command=self.start_processing_thread)
        self.btn_run.pack(fill="x", pady=4)
        
        self.btn_clear = ttk.Button(f_ctrl, text="Xóa Dữ Liệu", command=self.clear_input)
        self.btn_clear.pack(fill="x", pady=4)
        
        self.btn_copy_all = ttk.Button(f_ctrl, text="Copy Tất Cả Link", command=self.copy_all_links)
        self.btn_copy_all.pack(fill="x", pady=4)

        # Process / Progress Frame
        f_prog = ttk.LabelFrame(t1, text="  Tiến trình  ", padding=8)
        f_prog.pack(fill="x", padx=10, pady=4)
        self.v_prog = tk.DoubleVar()
        self.prog_bar = ttk.Progressbar(f_prog, variable=self.v_prog, maximum=100)
        self.prog_bar.pack(fill="x")
        self.lbl_status = tk.Label(f_prog, text="Sẵn sàng", bg=BG, fg="#6c7086", font=("Segoe UI", 9))
        self.lbl_status.pack(anchor="w", pady=(4, 0))

        # Bottom Area: Output table
        f_out = ttk.LabelFrame(t1, text="  Bảng kết quả  ", padding=10)
        f_out.pack(fill="both", expand=True, padx=10, pady=(4, 10))

        columns = ("stt", "key", "url")
        self.table = ttk.Treeview(f_out, columns=columns, show="headings")
        self.table.heading("stt", text="STT")
        self.table.heading("key", text="KEY")
        self.table.heading("url", text="LINK RÚT GỌN (LINK4M)")
        
        self.table.column("stt", width=50, minwidth=50, anchor=tk.CENTER)
        self.table.column("key", width=180, minwidth=120, anchor=tk.W)
        self.table.column("url", width=420, minwidth=300, anchor=tk.W)
        
        scroll = ttk.Scrollbar(f_out, orient=tk.VERTICAL, command=self.table.yview)
        self.table.configure(yscrollcommand=scroll.set)
        
        self.table.pack(side="left", fill="both", expand=True)
        scroll.pack(side="right", fill="y")
        
        # Bind double-click or select row to copy automatically
        self.table.bind("<Double-1>", lambda event: self.copy_selected_link())

        # ============================================================
        # TAB 2: HƯỚNG DẪN
        # ============================================================
        t2 = ttk.Frame(nb)
        nb.add(t2, text="  Hướng Dẫn Sử Dụng  ")
        
        hlp = scrolledtext.ScrolledText(t2, bg="#11111b", fg=FG, font=("Consolas", 10), wrap="word")
        hlp.pack(fill="both", expand=True, padx=10, pady=10)
        hlp.insert("1.0", (
            "HỆ THỐNG RÚT GỌN KEY LINK4M - HƯỚNG DẪN\n"
            "=" * 55 + "\n\n"
            "MỤC ĐÍCH:\n"
            "  - Tool này dùng để tự động tạo link rút gọn kiếm tiền (Link4M) cho danh sách\n"
            "    Key VIP của bạn một cách nhanh chóng.\n"
            "  - Người dùng sau khi hoàn thành vượt link (bypass) sẽ tự động được điều hướng\n"
            "    đến trang Web App hiển thị Key để kích hoạt game.\n\n"
            "CÁCH SỬ DỤNG:\n"
            "  [1] Soạn danh sách Key cần rút gọn (tách biệt bằng dấu phẩy, dấu cách, hoặc xuống dòng).\n"
            "  [2] Dán danh sách vào ô 'Nhập Key thủ công' ở Tab 1.\n"
            "  [3] Click chọn 'Bắt đầu Rút Gọn'. Hệ thống sẽ tự động gửi request rút gọn tới Link4M.\n"
            "  [4] Sau khi chạy xong, kết quả sẽ hiện ra ở bảng dưới:\n"
            "      - Nhấp đúp chuột (Double click) vào bất kỳ dòng nào để COPY link rút gọn của dòng đó.\n"
            "      - Nhấp chọn 'Copy Tất Cả Link' để copy nhanh toàn bộ danh sách kết quả.\n\n"
            "Mẹo nhỏ: Bạn nên tắt Menu Tool game (ImGui) khi chạy tool này để tránh bị đè hiển thị.\n"
        ))
        hlp.configure(state="disabled")

    def clear_input(self):
        self.input_text.delete("1.0", tk.END)
        for item in self.table.get_children():
            self.table.delete(item)
        self.lbl_status.config(text="Sẵn sàng")
        self.v_prog.set(0)

    def start_processing_thread(self):
        thread = threading.Thread(target=self.process_keys)
        thread.daemon = True
        thread.start()

    def shorten_key(self, key):
        dest_url = f"{GAS_WEBAPP_URL}?action=showKey&key={key}"
        encoded_url = urllib.parse.quote(dest_url)
        shorten_api = f"{LINK4M_API_URL}?api={API_TOKEN}&url={encoded_url}"
        try:
            res = requests.get(shorten_api, timeout=12)
            res.raise_for_status()
            short_data = res.json()
            if short_data.get("status") == "success":
                return short_data.get("shortenedUrl")
            else:
                return f"Lỗi Link4M: {short_data.get('message', 'Không rõ')}"
        except Exception as e:
            return f"Lỗi kết nối: {e}"

    def process_keys(self):
        self.btn_run.config(state=tk.DISABLED)
        self.btn_clear.config(state=tk.DISABLED)
        self.btn_copy_all.config(state=tk.DISABLED)
        
        raw_text = self.input_text.get("1.0", tk.END)
        keys = [k.strip() for k in re.split(r'[,\s;]+', raw_text) if k.strip()]
        
        if not keys:
            messagebox.showwarning("Cảnh Báo", "Vui lòng nhập danh sách key cần rút gọn!")
            self.btn_run.config(state=tk.NORMAL)
            self.btn_clear.config(state=tk.NORMAL)
            self.btn_copy_all.config(state=tk.NORMAL)
            return

        for item in self.table.get_children():
            self.table.delete(item)

        total = len(keys)
        self.lbl_status.config(text=f"Đang xử lý: 0/{total} key...")
        
        for idx, key in enumerate(keys, 1):
            self.lbl_status.config(text=f"Đang xử lý: {idx}/{total} key ({key})...")
            short_url = self.shorten_key(key)
            
            # Insert to table
            self.table.insert("", tk.END, values=(idx, key, short_url))
            self.v_prog.set((idx / total) * 100)
            
        self.lbl_status.config(text=f"Đã hoàn thành xử lý {total} key!")
        messagebox.showinfo("Thành Công", f"Đã rút gọn xong {total} key!")
        
        self.btn_run.config(state=tk.NORMAL)
        self.btn_clear.config(state=tk.NORMAL)
        self.btn_copy_all.config(state=tk.NORMAL)

    def copy_all_links(self):
        links = []
        for item in self.table.get_children():
            values = self.table.item(item, "values")
            if len(values) >= 3 and "http" in values[2]:
                links.append(values[2])
                
        if not links:
            messagebox.showwarning("Cảnh Báo", "Không có link rút gọn nào hợp lệ để copy.")
            return
            
        self.clipboard_clear()
        self.clipboard_append("\n".join(links))
        messagebox.showinfo("Sao Chép", f"Đã copy toàn bộ {len(links)} link vào bộ nhớ tạm (Clipboard)!")

    def copy_selected_link(self):
        selected = self.table.selection()
        if not selected:
            return
            
        values = self.table.item(selected[0], "values")
        if len(values) >= 3:
            url = values[2]
            self.clipboard_clear()
            self.clipboard_append(url)
            self.lbl_status.config(text=f"Đã copy link: {url}")

if __name__ == "__main__":
    app = LinkShortenerApp()
    app.mainloop()
