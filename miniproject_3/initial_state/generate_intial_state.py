from PIL import Image

def write_image_hex(image_path):
    """
    Reads an image and writes each pixel's color as a hex value to a file.

    Each pixel is written as a 6-digit (RGB) or 8-digit (RGBA) hexadecimal string.
    """
    img = Image.open(image_path).convert("RGBA")  # Ensure RGBA format
    width, height = img.size
    pixels = img.load()
    red_vals = []
    green_vals = []
    blue_vals = []
    for y in range(height):
        #row_hex = []

        for x in range(width):
            r, g, b, a = pixels[x, y]
            hex_val = f"#{r:02X}{g:02X}{b:02X}{a:02X}"  # e.g. #FFA07AFF
            #row_hex.append(hex_val)
            red_vals.append(f"{r:02X}")
            green_vals.append(f"{g:02X}")
            blue_vals.append(f"{b:02X}")
    
    with open("red.txt", "w") as f:
        f.writelines(line + "\n" for line in red_vals)
    with open("blue.txt", "w") as f:
        f.writelines(line + "\n" for line in blue_vals)
    with open("green.txt", "w") as f:
        f.writelines(line + "\n" for line in green_vals)


write_image_hex(r"C:\Users\amahesh\comparch\Computer-Architecture-Fall-2025\miniproject_3\initial_state\initial_state.png")