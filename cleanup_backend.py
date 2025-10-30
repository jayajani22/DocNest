
import os
import shutil
import sys

# --- Configuration ---
# The script assumes it is located in the project root (DocNest_Frontend).
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

# Add any other backend-specific folders or files here if needed.
DIRECTORIES_TO_DELETE = [
    "docnest_api",
    "users",
    "documents",
    "notes",
    "passwords",
    "venv",
    "env",
]

FILES_TO_DELETE = [
    "manage.py",
    "db.sqlite3",
    "requirements.txt",
]

RECURSIVE_TARGETS = {
    "dirs": ["__pycache__", "migrations"],
    "extensions": [".py"],
}

# --- Safety Configuration ---
# Add folders here that the script should NEVER enter.
PROTECTED_DIRECTORIES = [
    # Flutter project
    "docnest",
    # Git and IDE configs
    ".git",
    ".idea",
    ".vscode",
    # Build outputs and platform folders (should be inside "docnest" but added for extra safety)
    "build",
    "android",
    "ios",
    "web",
    "linux",
    "macos",
    "windows",
]

def delete_item(path, is_dir=False):
    """Safely deletes a file or directory and prints the action."""
    try:
        if is_dir:
            if os.path.isdir(path):
                print(f"Deleting directory: {path}")
                shutil.rmtree(path)
            else:
                # This can happen if a previous operation already removed the parent.
                # print(f"Info: Directory not found (may already be deleted): {path}")
                pass
        else:
            if os.path.isfile(path):
                print(f"Deleting file: {path}")
                os.remove(path)
            else:
                # print(f"Info: File not found (may already be deleted): {path}")
                pass
    except OSError as e:
        print(f"  -> Error deleting {os.path.basename(path)}: {e}", file=sys.stderr)

def main():
    """
    Main function to execute the cleanup process.
    """
    print(f"Starting cleanup in: {ROOT_DIR}")
    print("---")

    # 1. Delete specific top-level directories
    print("Step 1: Deleting specified top-level backend directories...")
    for dirname in DIRECTORIES_TO_DELETE:
        path = os.path.join(ROOT_DIR, dirname)
        delete_item(path, is_dir=True)
    print("---
")

    # 2. Delete specific top-level files
    print("Step 2: Deleting specified top-level backend files...")
    for filename in FILES_TO_DELETE:
        path = os.path.join(ROOT_DIR, filename)
        delete_item(path)
    print("---
")

    # 3. Walk the directory tree for recursive cleanup
    print("Step 3: Recursively searching for and deleting backend artifacts...")
    for root, dirs, files in os.walk(ROOT_DIR, topdown=True):
        # Modify dirs in-place to prevent walking into protected directories
        dirs[:] = [d for d in dirs if d not in PROTECTED_DIRECTORIES]

        # Delete target directories found in the walk
        for dirname in list(dirs):
            if dirname in RECURSIVE_TARGETS["dirs"]:
                path = os.path.join(root, dirname)
                delete_item(path, is_dir=True)
                dirs.remove(dirname)  # Don't descend further

        # Delete target files found in the walk
        for filename in files:
            if any(filename.endswith(ext) for ext in RECURSIVE_TARGETS["extensions"]):
                path = os.path.join(root, filename)
                delete_item(path)

    print("---
Cleanup complete.")

if __name__ == "__main__":
    # Safety prompt before running
    print("This script will permanently delete backend-related files and folders.")
    print("Please review the configured lists in the script to ensure safety.")
    
    # In a real-world scenario, you might want a more robust confirmation.
    # For this automated context, we proceed with clear logging.
    main()

