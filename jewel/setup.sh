echo "📦 Installing prerequisites..."
pkg update -y
pkg install -y python git wget termux-api android-tools

CWD=$(pwd)
INSTALL_DIR="$CWD/jewel"
mkdir -p "$INSTALL_DIR"
cd jewel
echo "📂 Creating debug tool directory..."
mkdir -p $HOME/debug-tools
cd $HOME/debug-tools

echo "⬇️ Downloading Python memory patch script..."
wget -O "$INSTALL_DIR/mempatch.py" https://raw.githubusercontent.com/biggiecheesetherat/jecode/refs/heads/main/jewel/mempatch.py

echo "⬇️ Downloading Wireless Debugging setup script..."
cat << 'EOF' > $INSTALL_DIR/wireless_debug_setup.sh
echo ""
echo "==== Wireless Debugging Setup Guide ===="
echo ""
echo "1) Please open the Wireless Debugging settings manually:"
echo "   - Swipe up your recent apps button"
echo "   - Drag Settings app to the top half of the screen (split screen mode)"
echo "   - Then select Termux from recent apps to appear on bottom half"
echo ""
read -p "Press ENTER once you have the Wireless Debugging screen and Termux in split-screen..."

read -p "Press the Pair with Pairing Code option and enter the device IP (e.g. 192.168.1.100): " PAIR_IP
read -p "Then enter the port after the IP (ex. 3782):" PAIR_PORT
read -p "Now enter the pairing code displayed on the device: " PAIR_CODE

echo "[*] Attempting to pair..."
adb pair "$PAIR_IP:$PAIR_PORT" <<< "$PAIR_CODE"
[ $? -ne 0 ] && echo "❌ Pairing failed." && exit 1

echo "✅ Pairing successful!"
read -p "Enter the Wireless Debugging device port (default 5555): " DEBUG_PORT

echo "[*] Connecting to $PAIR_IP:$DEBUG_PORT..."
adb connect "$PAIR_IP:$DEBUG_PORT"
[ $? -eq 0 ] && echo "✅ Connected!" || echo "❌ Connection failed."
EOF

chmod +x wireless_debug_setup.sh

echo "🛠 Creating start_debug.sh..."
cat << 'EOF' > $INSTALL_DIR/start_debug.sh
#!/data/data/com.termux/files/usr/bin/bash

termux-wake-lock
cd "$(dirname "$0")"

echo "⚙️ Starting Wireless Debugging setup..."
bash wireless_debug_setup.sh || exit 1
PKG="com.hortor.julianseditor"
echo "📲 Launching JE..."
adb shell monkey -p "com.hortor.julianseditor" -c android.intent.category.LAUNCHER 1
sleep 2

PID=$(adb shell pidof $PKG)
if [ -z "$PID" ]; then
  echo "❌ Failed to get PID of the app."
  exit 1
fi

echo "🐛 Starting gdbserver on PID $PID..."
adb shell "run-as $PKG /data/local/tmp/gdbserver :1234 --attach $PID" &

sleep 2
echo "🐍 Running memory patch Python script..."
python3 mempatch.py
EOF

chmod +x start_debug.sh

echo "🔗 Adding start_je to your path incase you Ctrl+C the process setup runs."
ln -sf $CWD/jewel/start_debug.sh $PREFIX/bin/start_je

echo "✅ Done!"
echo "Setup is complete! Run start_je to open Julian's Editor."
