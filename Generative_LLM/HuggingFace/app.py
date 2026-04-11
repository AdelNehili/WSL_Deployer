from fastapi import FastAPI
from pydantic import BaseModel
from transformers import pipeline
import os
import torch
import time


MODEL_ID = os.getenv("MODEL_ID", "Qwen/Qwen2.5-0.5B-Instruct")

app = FastAPI()

print(f"Loading model: {MODEL_ID}")

generator = pipeline(
    "text-generation",
    model=MODEL_ID,
    device_map="cpu",
    torch_dtype=torch.float32
)

class PromptRequest(BaseModel):
    prompt: str
    max_new_tokens: int = 128
    temperature: float = 0.7
    do_sample: bool = True

@app.get("/health")
def health():
    return {
        "status": "ok",
        "model": MODEL_ID,
        "device": "cpu"
    }



@app.post("/generate")
def generate(req: PromptRequest):
    start = time.time()

    result = generator(
        req.prompt,
        max_new_tokens=req.max_new_tokens,
        temperature=req.temperature,
        do_sample=req.do_sample,
        pad_token_id=generator.tokenizer.eos_token_id
    )

    end = time.time()

    full_text = result[0]["generated_text"]
    output = full_text[len(req.prompt):].strip()

    return {
        "model": MODEL_ID,
        "input": req.prompt,
        "output": output,
        "meta": {
            "latency_seconds": round(end - start, 3)
        }
    }

    
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)