from fastapi import FastAPI
from pydantic import BaseModel
from model import generate_image

app = FastAPI()

class PromptRequest(BaseModel):
    prompt: str

@app.post("/generate")
def generate(req: PromptRequest):
    img = generate_image(req.prompt)

    # Convert to list for JSON response (or serve as PNG)
    return {
        "prompt": req.prompt,
        "image": img.tolist()
    }