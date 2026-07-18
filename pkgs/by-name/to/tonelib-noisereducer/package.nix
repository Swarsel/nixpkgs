{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  curl,
  dpkg,
  freetype,
  libgbm,
  libglvnd,
  libjack2,
  libxcursor,
  libxinerama,
  libxrandr,
  libxrender,
}:
stdenv.mkDerivation rec {
  pname = "tonelib-noisereducer";
  version = "2.0";

  src = fetchurl {
    url = "https://tonelib.vip/download/24-12-01/ToneLib-NoiseReducer-amd64.deb";
    hash = "sha256-R+JXoc6waKGPMaghlJ8BkLumDcjC7Oq0jx8tFjAKegE=";
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
    libgbm
  ]
  ++ runtimeDependencies;

  installPhase = ''
    runHook preInstall

    cp -r usr $out

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
    description = "ToneLib NoiseReducer – two-unit noise reduction rack effect plugin";
    homepage = "https://tonelib.net/tl-noisereducer.html";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ToneLib-NoiseReducer";
  };
}
