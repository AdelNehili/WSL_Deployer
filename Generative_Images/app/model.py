import torch
import torch.nn as nn
import numpy as np

DEVICE = "cpu"

# Simple text embedding (very lightweight)
class TextEncoder(nn.Module):
    def __init__(self, vocab_size=1000, embed_dim=32):
        super().__init__()
        self.embedding = nn.Embedding(vocab_size, embed_dim)

    def forward(self, x):
        return self.embedding(x).mean(dim=1)
class Generator(nn.Module):
    def __init__(self, noise_dim=32, text_dim=32):
        super().__init__()

        self.fc = nn.Linear(noise_dim + text_dim, 128 * 4 * 4)

        self.net = nn.Sequential(
            nn.ConvTranspose2d(128, 64, 4, stride=2, padding=1),  # 8x8
            nn.ReLU(),
            nn.ConvTranspose2d(64, 32, 4, stride=2, padding=1),   # 16x16
            nn.ReLU(),
            nn.Conv2d(32, 3, 3, padding=1),
            nn.Sigmoid()
        )

    def forward(self, noise, text_emb):
        x = torch.cat([noise, text_emb], dim=1)
        x = self.fc(x)
        x = x.view(-1, 128, 4, 4)
        return self.net(x)


# Initialize
text_encoder = TextEncoder().to(DEVICE)
generator = Generator().to(DEVICE)

def simple_tokenize(prompt, max_len=10):
    tokens = [hash(word) % 1000 for word in prompt.split()]
    tokens = tokens[:max_len] + [0] * (max_len - len(tokens))
    return torch.tensor([tokens], dtype=torch.long)
def generate_image(prompt):
    with torch.no_grad():
        tokens = simple_tokenize(prompt).to(DEVICE)
        text_emb = text_encoder(tokens)

        noise = torch.randn(1, 32).to(DEVICE)

        img = generator(noise, text_emb)
        img = img.squeeze().permute(1, 2, 0).cpu().numpy()

        return (img * 255).astype(np.uint8)