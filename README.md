Создайте python script и запустите в нём:


--import--

from ultralytics import YOLO

--Load model--

model = YOLO("yolov8n.pt")

---

# опционально
--Run inference--

results = model("image.jpg")

--Print image.jpg results in JSON format--

print(results[0].to_json())

---

Код подгрузит параметры модели отдельным файлом

После этого можно продолжать сборку в обычном формате
