import os
import re
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed

log_path = r"C:\Users\USER\.gemini\antigravity\brain\c37d40ae-83f8-4abc-8506-a44097b042b3\.system_generated\tasks\task-485.log"
output_dir = os.path.join("ml", "data", "drive_download")
os.makedirs(output_dir, exist_ok=True)

with open(log_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

file_entries = []
pattern = re.compile(r"Processing file\s+([a-zA-Z0-9_\-]+)\s+(.+)")

for line in lines:
    m = pattern.search(line)
    if m:
        fid, fname = m.group(1), m.group(2).strip()
        file_entries.append((fid, fname))

print(f"Total files to verify/download: {len(file_entries)}")

def download_file(item):
    fid, fname = item
    out_file = os.path.join(output_dir, fname)
    if os.path.exists(out_file) and os.path.getsize(out_file) > 1000:
        return True, fname, "cached"
    
    url = f"https://drive.google.com/uc?id={fid}&export=download"
    try:
        r = requests.get(url, timeout=15)
        if r.status_code == 200 and len(r.content) > 1000:
            with open(out_file, "wb") as f:
                f.write(r.content)
            return True, fname, f"{len(r.content)/1024:.1f} KB"
        return False, fname, f"status {r.status_code}"
    except Exception as e:
        return False, fname, str(e)

success = 0
failed = 0

with ThreadPoolExecutor(max_workers=16) as executor:
    futures = [executor.submit(download_file, item) for item in file_entries]
    for future in as_completed(futures):
        ok, fname, msg = future.result()
        if ok:
            success += 1
        else:
            failed += 1
        if (success + failed) % 50 == 0 or (success + failed) == len(file_entries):
            print(f"Progress: {success + failed}/{len(file_entries)} (Success: {success}, Failed: {failed})")

print(f"\nFinal Download Result: {success} downloaded successfully, {failed} failed.")
