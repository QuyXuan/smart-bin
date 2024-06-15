from PIL import Image
import numpy as np
from flask import Flask, request
import json
import io
import utils
import tensorflow as tf
from tensorflow.keras.preprocessing.image import img_to_array
import base64
from firebase_utils import push_notification, upload_image, set_state_on_esp32

img_height = 160
img_width = 160
class_names = [
    "battery",
    "batterypack",
    "cardboard",
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

compartment_categories = {
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
    "nylon": "organic",
}

model = utils.load_model_predict()
device_token = None
app = Flask(__name__)


@app.route("/predict", methods=["POST"])
def predict():
    print("Predicting...")
    data = {"success": False}
    try:
        if request.files.get("image"):
            image = request.files["image"].read()
            image_bytes = io.BytesIO(image).read()
            upload_image(image_bytes)
            image: Image.Image = Image.open(io.BytesIO(image))
            image = image.resize((img_height, img_width))
            img_array = tf.keras.utils.img_to_array(image)
            img_array = img_array / 255.0
            img_batch = np.expand_dims(img_array, axis=0)
            predictions = model.predict(img_batch)
            score = tf.nn.softmax(predictions[0])
            predicted_class = class_names[np.argmax(score)]
            confidence = np.max(score) * 100
            data["prediction"] = predicted_class
            data["compartment_name"] = compartment_categories[predicted_class]
            data["confidence"] = confidence
            data["success"] = True
            print(f"Predicted class: {predicted_class}")
            set_state_on_esp32(compartment_categories[predicted_class])
            push_notification(
                "GARBAGE CLASSIFICATION!!!",
                f"Predicted class: {predicted_class}!",
                device_token,
            )
    except Exception as e:
        data["error"] = str(e)
        return json.dumps(data, ensure_ascii=False, cls=utils.NumpyEncoder)
    return json.dumps(data, ensure_ascii=False, cls=utils.NumpyEncoder)


@app.route("/predict_img", methods=["POST"])
def predict_img():
    print("Predicting image...")
    data = {"success": False}
    image_b64 = request.json.get("image")
    if image_b64:
        try:
            image_data = base64.b64decode(image_b64)
            image = Image.open(io.BytesIO(image_data))
            image = image.resize((img_height, img_width))
            img_arr = img_to_array(image)
            img_bat = np.expand_dims(img_arr, axis=0)
            predict = model.predict(img_bat)
            score = tf.nn.softmax(predict[0])
            predicted_class = class_names[np.argmax(score)]
            confident = np.max(score) * 100
            data["prediction"] = predicted_class
            data["compartment_name"] = compartment_categories[predicted_class]
            data["confident"] = confident
            data["success"] = True
            print(f"Predicted class: {predicted_class}")
        except Exception as e:
            data["error"] = str(e)
    return json.dumps(data, ensure_ascii=False, cls=utils.NumpyEncoder)


@app.route("/register_device", methods=["POST"])
def register_device():
    print("Call register_device")
    data = {"success": False}
    token = request.json.get("token")
    if token:
        print(f"Register device with token: {token}")
        global device_token
        device_token = token
        data["success"] = True
    return json.dumps(data, ensure_ascii=False, cls=utils.NumpyEncoder)


if __name__ == "__main__":
    print("Starting server...")
    app.run(host="0.0.0.0", port=8000)
