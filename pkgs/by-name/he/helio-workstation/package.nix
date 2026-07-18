{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  curl,
  freetype,
  libGL,
  libjack2,
  libx11,
  libxcomposite,
  libxcursor,
  libxext,
  libxinerama,
  libxrandr,
  makeWrapper,
  pkg-config,
  zenity,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "helio-workstation";
  version = "3.17";

  src = fetchFromGitHub {
    owner = "helio-fm";
    repo = "helio-sequencer";
    tag = finalAttrs.version;
    hash = "sha256-uEo4dxwc1HksYGU5ssYp3rLugszSir2kKo4XxgqvSno=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    freetype
    libx11
    libxext
    libxinerama
    libxrandr
    libxcursor
    libxcomposite
    curl
    libGL
    libjack2
    zenity
  ];

  buildFlags = [ "CONFIG=Release64" ];

  preBuild = ''
    cd Projects/LinuxMakefile
    substituteInPlace Makefile --replace alsa "alsa jack"
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 build/helio $out/bin
    wrapProgram $out/bin/helio --prefix PATH ":" ${zenity}/bin

    mkdir -p $out/share
    cp -r ../Deployment/Linux/Debian/x64/usr/share/* $out/share
    substituteInPlace $out/share/applications/Helio.desktop \
      --replace "/usr/bin/helio" "$out/bin/helio"
  '';

  meta = {
    description = "One music sequencer for all major platforms, both desktop and mobile";
    homepage = "https://helio.fm/";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.suhr ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "helio";
  };
})
