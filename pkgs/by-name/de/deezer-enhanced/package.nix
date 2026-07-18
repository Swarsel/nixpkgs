{
  ### Tools
  lib,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  autoPatchelfHook,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  glib,
  gnutar,
  gtk3,
  libGL,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  ### Libs
  libxrandr,
  makeWrapper,
  nss,
  nwjs,
  pango,
  stdenvNoCC,
  systemdLibs,
}:

stdenvNoCC.mkDerivation rec {
  pname = "deezer-enhanced";
  version = "1.5.1";

  src = fetchurl {
    url = "https://github.com/duzda/deezer-enhanced/releases/download/v${version}/deezer-enhanced_${version}_amd64.deb";
    hash = "sha256-iMqQ6mqP5/1nKjqH58kfiQERUeOF54gHvAOiI8narKI=";
  };

  nativeBuildInputs = [
    ### To unpack deezer-enhanced
    dpkg
    gnutar

    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [

    ### Xorg libs
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb

    ### Systemd libs
    systemdLibs
    dbus

    ### Other libs
    libxkbcommon
    nss
    glib
    at-spi2-atk
    cups
    gtk3
    libGL
    nwjs # For libffmpeg.so
  ];

  installPhase = ''
    runHook preInstall

    ### Create directory and copy files
    mkdir -p $out
    mv usr/* $out

    ### Wrap deezer-enhanced to include all libraries in the environment
    wrapProgram $out/bin/${pname} \
      --set LD_LIBRARY_PATH ${
        lib.makeLibraryPath [
          ### Xorg libs
          libx11
          libxcomposite
          libxdamage
          libxext
          libxfixes
          libxrandr
          libxcb

          ### Systemd libs
          systemdLibs
          dbus

          ### Other libs
          libxkbcommon
          nss
          glib
          at-spi2-atk
          cups
          gtk3
          nwjs
          libGL
        ]
      }

    runHook postInstall
  '';

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb --fsys-tarfile $src | tar --no-same-owner --no-same-permissions -xvf -

    runHook postUnpack
  '';

  meta = {
    description = "Unofficial application for Deezer with enhanced features";
    homepage = "https://github.com/duzda/deezer-enhanced";
    changelog = "https://github.com/duzda/deezer-enhanced/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ minegameYTB ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "deezer-enhanced";
  };
}
