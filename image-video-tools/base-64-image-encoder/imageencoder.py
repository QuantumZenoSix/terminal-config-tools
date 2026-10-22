import argparse
import base64
import os
import sys
from PIL import Image
try:
    import pyperclip
except ImportError:
    pyperclip = None
    print("Warning: 'pyperclip' module not found. Clipboard functionality will be skipped.")
    print("Install it using 'pip install pyperclip'.")

# Set up argument parser
parser = argparse.ArgumentParser(description="Encode an image file to Base64 (resizing if >= 100 KB), save to a text file, and copy to clipboard.")
parser.add_argument("image_path", help="Path to the image file to encode")

# Parse arguments
args = parser.parse_args()

def resize_image_to_under_100kb(input_path, output_path, target_size_kb=100):
    """Resize image to ensure file size is under target_size_kb KB, preserving aspect ratio."""
    img = Image.open(input_path)
    img = img.convert("RGB")  # Ensure consistent format (e.g., convert PNG to RGB)
    scale = 0.9  # Initial scale factor
    while True:
        # Save resized image to temporary file to check size
        img_resized = img.resize((int(img.width * scale), int(img.height * scale)), Image.Resampling.LANCZOS)
        img_resized.save(output_path, "JPEG", quality=85)  # Save as JPEG for smaller size
        if os.path.getsize(output_path) < target_size_kb * 1000 or scale < 0.1:
            break
        scale *= 0.9  # Reduce size further
    return output_path

try:
    # Check if file exists
    if not os.path.exists(args.image_path):
        print(f"Error: The file '{args.image_path}' was not found.")
        sys.exit(1)

    # Check file size (100 KB = 100,000 bytes)
    file_size_kb = os.path.getsize(args.image_path) / 1000
    image_to_encode = args.image_path

    if file_size_kb >= 100:
        print(f"Image size ({file_size_kb:.2f} KB) is >= 100 KB. Creating resized copy.")
        # Generate output path for resized image (e.g., original.png -> original_resized.jpg)
        base, ext = os.path.splitext(args.image_path)
        resized_path = f"{base}_resized.jpg"
        image_to_encode = resize_image_to_under_100kb(args.image_path, resized_path)
        print(f"Resized image saved as '{resized_path}' (size: {os.path.getsize(resized_path) / 1000:.2f} KB).")

    # Encode the image (original or resized)
    with open(image_to_encode, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
    
    # Print the encoded string
    print(encoded_string)
    
    # Save to text file
    # with open("encoded_output.txt", "w") as text_file:
    #     text_file.write(encoded_string)
    
    # Copy to clipboard if pyperclip is available
    if pyperclip:
        pyperclip.copy(f"![Alt text](data:image/png;base64,{encoded_string})")

        print("Base64 string copied to clipboard.")
    else:
        print("Clipboard copy skipped due to missing 'pyperclip' module.")

except FileNotFoundError:
    print(f"Error: The file '{args.image_path}' was not found.")
    sys.exit(1)
except Exception as e:
    print(f"Error: An unexpected error occurred: {e}")
    sys.exit(1)
