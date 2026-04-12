#!/bin/bash

echo "[+] Dark Net Cleaner - Termux Installation"
echo "[*] Script version 1.0"

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running in Termux
if [ ! -d "$PREFIX" ]; then
    echo -e "${RED}[-] This script is designed for Termux!${NC}"
    exit 1
fi

echo -e "${YELLOW}[*] Updating package lists...${NC}"
pkg update && pkg upgrade -y

echo -e "${YELLOW}[*] Installing essential build tools...${NC}"
pkg install -y \
    python \
    git \
    clang \
    make \
    pkg-config \
    libffi-dev \
    zlib-dev

echo -e "${YELLOW}[*] Installing Python development headers...${NC}"
pkg install -y python-dev

# Set proper environment variables for compilation
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LD_LIBRARY_PATH="$PREFIX/lib"

# Clone repository
INSTALL_DIR="$HOME/DarkNetCleaner"
echo -e "${YELLOW}[*] Cloning repository...${NC}"

if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}[*] Directory exists, updating...${NC}"
    cd "$INSTALL_DIR"
    git pull origin main
else
    echo -e "${YELLOW}[*] Creating new installation...${NC}"
    git clone https://github.com/karisnacell69/DarkNetCleaner "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Create Python virtual environment
echo -e "${YELLOW}[*] Setting up Python virtual environment...${NC}"
python -m venv venv
source venv/bin/activate

# Upgrade pip and setuptools
echo -e "${YELLOW}[*] Upgrading pip and setuptools...${NC}"
pip install --upgrade pip setuptools wheel

# Install Python dependencies
echo -e "${YELLOW}[*] Installing Python dependencies...${NC}"
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] Dependencies installed successfully!${NC}"
    else
        echo -e "${RED}[-] Failed to install dependencies${NC}"
        exit 1
    fi
else
    echo -e "${RED}[-] requirements.txt not found!${NC}"
    exit 1
fi

# Check if main script exists
if [ ! -f "darknet_cleaner_v3.py" ]; then
    echo -e "${RED}[-] Main script darknet_cleaner_v3.py not found!${NC}"
    exit 1
fi

# Create launcher script
echo -e "${YELLOW}[*] Creating launcher script...${NC}"
cat > "$INSTALL_DIR/darknetcleaner" << 'EOF'
#!/bin/bash
cd "
	"$(dirname "$0")"
source venv/bin/activate
python darknet_cleaner_v3.py "$@"
deactivate
EOF

chmod +x "$INSTALL_DIR/darknetcleaner"

# Create symlink for easy access
echo -e "${YELLOW}[*] Creating symlink for global access...${NC}"
ln -sf "$INSTALL_DIR/darknetcleaner" "$PREFIX/bin/darknetcleaner" 2>/dev/null

echo -e "${GREEN}[+] Installation completed successfully!${NC}"
echo -e "${GREEN}[+] You can now run the application with:${NC}"
echo -e "${YELLOW}   darknetcleaner${NC}"
echo -e "${GREEN}[+] Or from the installation directory:${NC}"
echo -e "${YELLOW}   $INSTALL_DIR/darknetcleaner${NC}"

# Ask user if they want to run it now
read -p "Do you want to run DarkNetCleaner now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}[*] Starting DarkNetCleaner...${NC}"
    cd "$INSTALL_DIR"
    source venv/bin/activate
    python darknet_cleaner_v3.py
    deactivate
fi
