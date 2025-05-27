import torch, torchvision
from torch.utils.data import DataLoader
from model import TinyCNN

def train_one_epoch(model, loader, opt, loss_fn):
    model.train()
    for x, y in loader:
        opt.zero_grad()
        out = model(x)
        loss = loss_fn(out, y)
        loss.backward()
        opt.step()

if __name__ == "__main__":
    ds = torchvision.datasets.MNIST(
        root="data", download=True,
        transform=torchvision.transforms.ToTensor())
    loader = DataLoader(ds, batch_size=128, shuffle=True)

    net = TinyCNN()
    opt = torch.optim.Adam(net.parameters(), lr=1e-3)
    loss_fn = torch.nn.CrossEntropyLoss()

    train_one_epoch(net, loader, opt, loss_fn)

    torch.save(net.state_dict(), "model.pt")
    print("✔ model.pt saved")
