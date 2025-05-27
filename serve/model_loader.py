import os, tempfile
import torch, boto3

BUCKET = os.getenv("BUCKET_NAME")
s3     = boto3.client("s3")

def _latest_key():
    objs = s3.list_objects_v2(Bucket=BUCKET)["Contents"]
    # objects keyed like 2025-05-27T17-05-22/model.pt → pick max lexicographically
    return max(o["Key"] for o in objs if o["Key"].endswith("model.pt"))

def load_latest_model():
    key = _latest_key()
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        s3.download_fileobj(Bucket=BUCKET, Key=key, Fileobj=tmp)
        tmp.flush()
        from ml.model import TinyCNN
        net = TinyCNN()
        net.load_state_dict(torch.load(tmp.name, map_location="cpu"))
        net.eval()
        print(f"[loader] loaded {key}")
        return net
