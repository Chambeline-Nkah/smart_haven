from fastapi import FastAPI, File, UploadFile
import uvicorn
import numpy as np
import librosa
import librosa.display
import tensorflow as tf
import io
import matplotlib.pyplot as plt
from PIL import Image

app = FastAPI()

# Loading your trained model
MODEL = tf.keras.models.load_model("audio_classification_model.h5")

# Class names (Healthy or Unhealthy)
CLASS_NAMES = ["healthy", "unhealthy"]

def audio_to_mel(audio_bytes):
    """Converting uploaded audio file to a Mel spectrogram image"""
    y, sr = librosa.load(io.BytesIO(audio_bytes), sr=None)
    S = librosa.feature.melspectrogram(y=y, sr=sr, n_fft=1024, hop_length=320, n_mels=64)
    S_db = librosa.power_to_db(S, ref=np.max)

    # Converting to an image
    fig, ax = plt.subplots(figsize=(6, 6))
    librosa.display.specshow(S_db, sr=sr, hop_length=320, x_axis="time", y_axis="log")
    plt.axis("off")
    plt.tight_layout()

    # Saving to buffer
    buf = io.BytesIO()
    plt.savefig(buf, format="png")
    plt.close(fig)

    # Converting to NumPy array for model input
    buf.seek(0)
    img = Image.open(buf).convert("RGB")
    img = img.resize((256, 256))
    img_array = np.array(img) / 255.0
    return np.expand_dims(img_array, axis=0)


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """It accepts an audio file, converts it to a Mel spectrogram, and makes a prediction"""
    audio_bytes = await file.read()
    img_array = audio_to_mel(audio_bytes)

    predictions = MODEL.predict(img_array) 
    predicted_class = CLASS_NAMES[int(predictions[0] > 0.5)]

    return {
        'class': predicted_class
    }


if __name__ == "__main__":
    uvicorn.run(app, host="localhost", port=8000)
