{
  lib,
  stdenv,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  autoPatchelfHook,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libcxx,
  libdrm,
  libgbm,
  libnotify,
  libpulseaudio,
  libuuid,
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
  openssl,
  pango,
  requireFile,
  systemd,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "upwork";
  version = "5.8.0.35";

  src = requireFile {
    url = "https://www.upwork.com/ab/downloads/os/linux/";
    sha256 = "sha256-Suv23TL6l5HhkOSRT56LpFRZJxuSLYVc1uT6he8j7O0=";
    name = "${pname}_${version}_amd64.deb";
  };

  nativeBuildInputs = [
    dpkg
    wrapGAppsHook3
    autoPatchelfHook
  ];

  buildInputs = [
    libcxx
    systemd
    libpulseaudio
    stdenv.cc.cc
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libnotify
    libuuid
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    libgbm
    nspr
    nss
    pango
    systemd
  ];

  installPhase = ''
    runHook preInstall

    mv usr $out
    mv opt $out

    # Now it requires lib{ssl,crypto}.so.1.0.0. Fix based on Spotify pkg.
    # https://github.com/NixOS/nixpkgs/blob/efea022d6fe0da84aa6613d4ddeafb80de713457/pkgs/applications/audio/spotify/default.nix#L129
    mkdir -p $out/lib/upwork
    ln -s ${lib.getLib openssl}/lib/libssl.so $out/lib/upwork/libssl.so.1.0.0
    ln -s ${lib.getLib openssl}/lib/libcrypto.so $out/lib/upwork/libcrypto.so.1.0.0

    sed -e "s|/opt/Upwork|$out/bin|g" -i $out/share/applications/upwork.desktop
    makeWrapper $out/opt/Upwork/upwork \
      $out/bin/upwork \
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}/" \
      --prefix LD_LIBRARY_PATH : ${libPath}

    runHook postInstall
  '';

  dontWrapGApps = true;
  libPath = lib.makeLibraryPath buildInputs;

  meta = {
    description = "Online freelancing platform desktop application for time tracking";
    homepage = "https://www.upwork.com/ab/downloads/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ zakkor ];
    platforms = [ "x86_64-linux" ];
  };
}
