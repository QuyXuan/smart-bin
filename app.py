from PIL import Image
import numpy as np

from logger import log_critical, log_info, log_warning, log_error
from flask import Flask, request
import json
import io
import utils
import imagenet
import tensorflow as tf
from tensorflow.keras.preprocessing.image import img_to_array
import base64
from firebase_utils import push_notification, upload_image

img_height = 160
img_width = 160
class_names = [
    "battery",
    "batterypack",
    "cardboard",
    "dish",
    "eggshell",
    "facemask",
    "glass",
    "lighter",
    "metal",
    "milkbox",
    "nylon",
    "paper",
    "plastic",
]

compartmentCategories = {
    "battery": "danger",
    "batterypack": "danger",
    "lighter": "danger",
    "facemask": "danger",
    "milkbox": "recyclable",
    "metal": "recyclable",
    "paper": "recyclable",
    "cardboard": "recyclable",
    "plastic": "recyclable",
    "glass": "glass",
    "eggshell": "organic",
    "dish": "organic",
    "nylon": "organic",
}

# Khởi tạo model.
global model
model = None
# Token thiết bị
global device_token
device_token = None
# Khởi tạo flask app
app = Flask(__name__)


@app.route("/predict", methods=["POST"])
def predict():
    log_info("Predicting...")
    data = {"success": False}
    if request.files.get("image"):
        # Lấy file ảnh người dùng upload lên
        image = request.files["image"].read()
        image_bytes = io.BytesIO(image).read()
        upload_image(image_bytes)
        # Convert sang dạng array image
        image = Image.open(io.BytesIO(image))
        # resize ảnh
        image = image.resize((img_height, img_width))
        # Convert ảnh thành array
        img_arr = img_to_array(image)
        # Mở rộng kích thước của array
        img_bat = np.expand_dims(img_arr, axis=0)
        # Dự đoán phân phối xác suất
        predict = model.predict(img_bat)
        # Tính toán điểm số
        score = tf.nn.softmax(predict[0])
        # Lấy lớp có điểm số cao nhất
        predicted_class = class_names[np.argmax(score)]
        # Lấy điểm số cao nhất
        confident = np.max(score) * 100
        # Gán kết quả vào data
        data["prediction"] = predicted_class
        data["compartmentName"] = compartmentCategories[predicted_class]
        data["confident"] = confident
        data["success"] = True
        log_info(f"Predicted class: {predicted_class}")
        push_notification(
            "Waste Classification", f"Predicted class: {predicted_class}", device_token
        )
    return json.dumps(data, ensure_ascii=False, cls=utils.NumpyEncoder)


@app.route("/predict_img", methods=["POST"])
def predict_img():
    log_info("Predicting image...")
    data = {"success": False}
    # Nhận dữ liệu hình ảnh mã hóa base64 từ request
    image_b64 = request.json.get("image")
    if image_b64:
        try:
            # Giải mã hình ảnh từ base64
            image_data = base64.b64decode(image_b64)
            # Chuyển hình ảnh giải mã sang dạng array image
            image = Image.open(io.BytesIO(image_data))
            # Các bước tiếp theo như resize và xử lý hình ảnh không thay đổi
            image = image.resize((img_height, img_width))
            img_arr = img_to_array(image)
            img_bat = np.expand_dims(img_arr, axis=0)
            predict = model.predict(img_bat)
            score = tf.nn.softmax(predict[0])
            predicted_class = class_names[np.argmax(score)]
            confident = np.max(score) * 100
            # Gán kết quả vào data
            data["prediction"] = predicted_class
            data["compartmentName"] = compartmentCategories[predicted_class]
            data["confident"] = confident
            data["success"] = True
            log_info(f"Predicted class: {predicted_class}")
        except Exception as e:
            # Trả về một lỗi nếu có vấn đề trong quá trình xử lý hình ảnh
            data["error"] = str(e)
    return json.dumps(data, ensure_ascii=False, cls=utils.NumpyEncoder)


@app.route("/register_device", methods=["POST"])
def register_device():
    log_info("Call register_device")
    data = {"success": False}
    token = request.json.get("token")
    if token:
        log_info(f"Register device with token: {token}")
        global device_token
        device_token = token
        data["success"] = True
    return json.dumps(data, ensure_ascii=False, cls=utils.NumpyEncoder)


if __name__ == "__main__":
    log_info("Starting server...")
    # Load model
    model = utils._load_model()
    # IP = '127.0.0.1'
    app.run(host="0.0.0.0", port=8000)
