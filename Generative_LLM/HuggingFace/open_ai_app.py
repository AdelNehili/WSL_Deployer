from fastapi import FastAPI
from pydantic import BaseModel
from transformers import pipeline
import os
import torch

MODEL_ID = os.getenv("MODEL_ID", "Qwen/Qwen2.5-0.5B-Instruct")

app = FastAPI()

print(f"Loading model: {MODEL_ID}")

generator = pipeline(
    "text-generation",
    model=MODEL_ID,
    device_map="cpu",
    torch_dtype=torch.float32
)

class Message(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    model: str | None = None
    messages: list[Message]
    max_tokens: int = 128
    temperature: float = 0.7

@app.get("/health")
def health():
    return {
        "status": "ok",
        "model": MODEL_ID,
        "device": "cpu"
    }

@app.post("/v1/chat/completions")
def chat(req: ChatRequest):
    prompt = ""
    for msg in req.messages:
        prompt += f"{msg.role}: {msg.content}\n"
    prompt += "assistant:"

    result = generator(
        prompt,
        max_new_tokens=req.max_tokens,
        temperature=req.temperature,
        do_sample=True,
        pad_token_id=generator.tokenizer.eos_token_id
    )

    generated = result[0]["generated_text"]
    reply = generated[len(prompt):].strip()

    return {
        "id": "chatcmpl-local",
        "object": "chat.completion",
        "model": MODEL_ID,
        "choices": [
            {
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": reply
                },
                "finish_reason": "stop"
            }
        ]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)