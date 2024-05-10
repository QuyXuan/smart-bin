# import hyper as hp
from tensorflow.keras.applications import MobileNet, ResNet50
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras.models import load_model
import numpy as np
import json


def _load_model():
    # model = ResNet50(weights='imagenet')
    model = load_model("./aug_partial_stratify_after_T.h5")
    print("Load model complete!")
    return model


def _preprocess_image(img, shape):
    img_rz = img.resize(shape)
    img_rz = img_to_array(img_rz)
    img_rz = np.expand_dims(img_rz, axis=0)
    return img_rz


class NumpyEncoder(json.JSONEncoder):
    """
    Encoding numpy into json
    """

    def default(self, obj):
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        if isinstance(obj, np.int32):
            return int(obj)
        if isinstance(obj, np.int64):
            return int(obj)
        if isinstance(obj, np.float32):
            return float(obj)
        if isinstance(obj, np.float64):
            return float(obj)
        return json.JSONEncoder.default(self, obj)
