{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  curl,
  dpkg,
  freetype,
  libglvnd,
  libjack2,
  libxcursor,
  libxinerama,
  libxrandr,
  libxrender,
}:

stdenv.mkDerivation rec {
  pname = "tonelib-jam";
  version = "4.8.7";

  src = fetchurl {
    url = "https://tonelib.vip/download/24-10-24/ToneLib-Jam-amd64.deb";
    hash = "sha256-qBCEaV9uw6HHJYK+8AK+JYQK375cY0Ae3gxiQ0+sAg4=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    alsa-lib
    freetype
    libglvnd
  ]
  ++ runtimeDependencies;

  installPhase = ''
    runHook preInstall

    cp -r usr $out
    substituteInPlace $out/share/applications/ToneLib-Jam.desktop \
      --replace-fail "/usr/" "$out/"

    runHook postInstall
  '';

  runtimeDependencies = map lib.getLib [
    curl
    libxcursor
    libxinerama
    libxrandr
    libxrender
    libjack2
  ];

  meta = {
    description = "ToneLib Jam – the learning and practice software for guitar players";
    homepage = "https://tonelib.net/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ToneLib-Jam";
  };
}
