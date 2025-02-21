import sys
import cv2
from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QLabel, QPushButton, 
                             QVBoxLayout, QHBoxLayout, QFileDialog, QMessageBox)
from PyQt5.QtGui import QPixmap, QImage, QPainter, QPen
from PyQt5.QtCore import Qt, QSize
from ultralytics import YOLO
from Yui_logic import *

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.model = YOLO("yolov8n.pt")  # Загрузка модели при инициализации
        self.current_image = None
        self.initUI()
        
    def initUI(self):
        self.setWindowTitle("YOLO People Detector")
        self.setGeometry(100, 100, 800, 600)
        
        # Создание виджетов
        self.image_label = ImageLabel()
        self.btn_load = QPushButton("Load Image")
        self.btn_process = QPushButton("Process Image")
        self.btn_process.setEnabled(False)
        
        # Расположение элементов
        control_layout = QHBoxLayout()
        control_layout.addWidget(self.btn_load)
        control_layout.addWidget(self.btn_process)
        
        main_layout = QVBoxLayout()
        main_layout.addLayout(control_layout)
        main_layout.addWidget(self.image_label)
        
        container = QWidget()
        container.setLayout(main_layout)
        self.setCentralWidget(container)
        
        # Подключение сигналов
        self.btn_load.clicked.connect(self.load_image)
        self.btn_process.clicked.connect(self.process_image)
        
    def load_image(self):
        filepath, _ = QFileDialog.getOpenFileName(
            self, "Open Image", "", "Image Files (*.png *.jpg *.jpeg *.bmp)")
            
        if filepath:
            self.original_image = cv2.imread(filepath)
            if self.original_image is not None:
                self.current_image = self.original_image.copy()
                self.show_image(self.current_image)
                self.btn_process.setEnabled(True)
            else:
                QMessageBox.critical(self, "Error", "Failed to load image!")
                
    def show_image(self, image):
        height, width, channel = image.shape
        bytes_per_line = 3 * width
        q_img = QImage(image.data, width, height, bytes_per_line, QImage.Format_RGB888).rgbSwapped()
        self.image_label.set_image(q_img)
        
    def process_image(self):
        if self.current_image is not None:
            # Обработка изображения через YOLO
            results = self.model.predict(self.current_image, classes=[0])  # Класс 0 - человек
            
            # Рисование bounding boxes
            processed_image = self.current_image.copy()
            for box in results[0].boxes.xyxy:
                x1, y1, x2, y2 = map(int, box)
                cv2.rectangle(processed_image, (x1, y1), (x2, y2), (0, 255, 0), 2)
                
            self.show_image(processed_image)
            self.current_image = processed_image