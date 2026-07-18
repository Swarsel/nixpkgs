# Saleae logic analyzer software
#
# Suggested udev rules to be able to access the Logic device without being root:
#   SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", MODE="0666"
#   SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
#
# In NixOS, simply add this package to services.udev.packages.

{
  lib,
  stdenv,
  fetchurl,
  dbus,
  fontconfig,
  freetype,
  glib,
  gtk2,
  libGL,
  libice,
  libsm,
  libx11,
  libxcb,
  libxcursor,
  libxext,
  libxfixes,
  libxft,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  makeDesktopItem,
  pciutils,
  runtimeShell,
  unzip,
  xkeyboard-config,
  zlib,
}:

let

  libPath = lib.makeLibraryPath [
    glib
    libsm
    libice
    gtk2
    libxext
    libxft
    fontconfig
    libxrender
    libxfixes
    libx11
    libxi
    libxrandr
    libxcursor
    freetype
    libxinerama
    libxcb
    zlib
    stdenv.cc.cc
    dbus
    libGL
  ];

in

stdenv.mkDerivation rec {
  pname = "saleae-logic";
  version = "1.2.18";

  src = fetchurl {
    url = "https://downloads.saleae.com/logic/${version}/Logic%20${version}%20(64-bit).zip";
    sha256 = "0lhair2vsg8sjvzicvfcjfmvy30q7i01xj4z02iqh7pgzpb025h8";
    name = "saleae-logic-${version}-64bit.zip";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    # Copy prebuilt app to $out
    mkdir "$out"
    cp -r * "$out"

    # Patch it
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out/Logic"
    for bin in "$out/Logic"              \
               "$out/libQt5Widgets.so.5" \
               "$out/libQt5Gui.so.5"     \
               "$out/libQt5Core.so.5"    \
               "$out/libQt5Network.so.5" ; do
        patchelf --set-rpath "${lib.getLib stdenv.cc.cc}/lib:${lib.getLib stdenv.cc.cc}/lib64:${libPath}:\$ORIGIN/Analyzers:\$ORIGIN" "$bin"
    done

    patchelf --set-rpath "${lib.getLib stdenv.cc.cc}/lib:${lib.getLib stdenv.cc.cc}/lib64:${libPath}:\$ORIGIN/../" "$out/platforms/libqxcb.so"

    # Build the LD_PRELOAD library that makes Logic work from a read-only directory
    mkdir -p "$out/lib"
    gcc -shared -fPIC -DOUT=\"$out\" "${./preload.c}" -o "$out/lib/preload.so" -ldl

    # Make wrapper script that uses the LD_PRELOAD library
    mkdir -p "$out/bin"
    cat > "$out/bin/saleae-logic" << EOF
    #!${runtimeShell}
    export LD_PRELOAD="$out/lib/preload.so"
    export QT_XKB_CONFIG_ROOT="${xkeyboard-config}/share/X11/xkb"
    export PATH="${pciutils}/bin:\$PATH"
    exec "$out/Logic" "\$@"
    EOF
    chmod a+x "$out"/bin/saleae-logic

    # Copy the generated .desktop file
    mkdir -p "$out/share/applications"
    cp "$desktopItem"/share/applications/* "$out/share/applications/"

    # Install provided udev rules
    mkdir -p "$out/etc/udev/rules.d"
    cp Drivers/99-SaleaeLogic.rules "$out/etc/udev/rules.d/"
  '';

  desktopItem = makeDesktopItem {
    categories = [ "Development" ];
    comment = "Software for Saleae logic analyzers";
    desktopName = "Saleae Logic";
    exec = "saleae-logic";
    genericName = "Logic analyzer";
    icon = ""; # the package contains no icon
    name = "saleae-logic";
  };

  meta = {
    description = "Software for Saleae logic analyzers";
    homepage = "https://www.saleae.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.intersectLists lib.platforms.x86_64 lib.platforms.linux;
  };
}
