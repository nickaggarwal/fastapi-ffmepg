from fastapi import FastAPI, HTTPException
import subprocess
from pydantic import BaseModel

app = FastAPI()


class InferRequest(BaseModel):
    video_url: str

@app.get("/v2/health/ready")
@app.get("/v2/health/live")
def health_check():
    return {"status": "running"}


@app.post("/v2/models/stable-diffusion/infer")
def generate_image(request: InferRequest):
    text = request.video_url
    subprocess.run(["wget", "-O", "input.mp4", url], check=True)
    # Transcode the file using ffmpeg
    subprocess.run(["ffmpeg", "-hwaccel", "cuda", "-i", "input.mp4", "output.mp4"], check=True)
    return {"generated_image": "success"}