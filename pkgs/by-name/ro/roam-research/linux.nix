{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  atk,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libpulseaudio,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  nspr,
  nss,
  pango,
  udev,
}:

let
  common = import ./common.nix { inherit fetchurl; };
  inherit (stdenv.hostPlatform) system;
  libPath = lib.makeLibraryPath [
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libdrm
    libxcb
    libxkbcommon
    libxshmfence
    libgbm
    nspr
    nss
    pango
    stdenv.cc.cc
    libxscrnsaver
    libxcursor
    libxrender
    libxtst
    libpulseaudio
    udev
  ];
in
stdenv.mkDerivation rec {
  inherit (common) pname version;
  src = common.sources.${system} or (throw "Source for ${pname} is not available for ${system}");
  nativeBuildInputs = [ dpkg ];

  installPhase = ''
    mkdir -p "$out/bin"
    mv opt "$out/"

    ln -s "$out/opt/Roam Research/roam-research" "$out/bin/roam-research"
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${libPath}:$out/opt/Roam Research:\$ORIGIN" "$out/opt/Roam Research/roam-research"

    mv usr/* "$out/"

    substituteInPlace $out/share/applications/roam-research.desktop \
      --replace "/opt/Roam Research/roam-research" "roam-research"
  '';

  # autoPatchelfHook/patchelf are not used because they cause the binary to coredump.
  dontPatchELF = true;

  meta = {
    description = "Note-taking tool for networked thought";
    homepage = "https://roamresearch.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ dbalan ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "roam-research";
  };
}
