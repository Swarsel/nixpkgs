{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
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
  nixosTests,
  nspr,
  nss,
  pango,
  udev,
}:

let
  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    gtk3
    atk
    glib
    pango
    gdk-pixbuf
    cairo
    freetype
    fontconfig
    dbus
    libxi
    libxcursor
    libxdamage
    libxrandr
    libxcomposite
    libxext
    libxfixes
    libxcb
    libxrender
    libx11
    libxtst
    libxscrnsaver
    nss
    nspr
    alsa-lib
    cups
    expat
    udev
    libpulseaudio
    at-spi2-atk
    at-spi2-core
    libxshmfence
    libdrm
    libxkbcommon
    libgbm
  ];

in
stdenv.mkDerivation rec {
  pname = "hyper";
  version = "3.4.1";

  src = fetchurl {
    url = "https://github.com/vercel/hyper/releases/download/v${version}/hyper_${version}_amd64.deb";
    sha256 = "sha256-jEzZ6MWFaNXBS8CAzfn/ufMPpWcua9HhBFzetWMlH1Y=";
  };

  nativeBuildInputs = [ dpkg ];

  installPhase = ''
    mkdir -p "$out/bin"
    mv opt "$out/"

    ln -s "$out/opt/Hyper/hyper" "$out/bin/hyper"
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${libPath}:$out/opt/Hyper:\$ORIGIN" "$out/opt/Hyper/hyper"

    mv usr/* "$out/"

    substituteInPlace $out/share/applications/hyper.desktop \
      --replace "/opt/Hyper/hyper" "hyper"
  '';

  dontPatchELF = true;
  passthru.tests.test = nixosTests.terminal-emulators.hyper;

  meta = {
    description = "Terminal built on web technologies";
    homepage = "https://hyper.is/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      puffnfresh
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "hyper";
    broken = true; # Error: 'node-pty' failed to load
  };
}
