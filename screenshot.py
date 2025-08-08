import tkinter as tk
from PIL import ImageGrab
import datetime
import argparse


# Kommandozeilenargumente einlesen
parser = argparse.ArgumentParser(description='Screenshot-Tool mit Auswahlbereich.')
parser.add_argument('--screenshotPath', type=str, default=None, help='Pfad zur Screenshot-Datei (inkl. .png)')
args = parser.parse_args()
    
def get_scaling_factor(root_window):
    """Определяет коэффициент масштабирования DPI автоматически"""
    try:
        # Сравнение размеров экрана tkinter vs PIL
        
        # Размер экрана по tkinter (используем существующий root)
        tk_width = root_window.winfo_screenwidth()
        tk_height = root_window.winfo_screenheight()
        
        # Размер экрана через PIL (реальные пиксели)
        screen_img = ImageGrab.grab()
        pil_width, pil_height = screen_img.size
        
        # Вычисляем коэффициент масштабирования
        scaling_factor = pil_width / tk_width
        print(f"Auto-detected scaling factor: {scaling_factor:.2f} (Tkinter: {tk_width}x{tk_height}, PIL: {pil_width}x{pil_height})")
        
        return scaling_factor
        
    except Exception as e:
        print(f"Не удалось определить scaling factor автоматически: {e}, используем 1.0")
        return 1.0

def take_screenshot(save_path=None):
    root.withdraw()
    
    # Получаем коэффициент масштабирования
    scaling_factor = get_scaling_factor(root)
    
    selection = tk.Toplevel(root)
    selection.attributes('-fullscreen', True)
    selection.attributes('-alpha', 0.4)
    selection.attributes('-topmost', True)
    selection.config(cursor='crosshair')
    
    canvas = tk.Canvas(selection, bg='gray')
    canvas.pack(fill=tk.BOTH, expand=True)
    
    rect = None
    start_x = start_y = 0
    
    def on_mouse_down(event):
        nonlocal start_x, start_y, rect
        # Используем canvas координаты для отрисовки
        start_x, start_y = event.x, event.y
        rect = canvas.create_rectangle(start_x, start_y, start_x, start_y, outline='red', width=3)
    
    def on_mouse_drag(event):
        # Используем canvas координаты для отрисовки
        canvas.coords(rect, start_x, start_y, event.x, event.y)
    
    def on_mouse_up(event):
        # Получаем позицию окна selection относительно экрана ПЕРЕД уничтожением
        window_x = selection.winfo_rootx()
        window_y = selection.winfo_rooty()
        
        # Конвертируем canvas координаты в screen координаты для screenshot
        canvas_x1, canvas_y1 = min(start_x, event.x), min(start_y, event.y)
        canvas_x2, canvas_y2 = max(start_x, event.x), max(start_y, event.y)
        
        # Конвертируем в глобальные координаты экрана
        screen_x1 = window_x + canvas_x1
        screen_y1 = window_y + canvas_y1  
        screen_x2 = window_x + canvas_x2
        screen_y2 = window_y + canvas_y2
        
        # Теперь можно уничтожить окно
        selection.destroy()
        
        # Применяем автоматически определенный коэффициент масштабирования
        screen_x1 = int(screen_x1 * scaling_factor)
        screen_y1 = int(screen_y1 * scaling_factor)
        screen_x2 = int(screen_x2 * scaling_factor)
        screen_y2 = int(screen_y2 * scaling_factor)
        
        img = ImageGrab.grab(bbox=(screen_x1, screen_y1, screen_x2, screen_y2))
        
        # Standard-Dateiname mit Zeitstempel, wenn kein Pfad übergeben wurde
        if save_path:
            filename = save_path
        else:
            filename = f"screenshot_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
        
        try:
            img.save(filename)
            #print(f"Screenshot saved as {filename}")
        except Exception as e:
            print(f"Fehler beim Speichern des Screenshots: {e}")
        finally:
            root.destroy()
    
    canvas.bind("<ButtonPress-1>", on_mouse_down)
    canvas.bind("<B1-Motion>", on_mouse_drag)
    canvas.bind("<ButtonRelease-1>", on_mouse_up)
    
    selection.mainloop()

root = tk.Tk()
root.withdraw()

# Screenshot-Funktion aufrufen mit optionalem Pfad
take_screenshot(args.screenshotPath)