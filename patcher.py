import os
import sys
import shutil
import subprocess
import re
import glob

# Paths configuration
APKTOOL_JAR = r"C:\Users\Nitro 5\Downloads\skpreapk\apktool.jar"
UBER_SIGNER_JAR = r"D:\Gamemod\uber-apk-signer.jar"

# Proxy source libraries compiled via build.bat
PROXY_LIBS = {
    "arm64-v8a": r"C:\Users\Nitro 5\.gemini\antigravity\scratch\treasuhunter_android\libs\arm64-v8a\libpairipcore.so",
    "armeabi-v7a": r"C:\Users\Nitro 5\.gemini\antigravity\scratch\treasuhunter_android\libs\armeabi-v7a\libpairipcore.so"
}

def log(msg):
    print(f"[Patcher] {msg}")

def run_cmd(cmd):
    log(f"Running: {cmd}")
    res = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode != 0:
        log(f"Command failed with code {res.returncode}")
        log(f"STDOUT:\n{res.stdout}")
        log(f"STDERR:\n{res.stderr}")
        return False
    return True

def patch_smali_file(file_path, patch_type):
    if not os.path.exists(file_path):
        return False
        
    log(f"Patching smali: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    if patch_type == "SignatureCheck":
        # Match verifyIntegrity method and replace it to return immediately
        pattern = re.compile(
            r"\.method public static verifyIntegrity\(Landroid/content/Context;\)V.*\.end method",
            re.DOTALL
        )
        dummy_method = (
            ".method public static verifyIntegrity(Landroid/content/Context;)V\n"
            "    .locals 0\n"
            "    return-void\n"
            ".end method"
        )
        new_content, count = pattern.subn(dummy_method, content)
        if count > 0:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            log("  Successfully patched verifyIntegrity!")
            return True
            
    elif patch_type == "LicenseClient":
        # Match checkLicense method and replace it to return immediately
        pattern = re.compile(
            r"\.method public static checkLicense\(Landroid/content/Context;\)V.*\.end method",
            re.DOTALL
        )
        dummy_method = (
            ".method public static checkLicense(Landroid/content/Context;)V\n"
            "    .locals 0\n"
            "    return-void\n"
            ".end method"
        )
        new_content, count = pattern.subn(dummy_method, content)
        if count > 0:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            log("  Successfully patched checkLicense!")
            return True
            
    elif patch_type == "UnityPlayerActivity":
        # Check if treasu loadLibrary exists and remove it
        pattern = re.compile(
            r'const-string v0, "treasu"\s+invoke-static \{v0\}, Ljava/lang/System;->loadLibrary\(Ljava/lang/String;\)V',
            re.DOTALL
        )
        new_content, count = pattern.subn("", content)
        if count > 0:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            log("  Successfully removed loadLibrary('treasu')!")
            return True
            
    return False

def patch_apk(input_apk, output_apk):
    if not os.path.exists(input_apk):
        log(f"Error: Input APK not found at {input_apk}")
        return
        
    temp_dir = os.path.join(os.path.dirname(output_apk), "temp_decompiled")
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
        
    log("Step 1: Decompiling original APK...")
    decompile_cmd = f'java -jar "{APKTOOL_JAR}" d "{input_apk}" -o "{temp_dir}" -f'
    if not run_cmd(decompile_cmd):
        log("Decompile failed!")
        return

    log("Step 2: Injecting proxy libraries...")
    lib_root = os.path.join(temp_dir, "lib")
    arches_patched = 0
    if not os.path.exists(lib_root):
        log("  Warning: 'lib' directory not found (this might be a base split APK). Skipping library injection.")
    else:
        for arch in ["arm64-v8a", "armeabi-v7a"]:
            arch_dir = os.path.join(lib_root, arch)
            if os.path.exists(arch_dir):
                log(f"Processing architecture: {arch}")
                
                # Check if original libpairipcore.so exists
                orig_so_path = os.path.join(arch_dir, "libpairipcore.so")
                backup_so_path = os.path.join(arch_dir, "libpairipcore_orig.so")
                
                if os.path.exists(orig_so_path):
                    # Rename original to libpairipcore_orig.so (overwriting if exists)
                    if os.path.exists(backup_so_path):
                        os.remove(backup_so_path)
                    os.rename(orig_so_path, backup_so_path)
                    log(f"  Renamed original libpairipcore.so to libpairipcore_orig.so")
                    
                    # Copy proxy in
                    proxy_src = PROXY_LIBS[arch]
                    if not os.path.exists(proxy_src):
                        log(f"  Error: Proxy source binary for {arch} not found at {proxy_src}!")
                        return
                    shutil.copy2(proxy_src, orig_so_path)
                    log(f"  Copied proxy libpairipcore.so into {arch} folder")
                    arches_patched += 1
                else:
                    log(f"  Warning: libpairipcore.so not found under {arch_dir}")
                    
                # If libtreasu.so exists, delete it since we merged cheat logic in the proxy
                treasu_path = os.path.join(arch_dir, "libtreasu.so")
                if os.path.exists(treasu_path):
                    os.remove(treasu_path)
                    log(f"  Deleted libtreasu.so (redundant)")

        if arches_patched == 0:
            log("  Warning: No architecture folders with libpairipcore.so were processed.")


    log("Step 3: Finding and patching Smali code...")
    # Search recursively in all smali directories
    smali_dirs = glob.glob(os.path.join(temp_dir, "smali*"))
    for s_dir in smali_dirs:
        # Patch SignatureCheck.smali
        sig_check_path = os.path.join(s_dir, "com", "pairip", "SignatureCheck.smali")
        patch_smali_file(sig_check_path, "SignatureCheck")
        
        # Patch LicenseClient.smali
        lic_client_path = os.path.join(s_dir, "com", "pairip", "licensecheck", "LicenseClient.smali")
        patch_smali_file(lic_client_path, "LicenseClient")
        
        # Patch UnityPlayerActivity.smali
        unity_act_path = os.path.join(s_dir, "com", "unity3d", "player", "UnityPlayerActivity.smali")
        patch_smali_file(unity_act_path, "UnityPlayerActivity")

    log("Step 4: Rebuilding patched APK...")
    unsigned_apk = os.path.join(os.path.dirname(output_apk), "temp_unsigned.apk")
    if os.path.exists(unsigned_apk):
        os.remove(unsigned_apk)
        
    rebuild_cmd = f'java -jar "{APKTOOL_JAR}" b "{temp_dir}" -o "{unsigned_apk}" -f'
    if not run_cmd(rebuild_cmd):
        log("Rebuild failed!")
        return

    log("Step 5: Signing and zipaligning APK...")
    sign_out_dir = os.path.join(os.path.dirname(output_apk), "sign_out")
    if os.path.exists(sign_out_dir):
        shutil.rmtree(sign_out_dir)
    os.makedirs(sign_out_dir, exist_ok=True)
    
    # We let uber-apk-signer sign with its default built-in debug keystore
    sign_cmd = f'java -jar "{UBER_SIGNER_JAR}" --apks "{unsigned_apk}" --out "{sign_out_dir}"'
    if not run_cmd(sign_cmd):
        log("Signing failed!")
        return

    # Find the signed APK in the output directory
    signed_apks = glob.glob(os.path.join(sign_out_dir, "*debugSigned.apk"))
    if not signed_apks:
        log("Error: Signed APK not found in signing output directory!")
        return
        
    shutil.copy2(signed_apks[0], output_apk)
    log(f"SUCCESS: Patched and signed APK written to: {output_apk}")

    # Clean up temp files
    log("Cleaning up temp files...")
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
    if os.path.exists(unsigned_apk):
        os.remove(unsigned_apk)
    if os.path.exists(sign_out_dir):
        shutil.rmtree(sign_out_dir)
    log("Done!")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python patcher.py <input_apk> <output_apk>")
        sys.exit(1)
        
    patch_apk(sys.argv[1], sys.argv[2])
