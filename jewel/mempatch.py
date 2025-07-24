import subprocess
import re
import time

MAGIC_PREFIXES = ['£', '¢', '€', '¥', '^', '°', '=', '{', '}', '%', '©', '®', '™', '✓']
pattern = re.compile(r"[" + re.escape(''.join(MAGIC_PREFIXES)) + r"]([^\x00\r\n]+)")

# Read PID
package = input("Enter the package name again (e.g., com.example.app): ").strip()
try:
    pid = subprocess.check_output(["adb", "shell", "pidof", package], text=True).strip()
except subprocess.CalledProcessError:
    print("❌ Could not get PID.")
    exit(1)

print(f"✅ PID is {pid}")

# List memory regions
def get_memory_maps():
    maps = subprocess.check_output(["adb", "shell", f"cat /proc/{pid}/maps"], text=True)
    regions = []
    for line in maps.splitlines():
        if 'rw' in line:
            parts = line.split()
            addr = parts[0]
            start, end = [int(x, 16) for x in addr.split('-')]
            regions.append((start, end))
    return regions

# Dump memory from a region
def read_memory(start, end):
    length = end - start
    cmd = f"dd if=/proc/{pid}/mem bs=1 skip={start} count={length} 2>/dev/null | hexdump -v -e '1/1 \"%c\"'"
    return subprocess.check_output(["adb", "shell", cmd], text=True, errors='ignore')

# Write memory
def write_memory(address, value):
    hex_bytes = ''.join(f'\\x{ord(c):02x}' for c in value)
    cmd = f"echo -ne '{hex_bytes}' | dd of=/proc/{pid}/mem bs=1 seek={address} conv=notrunc"
    subprocess.call(["adb", "shell", cmd])

def find_and_replace():
    while True:
        regions = get_memory_maps()
        for start, end in regions:
            try:
                data = read_memory(start, end)
                for match in pattern.finditer(data):
                    code = match.group(1)
                    try:
                        result = str(eval(code))
                        offset = data.find(match.group(0))
                        if offset != -1:
                            address = start + offset
                            print(f"✨ Executing: {code} → {result}")
                            write_memory(address, result + '\x00')
                    except Exception as e:
                        print(f"⚠️ Eval error: {e}")
            except Exception:
                continue
        time.sleep(1)

find_and_replace()
