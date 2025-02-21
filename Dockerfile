# Фаза сборки
FROM python:3.10-slim AS builder

# 1. Добавьте недостающие зависимости для Qt
RUN apt-get update && apt-get install -y \
    libgl1 \
    libqt5gui5 \
    libqt5core5a \
    libxcb-xinerama0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxkbcommon-x11-0 \
    libx11-xcb-dev \
    libxcb-util1 \
    libxrender-dev \
    libsm6 \
    libxrender1 \
    libxext6 \
    libgl1-mesa-glx \
    libxcb-xkb1 \
    libxcomposite1 \
    libxi6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .

# 2. Фиксируйте версии пакетов
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir \
    opencv-python-headless==4.9.0.80 \
    ultralytics==8.0.196 \
    PyQt5==5.15.9 && \
    rm -rf /opt/venv/lib/python3.10/site-packages/cv2/qt/plugins

# Финальный образ
FROM python:3.10-slim

# 4. Добавьте ключевые зависимости X11
RUN apt-get update && apt-get install -y \
    libgl1 \
    libqt5gui5 \
    libxcb-xinerama0 \
    libx11-xcb1 \
    libglib2.0-0 \
    libdbus-1-3 \
    libxcb-shape0 \
    libxcb-xfixes0 \
    libxcomposite1 \
    libxcb-randr0 \
    libxi6 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libxcb-xkb1 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    xvfb \
    libglx-mesa0 \
    libegl1-mesa \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv

# 5. Обновите переменные окружения
ENV QT_DEBUG_PLUGINS=1
ENV QT_QPA_PLATFORM="xcb"
ENV QT_QPA_PLATFORM_PLUGIN_PATH="/opt/venv/lib/python3.10/site-packages/PyQt5/Qt5/plugins"
ENV XDG_RUNTIME_DIR="/tmp/runtime-root"
ENV DISPLAY=:99
ENV QT_XCB_GL_INTEGRATION="xcb_egl"
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app
COPY . .

# 6. Добавьте права на Xvfb и запуск
RUN chmod +x /app/YOLO_logic.py
CMD ["sh", "-c", "Xvfb :99 -screen 0 1024x768x24 & python YOLO_logic.py"]
