import os

def hex_to_mif(input_path, output_path, width=32):
    byte_list = []
    with open(input_path, 'r') as f:
        for i, line in enumerate(f):
            if i == 0:
                continue  # Skip header
            parts = line.strip().split()
            if len(parts) < 2:
                continue
            hex_bytes = parts[1:]  # Skip address
            byte_list.extend(hex_bytes)

    # Pad to multiple of 4 bytes
    while len(byte_list) % 4 != 0:
        byte_list.append("00")

    depth = len(byte_list) // 4

    with open(output_path, 'w') as f:
        f.write(f"WIDTH={width};\n")
        f.write(f"DEPTH={depth};\n\n")
        f.write("ADDRESS_RADIX=HEX;\n")
        f.write("DATA_RADIX=HEX;\n\n")
        f.write("CONTENT BEGIN\n")

        for addr in range(depth):
            # Pack 4 bytes into one word (little-endian)
            b0 = byte_list[addr * 4 + 0]
            b1 = byte_list[addr * 4 + 1]
            b2 = byte_list[addr * 4 + 2]
            b3 = byte_list[addr * 4 + 3]
            word = f"{b3}{b2}{b1}{b0}".upper()
            f.write(f"  {addr:04X} : {word};\n")

        f.write("END;\n")

# Create output folder
output_dir = "mif"
os.makedirs(output_dir, exist_ok=True)

converted = 0

# Process all .mem files
for filename in os.listdir():
    if filename.lower().endswith(".mem"):
        input_path = filename
        output_filename = os.path.splitext(filename)[0] + ".mif"
        output_path = os.path.join(output_dir, output_filename)
        hex_to_mif(input_path, output_path)
        print(f"✅ Converted {filename} → {output_path}")
        converted += 1

if converted == 0:
    print("⚠️ No .mem files found in the current directory.")
else:
    print(f"\n🎉 Done! Converted {converted} file(s). Output saved in 'mif/' folder.")

input("\nPress Enter to exit...")