{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  atk,
  autoPatchelfHook,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  libappindicator-gtk3,
  libdrm,
  libgbm,
  libnotify,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  nspr,
  nss,
  pango,
  runtimeShell,
  systemd,
  udev,
  wrapGAppsHook3,
}:

let
  versionSuffix = "20250428154451.19f9cfeddb";
in

stdenv.mkDerivation rec {
  pname = "keybase-gui";
  version = "6.5.1"; # Find latest version and versionSuffix from https://prerelease.keybase.io/deb/dists/stable/main/binary-amd64/Packages

  src = fetchurl {
    url = "https://s3.amazonaws.com/prerelease.keybase.io/linux_binaries/deb/keybase_${version + "-" + versionSuffix}_amd64.deb";
    hash = "sha256-PCKi1lavGwLbCoMTMG4h6PJTIzwRAu542eYqDDKzU4Y=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gsettings-desktop-schemas
    gtk3
    libappindicator-gtk3
    libnotify
    nspr
    nss
    pango
    systemd
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
    libdrm
    libgbm
  ];

  installPhase = ''
    mkdir -p $out/bin
    mv usr/share $out/share
    mv opt/keybase $out/share/

    cat > $out/bin/keybase-gui <<EOF
    #!${runtimeShell}

    checkFailed() {
      if [ "\$NIX_SKIP_KEYBASE_CHECKS" = "1" ]; then
        return
      fi
      echo "Set NIX_SKIP_KEYBASE_CHECKS=1 if you want to skip this check." >&2
      exit 1
    }

    if [ ! -S "\$XDG_RUNTIME_DIR/keybase/keybased.sock" ]; then
      echo "Keybase service doesn't seem to be running." >&2
      echo "You might need to run: keybase service" >&2
      checkFailed
    fi

    if [ -z "\$(keybase status | grep kbfsfuse)" ]; then
      echo "Could not find kbfsfuse client in keybase status." >&2
      echo "You might need to run: kbfsfuse" >&2
      checkFailed
    fi

    exec $out/share/keybase/Keybase \''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} "\$@"
    EOF
    chmod +x $out/bin/keybase-gui

    substituteInPlace $out/share/applications/keybase.desktop \
      --replace run_keybase $out/bin/keybase-gui
  '';

  dontBuild = true;
  dontConfigure = true;
  dontPatchELF = true;

  runtimeDependencies = [
    (lib.getLib udev)
    libappindicator-gtk3
  ];

  unpackPhase = ''
    ar xf $src
    tar xf data.tar.xz
  '';

  meta = {
    description = "Keybase official GUI";
    homepage = "https://www.keybase.io/";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      avaq
      rvolosatovs
      puffnfresh
      np
      shofius
      ryand56
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "keybase-gui";
  };
}
