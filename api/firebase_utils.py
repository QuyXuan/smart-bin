from logger import log_info, log_warning, log_error, log_critical
import firebase_admin
from firebase_admin import credentials, messaging, db, storage
import os
import base64
import uuid
import datetime

credentials_file_path = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "credentials.json"
)

cred = credentials.Certificate(credentials_file_path)
firebase_admin.initialize_app(
    cred,
    {
        "databaseURL": "https://eco-app-da818-default-rtdb.asia-southeast1.firebasedatabase.app/",
        "storageBucket": "eco-app-da818.appspot.com",
    },
)

ref = db.reference("/")
bucket = storage.bucket()


def push_notification(title, body, device_token):
    if device_token == None:
        log_error("Device token is required")
        return
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        token=device_token,
    )
    response = messaging.send(message)
    log_info(f"Successfully sent message: {response}")


def upload_image(image_bytes):
    blob = bucket.blob(f"images/{uuid.uuid4()}.png")
    blob.upload_from_string(image_bytes, content_type="image/png")

    image_url = get_signed_url(blob.name)

    return image_url


def get_signed_url(image_path):
    blob = bucket.blob(image_path)
    signed_url = blob.generate_signed_url(expiration=datetime.datetime(2100, 1, 1))
    return signed_url
