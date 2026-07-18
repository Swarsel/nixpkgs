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
  pname = "tonelib-metal";
  version = "1.3.0";

  src = fetchurl {
    url = "https://tonelib.vip/download/24-10-24/ToneLib-Metal-amd64.deb";
    hash = "sha256-H19ZUOFI7prQJPo9NWWAHSOwpZ4RIbpRJHfQVjDp/VA=";
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
    substituteInPlace $out/share/applications/ToneLib-Metal.desktop \
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
    description = "ToneLib Metal – Guitar amp simulator targeted at metal players";
    homepage = "https://tonelib.net";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ToneLib-Metal";
  };
}
