from PIL import Image
import numpy as np
# import hyper as hp
from flask import Flask, request
import json
import io
import utils
import imagenet
import tensorflow as tf
from tensorflow.keras.preprocessing.image import img_to_array
import base64

img_height = 160
img_width = 160
class_names = ['cardboard', 'danger', 'facemask', 'glass', 'metal', 'nilon', 'paper', 'plastic']
# Khởi tạo model.
global model 
model = None
# Khởi tạo flask app
app = Flask(__name__)
# api = Api(app)

@app.route("/predict", methods=["POST"])
def predict():
    data = {"success": False}
    if request.files.get("image"):
        # Lấy file ảnh người dùng upload lên
        image = request.files["image"].read()
        # Convert sang dạng array image
        image = Image.open(io.BytesIO(image))
        # resize ảnh
        image = image.resize((img_height, img_width))
        # Convert ảnh thành array
        img_arr = img_to_array(image)
        print("Shape of img_arr:", img_arr.shape)  # In ra hình dạng của img_arr
        # Mở rộng kích thước của array
        img_bat = np.expand_dims(img_arr, axis=0)
        print("Shape of img_bat:", img_bat.shape)  # In ra hình dạng của img_bat
        # Dự đoán phân phối xác suất
        predict = model.predict(img_bat)
        print("predict[0]:", predict[0])  # In ra hình dạng của predict
        # Tính toán điểm số
        score = tf.nn.softmax(predict[0])
        print("Shape of score:", score.shape)  # In ra hình dạng của score
        # Lấy lớp có điểm số cao nhất
        predicted_class = class_names[np.argmax(score)]
        print("np.argmax(score):", np.argmax(score))  # In ra hình dạng của score
        # Lấy điểm số cao nhất
        accuracy = np.max(score) * 100
        # Gán kết quả vào data
        data["prediction"] = predicted_class
        data["accuracy"] = accuracy
        data["success"] = True
    return json.dumps(data, ensure_ascii=False, cls=utils.NumpyEncoder)

@app.route("/predict_img", methods=["POST"])
def predict_img():
    data = {"success": False}
    # Nhận dữ liệu hình ảnh mã hóa base64 từ request
    image_b64 = request.json.get("image")
    print(image_b64)
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
            accuracy = np.max(score) * 100
            # Gán kết quả vào data
            data["prediction"] = predicted_class
            data["accuracy"] = accuracy
            data["success"] = True
        except Exception as e:
            # Trả về một lỗi nếu có vấn đề trong quá trình xử lý hình ảnh
            data["error"] = str(e)
    return json.dumps(data, ensure_ascii=False, cls=utils.NumpyEncoder)

if __name__ == "__main__":
	print("App run!")
	# Load model
	model = utils._load_model()
	# IP = '127.0.0.1'
	app.run(host='0.0.0.0', port=8000)