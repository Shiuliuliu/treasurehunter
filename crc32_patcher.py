import zipfile
import binascii
import sys
import shutil
import os


def crc_patch(crc: int):
    def inner_crc(*args):
        return crc
    return inner_crc


orig_crc_binascii = binascii.crc32


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} patched.apk original.apk")
        sys.exit(1)

    patched_apk = sys.argv[1]
    original_apk = sys.argv[2]

    # Output file name: <patched_basename>_Patched.apk in same directory as patched apk
    base = os.path.splitext(patched_apk)[0]
    output_file = base + "_Patched.apk"

    # Copy patched to output first
    shutil.copy2(patched_apk, output_file)

    print(f"[*] Reading original APK: {original_apk}")
    print(f"[*] Patching CRC32 from original into: {output_file}")

    with zipfile.ZipFile(original_apk, 'r') as orig_zip:
        orig_info = {info.filename: info for info in orig_zip.infolist()}

    # Patch the output APK's central directory CRC32 values
    with zipfile.ZipFile(output_file, 'a') as out_zip:
        for info in out_zip.infolist():
            if info.filename in orig_info:
                orig_entry = orig_info[info.filename]
                if info.CRC != orig_entry.CRC:
                    # Monkey-patch binascii.crc32 to return original CRC
                    binascii.crc32 = crc_patch(orig_entry.CRC)
                    info.CRC = orig_entry.CRC
                    binascii.crc32 = orig_crc_binascii

    print(f"[+] Successfully generated crc32 patched file in {output_file}")
