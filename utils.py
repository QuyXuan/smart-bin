from tensorflow.keras.models import load_model
import numpy as np
import json


def load_model_predict():
    # model = ResNet50(weights='imagenet')
    model = load_model("./trained_model_v3.h5.keras")
    print("Load model complete!")
    return model


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
