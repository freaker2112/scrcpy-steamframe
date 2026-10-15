#!/usr/bin/env bash
set -e

BUILDDIR=build-auto
PREBUILT_SERVER_URL=https://github.com/Genymobile/scrcpy/releases/download/v5.0.1/scrcpy-server-v5.0.1
PREBUILT_SERVER_SHA256=764eb6f79811d5211fe9df341120882ba9994c7a61b897d7bf3fb662e53bc536

echo "[scrcpy] Downloading prebuilt server..."
wget "$PREBUILT_SERVER_URL" -O scrcpy-server
echo "[scrcpy] Verifying prebuilt server..."
echo "$PREBUILT_SERVER_SHA256  scrcpy-server" | sha256sum --check

if grep -q 'ID=steamos' /etc/os-release 2>/dev/null; then
    echo "SteamOS detected, default install location set to mutable path"
    if ! ldconfig -p | grep -q 'libSDL3'; then
        echo "Downloading sdl3..."
        WD1=$PWD
        cd ..
        git clone https://github.com/libsdl-org/SDL.git
        cd SDL
        echo "Building sdl3"
        cmake -S . -B build -DSDL_X11=OFF -DSDL_X11_XSCRNSAVER=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/home/steamos/.local
        cmake --build build --parallel
        cmake --install build
        if [[ ! ":$PKG_CONFIG_PATH:" == *":/home/steamos/.local/lib/pkgconfig:"* ]]; then
            echo 'export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/steamos/.local/lib/pkgconfig"' >> ~/.bashrc
        fi
        if [[ ! ":$LD_LIBRARY_PATH:" == *":/home/steamos/.local/lib:"* ]]; then
            echo 'export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/steamos/.local/lib"' >> ~/.bashrc
        fi
        cd $WD1
        echo "sdl3 installed"
    fi
    echo "[scrcpy] Building client..."
    rm -rf "$BUILDDIR"
    meson setup "$BUILDDIR" --buildtype=release --prefix=/home/steamos/.local --strip -Db_lto=true \
        -Dprebuilt_server=scrcpy-server
    cd "$BUILDDIR"
    ninja
else
    echo "[scrcpy] Building client..."
    rm -rf "$BUILDDIR"
    meson setup "$BUILDDIR" --buildtype=release --strip -Db_lto=true \
        -Dprebuilt_server=scrcpy-server
    cd "$BUILDDIR"
    ninja
fi
echo "[scrcpy] Installing (sudo)..."
sudo ninja install
