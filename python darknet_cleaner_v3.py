pkg update -y && pkg install -y python clang && pip install opencv-python scikit-image numpy && cat > darknet_cleaner_v3.py << 'EOF'
import os
import hashlib
import time
from skimage.metrics import structural_similarity as ssim
import cv2

HOME = os.path.expanduser("~")
WORK_DIR = os.path.join(HOME, "Cleanerv3")
BASE_PATH = os.path.join(HOME, "storage/shared")

if not os.path.exists(WORK_DIR):
    os.makedirs(WORK_DIR)

os.chdir(WORK_DIR)

LOG_FILE = os.path.join(WORK_DIR, "darknet_ai.log")

SIMILARITY_THRESHOLD = 0.9
UNUSED_DAYS = 30
SAFE_MODE = False

def log(msg):
    with open(LOG_FILE, "a") as f:
        f.write(msg + "\n")
    print(msg)

def delete_file(path):
    if SAFE_MODE:
        log(f"[SAFE MODE] {path}")
    else:
        try:
            os.remove(path)
            log(f"[DELETED] {path}")
        except:
            pass

def get_hash(file):
    h = hashlib.md5()
    try:
        with open(file, 'rb') as f:
            h.update(f.read())
        return h.hexdigest()
    except:
        return None

def remove_duplicates():
    log("[AI] Scan duplikat...")
    hashes = {}
    for root, _, files in os.walk(BASE_PATH):
        for name in files:
            path = os.path.join(root, name)
            file_hash = get_hash(path)
            if not file_hash:
                continue
            if file_hash in hashes:
                delete_file(path)
            else:
                hashes[file_hash] = path

def compare_images(img1, img2):
    try:
        img1 = cv2.resize(img1, (100,100))
        img2 = cv2.resize(img2, (100,100))
        grayA = cv2.cvtColor(img1, cv2.COLOR_BGR2GRAY)
        grayB = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)
        score, _ = ssim(grayA, grayB, full=True)
        return score
    except:
        return 0

def clean_similar_images():
    log("[AI] Scan gambar mirip...")
    images = []
    for root, _, files in os.walk(BASE_PATH):
        for f in files:
            if f.lower().endswith((".jpg",".png",".jpeg")):
                images.append(os.path.join(root,f))
    for i in range(len(images)):
        for j in range(i+1, len(images)):
            img1 = cv2.imread(images[i])
            img2 = cv2.imread(images[j])
            score = compare_images(img1, img2)
            if score > SIMILARITY_THRESHOLD:
                log(f"[SIMILAR {score:.2f}] {images[j]}")
                delete_file(images[j])

def clean_junk():
    log("[AI] Hapus file sampah...")
    for root, _, files in os.walk(BASE_PATH):
        for f in files:
            if f.endswith((".tmp",".log",".cache")):
                delete_file(os.path.join(root,f))

def clean_unused():
    log("[AI] Hapus file tidak dipakai...")
    now = time.time()
    for root, _, files in os.walk(BASE_PATH):
        for f in files:
            path = os.path.join(root,f)
            try:
                if (now - os.path.getatime(path)) > UNUSED_DAYS*86400:
                    delete_file(path)
            except:
                pass

def clean_apps():
    log("[AI] Cleaning WhatsApp & Telegram...")
    folders = ["WhatsApp", "Telegram"]
    for folder in folders:
        full_path = os.path.join(BASE_PATH, folder)
        if not os.path.exists(full_path):
            continue
        for root, _, files in os.walk(full_path):
            for f in files:
                path = os.path.join(root,f)
                try:
                    if os.path.getsize(path) > 5*1024*1024:
                        delete_file(path)
                except:
                    pass

def ai_clean():
    log("================================")
    log("🤖 DARK NET AI AUTO CLEAN START")
    log("================================")
    remove_duplicates()
    clean_similar_images()
    clean_unused()
    clean_junk()
    clean_apps()
    log("================================")
    log("💀 CLEANING SELESAI")
    log("================================")

print("=== DARK NET CLEANER AUTO RUN ===")
ai_clean()
EOF
python darknet_cleaner_v3.py
