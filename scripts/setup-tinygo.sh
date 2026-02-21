#!/bin/bash

set -e

PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture names
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
fi

echo "Downloading TinyGo for $PLATFORM/$ARCH..."

# Get the latest release version
LATEST_VERSION=$(curl -s https://api.github.com/repos/tinygo-org/tinygo/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

echo "Latest version: $LATEST_VERSION"

# Construct download URL
# Strip 'v' prefix from version for tarball name
VERSION_NO_V=$(echo "$LATEST_VERSION" | sed 's/^v//')
TARBALL="tinygo${VERSION_NO_V}.${PLATFORM}-${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/tinygo-org/tinygo/releases/download/${LATEST_VERSION}/${TARBALL}"

echo "Downloading from: $DOWNLOAD_URL"

# Create bin directory if it doesn't exist
mkdir -p bin

# Download and extract
cd bin
curl -L -o "$TARBALL" "$DOWNLOAD_URL"
tar -xzf "$TARBALL"
rm "$TARBALL"

# Rename the tinygo directory to avoid conflict with the wrapper script
mv tinygo tinygo-dist

# Create a wrapper script that sets TINYGOROOT
cat > ./tinygo << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TINYGOROOT="$SCRIPT_DIR/tinygo-dist"
exec "$SCRIPT_DIR/tinygo-dist/bin/tinygo" "$@"
EOF
chmod +x ./tinygo

echo "TinyGo installed successfully to bin/tinygo"
