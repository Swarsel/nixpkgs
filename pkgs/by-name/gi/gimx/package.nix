{
  lib,
  stdenv,
  fetchFromGitHub,
  bluez,
  curl,
  libmhash,
  libusb1,
  libx11,
  libxi,
  libxml2,
  makeWrapper,
  ncurses5,
}:

let
  gimx-config = fetchFromGitHub {
    hash = "sha256-t/Ttlvc9LCRW624oSsFaP8EmswJ3OAn86QgF1dCUjAs=";
    owner = "matlo";
    repo = "GIMX-configurations";
    rev = "c20300f24d32651d369e2b27614b62f4b856e4a0";
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "gimx";
  version = "8.0";

  src = fetchFromGitHub {
    owner = "matlo";
    repo = "GIMX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BcFLdQgEAi6Sxyb5/P9YAIkmeXNZXrKcOa/6g817xQg=";
    fetchSubmodules = true;
  };

  patches = [ ./conf.patch ];
  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    curl
    libusb1
    bluez
    libxml2
    ncurses5
    libmhash
    libx11
    libxi
  ];

  makeFlags = [ "build-core" ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    substituteInPlace ./core/Makefile --replace-fail "chmod ug+s" "echo"
    export DESTDIR="$out"
    make install-shared install-core
    mv $out/usr/lib $out/lib
    mv $out/usr/bin $out/bin
    cp -r ${gimx-config}/Linux $out/share

    makeWrapper $out/bin/gimx $out/bin/gimx-ds4 \
      --add-flags "--nograb" --add-flags "-p /dev/ttyUSB0" \
      --add-flags "-c $out/share/Dualshock4.xml"

    runHook postInstall
  '';

  meta = {
    description = "Game Input Multiplexer";
    homepage = "https://github.com/matlo/GIMX";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
