import tkinter as tk
from tkinter import messagebox
import json
import os
import time
import threading
import csv
from datetime import datetime

CONFIG_FILE = "PetitPomo_config.json"
LOG_FILE = "PetitPomo_log.csv"

class PetitPomoApp(tk.Tk):
    def __init__(self):
        super().__init__()

        self.title("PetitPomo")
        self.geometry("145x132")
        self.resizable(False, False)
        self.configure(bg="lightgray")
        self.attributes("-topmost", True)
        self.overrideredirect(True)  # タイトルバー非表示
        self._offset_x = 0
        self._offset_y = 0
        self.bind("<ButtonPress-1>", self.start_move)
        self.bind("<B1-Motion>", self.do_move)
        # self.bind("<Return>", self.on_enter_key)
        # 状態変数
        self.phase = ""
        self.time_left = 0
        self.running = False
        self.notify_on_rest = False
        self.enable_csv_logging = False
        self.log_data = {
            "Date": "",
            "WorkStart": "",
            "WorkEnd": "",
            "RestStart": "",
            "RestEnd": ""
        }

        self.load_config()

        # UI作成
        self.create_widgets()

        # タイマー用スレッド
        self.timer_thread = None
        self.timer_stop_event = threading.Event()

        self.update_label_fonts()
        self.protocol("WM_DELETE_WINDOW", self.on_close)

    def start_move(self, event):
        self._offset_x = event.x
        self._offset_y = event.y

    def do_move(self, event):
        x = self.winfo_pointerx() - self._offset_x
        y = self.winfo_pointery() - self._offset_y
        self.geometry(f"+{x}+{y}")

    def load_config(self):
        if os.path.exists(CONFIG_FILE):
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                config = json.load(f)
                self.notify_on_rest = config.get("NotifyOnRest", False)
                self.enable_csv_logging = config.get("EnableCsvLogging", False)

    def save_config(self):
        config = {
            "NotifyOnRest": self.notify_on_rest,
            "EnableCsvLogging": self.enable_csv_logging
        }
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(config, f, indent=4)

    def create_widgets(self):
        self.tomato_Title = tk.Label(self, text="🍅", bg="lightgray", font=("Segoe UI", 10, "bold"))
        self.tomato_Title.place(x=5, y=0, width=15, height=20)

        self.label_Title = tk.Label(self, text="PetitPomo", bg="lightgray", font=("Segoe UI", 10, "bold"))
        self.label_Title.place(x=20, y=1, width=80, height=20)

        # Work label & entry
        self.label_work = tk.Label(self, text="Work (min)", bg="lightgray")
        self.label_work.place(x=10, y=23, width=75, height=20)

        self.entry_work = tk.Entry(self, width=5)
        self.entry_work.place(x=90, y=23, width=40, height=20)
        self.entry_work.insert(0, "25")

        # Rest label & entry
        self.label_rest = tk.Label(self, text="Rest (min)", bg="lightgray")
        self.label_rest.place(x=10, y=46, width=75, height=20)

        self.entry_rest = tk.Entry(self, width=5)
        self.entry_rest.place(x=90, y=47, width=40, height=20)
        self.entry_rest.insert(0, "5")

        # Countdown label
        self.label_countdown = tk.Label(self, text="00:00", font=("Segoe UI", 22, "bold"), bg="lightgray")
        self.label_countdown.place(x=13, y=87, width=120, height=50)
        self.label_countdown.configure(anchor="center")

        # Start button
        self.button_start = tk.Button(self, text="Start", command=self.on_start_stop, relief=tk.GROOVE)
        self.button_start.place(x=8, y=72, width=50, height=25)
        self.button_start.bind("<Return>", lambda event: self.button_start.invoke())

        # Reset button
        self.button_reset = tk.Button(self, text="Reset", command=self.on_reset, relief=tk.GROOVE)
        self.button_reset.place(x=60, y=72, width=45, height=25)
        self.button_reset.bind("<Return>", lambda event: self.button_reset.invoke())

        # Settings button (replace menu)
        self.button_settings = tk.Button(self, text="...", font=("Segoe UI", 10, "bold"), command=self.show_settings, relief=tk.GROOVE)
        self.button_settings.place(x=110, y=72, width=25, height=25)
        self.button_settings.bind("<Return>", lambda event: self.button_settings.invoke())

        self.button_close = tk.Button(self, text="×", command=self.on_close, bg="gray", fg="white", bd=0, font=("Segoe UI", 10, "bold"))
        self.button_close.place(x=123, y=0, width=22, height=20)
        self.button_close.bind("<Return>", lambda event: self.button_close.invoke())


    def validate_positive_number(self, text):
        try:
            num = float(text)
            if num <= 0 or num >= 1000:
                return None
            return num
        except ValueError:
            return None

    def set_phase_time(self):
        work_min = self.validate_positive_number(self.entry_work.get())
        rest_min = self.validate_positive_number(self.entry_rest.get())
        if self.phase == "work":
            if work_min is None:
                return False
            self.time_left = int(work_min * 60)
            self.configure(bg="#FFB6C1")  # LightPink
            self.label_countdown.configure(bg="#FFB6C1")
            self.label_work.configure(font=("Segoe UI", 10, "bold"), bg="#FFB6C1")
            self.label_rest.configure(font=("Segoe UI", 10, "normal"), bg="#FFB6C1")
            self.tomato_Title.configure(bg="#FFB6C1",fg="red")
            self.label_Title.configure(bg="#FFB6C1",fg="red")
            self.button_start.configure(bg="#FF8698")
            self.button_reset.configure(bg="#FF8698")
            self.button_settings.configure(bg="#FF8698")
            self.button_close.configure(bg="#FF8698", fg="black")
            now = datetime.now()
            self.log_data["WorkStart"] = now.strftime("%H:%M:%S")
            self.log_data["Date"] = now.strftime("%Y-%m-%d")
        elif self.phase == "rest":
            if rest_min is None:
                return False
            self.time_left = int(rest_min * 60)
            self.configure(bg="#90EE90")  # LightGreen
            self.label_countdown.configure(bg="#90EE90")
            self.label_work.configure(font=("Segoe UI", 10, "normal"), bg="#90EE90")
            self.label_rest.configure(font=("Segoe UI", 10, "bold"), bg="#90EE90")
            self.tomato_Title.configure(bg="#90EE90",fg="green")
            self.label_Title.configure(bg="#90EE90",fg="green")
            self.button_start.configure(bg="#5DD65D")
            self.button_reset.configure(bg="#5DD65D")
            self.button_settings.configure(bg="#5DD65D")
            self.button_close.configure(bg="#5DD65D", fg="black")

            now = datetime.now()
            self.log_data["WorkEnd"] = now.strftime("%H:%M:%S")
            self.log_data["RestStart"] = now.strftime("%H:%M:%S")
        else:
            return False
        return True


    def update_countdown_label(self):
        minutes = self.time_left // 60
        seconds = self.time_left % 60
        self.label_countdown.config(text=f"{minutes:02d}:{seconds:02d}")

    def update_label_fonts(self):
        if not self.running:
            self.label_work.configure(font=("Segoe UI", 10, "normal"))
            self.label_rest.configure(font=("Segoe UI", 10, "normal"))
        else:
            if self.phase == "work":
                self.label_work.configure(font=("Segoe UI", 10, "bold"))
                self.label_rest.configure(font=("Segoe UI", 10, "normal"))
            elif self.phase == "rest":
                self.label_work.configure(font=("Segoe UI", 10, "normal"))
                self.label_rest.configure(font=("Segoe UI", 10, "bold"))

    def log_session_to_csv(self):
        self.log_data["RestEnd"] = datetime.now().strftime("%H:%M:%S")
        file_exists = os.path.exists(LOG_FILE)
        with open(LOG_FILE, "a", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            if not file_exists:
                writer.writerow(["Date", "WorkStart", "WorkEnd", "RestStart", "RestEnd", "Memo"])
            writer.writerow([
                self.log_data.get("Date", ""),
                self.log_data.get("WorkStart", ""),
                self.log_data.get("WorkEnd", ""),
                self.log_data.get("RestStart", ""),
                self.log_data.get("RestEnd", ""),
                ""
            ])

    def show_notification(self, title, message):
        if not self.notify_on_rest:
            return

        # tkinterで自動で5秒後に閉じるポップアップ作成
        popup = tk.Toplevel(self)
        popup.title(title)
        popup.geometry("250x100+{}+{}".format(self.winfo_x() + 100, self.winfo_y() + 100))
        popup.attributes("-topmost", True)
        popup.resizable(False, False)
        if self.phase == "rest":
            popup.configure(bg='#90EE90')
            label = tk.Label(popup, text=message, font=("Segoe UI", 11),bg='#90EE90')
        else:
            popup.configure(bg='#FFB6C1')
            label = tk.Label(popup, text=message, font=("Segoe UI", 11),bg='#FFB6C1')
        label.pack(expand=True, fill="both", padx=20, pady=20)
        # 5秒後に閉じる
        popup.after(5000, popup.destroy)

    def timer_tick(self):
        while not self.timer_stop_event.is_set():
            if self.running:
                if self.time_left > 0:
                    self.time_left -= 1
                    self.after(0, self.update_countdown_label)
                else:
                    # 時間切れ
                    if self.phase == "rest" and self.enable_csv_logging:
                        self.log_session_to_csv()

                    self.phase = "rest" if self.phase == "work" else "work"

                    if self.phase == "rest":
                        self.show_notification("Rest Time", "Rest time! Please relax.")
                    else:
                        self.show_notification("Work Time", "Work time! Let's focus.")

                    if not self.set_phase_time():
                        self.running = False

                    self.after(0, self.update_label_fonts)
                    self.after(0, self.update_countdown_label)

            time.sleep(1)

    def on_start_stop(self):
        work_min = self.validate_positive_number(self.entry_work.get())
        rest_min = self.validate_positive_number(self.entry_rest.get())

        if work_min is None:
            messagebox.showerror("Error", "Work time must be a positive number less than 1000[min].")
            return
        if rest_min is None:
            messagebox.showerror("Error", "Rest time must be a positive number less than 1000[min].")
            return

        if not self.running:
            if not self.phase:
                self.phase = "work"
            if self.time_left <= 0:
                if not self.set_phase_time():
                    return
                self.update_countdown_label()

            self.running = True
            self.button_start.config(text="Stop")
            if self.timer_thread is None or not self.timer_thread.is_alive():
                self.timer_stop_event.clear()
                self.timer_thread = threading.Thread(target=self.timer_tick, daemon=True)
                self.timer_thread.start()
        else:
            self.running = False
            self.button_start.config(text="Start")

        self.update_label_fonts()

    def on_reset(self):
        self.running = False
        self.phase = ""
        self.time_left = 0
        self.update_countdown_label()
        self.button_start.config(text="Start")
        self.configure(bg="lightgray")
        self.update_label_fonts()
        self.configure(bg="lightgray")  # LightGreen
        self.label_countdown.configure(bg="lightgray")
        self.tomato_Title.configure(bg="lightgray",fg="black")
        self.label_Title.configure(bg="lightgray",fg="black")
        self.label_work.configure(font=("Segoe UI", 10, "normal"), bg="lightgray")
        self.label_rest.configure(font=("Segoe UI", 10, "normal"), bg="lightgray")
        self.button_start.configure(bg="lightgray")
        self.button_reset.configure(bg="lightgray")
        self.button_settings.configure(bg="lightgray")
        self.button_close.configure(bg="gray")

    def show_settings(self):
        # シンプルな設定ダイアログ
        win = tk.Toplevel(self)
        win.title("Settings")
        win.geometry("250x150")
        win.resizable(False, False)
        win.grab_set()

        notify_var = tk.BooleanVar(value=self.notify_on_rest)
        csv_var = tk.BooleanVar(value=self.enable_csv_logging)

        cb1 = tk.Checkbutton(win, text="Notify on rest", variable=notify_var)
        cb1.pack(anchor="w", padx=10, pady=5)

        cb2 = tk.Checkbutton(win, text="Enable CSV logging", variable=csv_var)
        cb2.pack(anchor="w", padx=10, pady=5)

        def on_ok(event=None):  # eventを受け取れるようにする
            self.notify_on_rest = notify_var.get()
            self.enable_csv_logging = csv_var.get()
            self.save_config()
            win.destroy()

        btn = tk.Button(win, text=" Save ", command=on_ok, relief=tk.GROOVE)
        btn.pack(anchor="w", padx=100, pady=5)

        # ↓ Checkbutton に Enter をバインド（フォーカスがあるときのみ）
        cb1.bind("<Return>", lambda e: cb1.invoke())
        cb2.bind("<Return>", lambda e: cb2.invoke())

        # ↓ Button に Enter をバインド
        btn.bind("<Return>", on_ok)

        # 最後のラベル（任意）
        tk.Label(win, text="by ataruno", font=("Segoe UI", 8)).pack(anchor="w", padx=80, pady=5)

        # 最初にどこにフォーカスを当てるか（例: 最初のCheckbutton）
        cb1.focus_set()

    def on_close(self):
        self.running = False
        self.timer_stop_event.set()
        self.save_config()
        self.destroy()

if __name__ == "__main__":
    app = PetitPomoApp()
    app.mainloop()
