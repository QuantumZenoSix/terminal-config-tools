import cv2
import pytesseract
import numpy as np
import questionary
import os
import re  # For cleaning up OCR output

# Path to your video file
# video_path = './Finished/Recording 2025-10-27 155546 - switchbot - bedroom PTAC AC - pretty low voltage.mp4'
video_path = './short.mp4'
# video_path = './Screen_Recording_20250926_180415_SwitchBot_cropped.mp4'

print("Starting...")

# mp4_files = [f for f in os.listdir('.') if f.lower().endswith('.mp4')]
#
# if not mp4_files:
#     print("No .mp4 files found.")
#     exit()
# else:
#     selected = questionary.select(
#         "Select a .mp4 video:",
#         choices=mp4_files,
#         qmark="🎥",
#         pointer="➜ "
#     ).ask()
#
#     if selected:
#         print(f"You chose: {selected}")
#         # Do something with selected file
#         video_path = selected
#     else:
#         print("No file selected.")
#         exit()
#
#



# Optional: Crop region where the number appears (x, y, width, height). Adjust based on your video.
crop_region = None  # Example: (100, 200, 300, 50) for a box starting at (100,200) with size 300x50

# Frame skip: Process every Nth frame to speed up (e.g., 10 for faster analysis)
frame_skip = 10

# Initialize min/max trackers
min_num = float('inf')
max_num = float('-inf')
frame_count = 0

def to_number(s, default=None):
    """Convert string to int or float. Returns default on failure."""
    if s is None:
        return default
    s = str(s).strip()
    if not s:
        return default

    try:
        return int(s)           # first try int (cleaner for whole numbers)
    except ValueError:
        try:
            return float(s)     # then try float
        except ValueError:
            return default

def format_timestamp(seconds):
    """Convert seconds to HH:MM:SS format."""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    return f"{hours:02d}:{minutes:02d}:{secs:02d}"

# Open video
cap = cv2.VideoCapture(video_path)
if not cap.isOpened():
    print("Error opening video file")
    exit()

# Get video FPS for timestamp calculation
fps = cap.get(cv2.CAP_PROP_FPS)

voltages = {}
over_threshold = 0

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    frame_count += 1
    if frame_count % frame_skip != 0:
        continue  # Skip frames

    # Convert to grayscale for better OCR
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Optional crop
    if crop_region:
        x, y, w, h = crop_region
        gray = gray[y:y+h, x:x+w]

    # Apply thresholding to improve contrast (adjust if numbers are light/dark)
    _, thresh = cv2.threshold(gray, 150, 255, cv2.THRESH_BINARY)

    # OCR the frame
    text = pytesseract.image_to_string(thresh, config='--psm 7')  # PSM 7 treats as single line


    # Extract numbers (assuming integers or floats; adjust regex if needed)
    numbers = re.findall(r'\d+\.?\d*', text)


    for num_str in numbers:
        try:
            num = float(num_str)
            min_num = min(min_num, num)
            max_num = max(max_num, num)
        except ValueError:
            pass  # Ignore non-numeric OCR errors

    if numbers:
        # print(numbers)
        num_value = to_number(numbers[0])
        if isinstance(num_value, (int, float)) and 50 <= num_value <= 150:
            timestamp = format_timestamp((frame_count - 1) / fps)

            if num_value <= 114 or num_value >= 126:
                # print("[OVER THRESHOLD!]")
                over_threshold += 1
            else:
                over_threshold = 0

            if over_threshold > 3:
                print(f"{num_value}\t frame_number: {frame_count}\t timestamp: {timestamp} | [OUTSIDE THRESHOLD 3x!]")
            else:
                print(f"{num_value}\t frame_number: {frame_count}\t timestamp: {timestamp}")

            # add to dict
            if numbers[0] in voltages:
                voltages[numbers[0]] += 1
            else:
                voltages[numbers[0]] = 1



cap.release()

if min_num == float('inf') or max_num == float('-inf'):
    print("No numbers detected.")
else:
    print(f"Highest number: {max_num}")
    print(f"Lowest number: {min_num}")
    # print(voltages)

    print("\n===== RESULTS =====")

    for key in sorted(voltages):
        print(f"{key}:{voltages[key]}")


