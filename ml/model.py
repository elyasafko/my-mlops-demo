import torch.nn as nn

class TinyCNN(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv = nn.Conv2d(1, 8, 3, padding=1)
        self.fc   = nn.Linear(8 * 28 * 28, 10)

    def forward(self, x):
        x = self.conv(x).relu()
        x = x.view(x.size(0), -1)
        return self.fc(x)
