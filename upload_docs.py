import os, glob
doc_dir = os.path.expanduser("~/dragon9_workspace/documents")
files = [f for f in glob.glob(os.path.join(doc_dir, "*")) if os.path.isfile(f)]
print("=== DOCUMENT SYNC MANIFEST ===")
print(f"Total files: {len(files)}")
for f in files:
    print(f"\n--- FILE: {os.path.basename(f)} ---")
    try:
        with open(f, "r", encoding="utf-8", errors="ignore") as file_obj:
            print(file_obj.read())
    except Exception as e:
        print(f"[Binary or unreadable file: {e}]")
