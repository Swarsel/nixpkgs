{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  avahi,
  curl,
  dpkg,
  gst_all_1,
  libglvnd,
  libx11,
  libxcb,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  libxxf86vm,
  makeWrapper,
  zenity,
}:

let
  runLibDeps = [
    curl
    avahi
    libxcb
    libx11
    libxcursor
    libxext
    libxi
    libxinerama
    libxrandr
    libxrender
    libxxf86vm
    libglvnd
  ];

  runBinDeps = [
    zenity
  ];
in

stdenv.mkDerivation rec {
  pname = "kodelife";
  version = "1.1.0.173";

  src = fetchurl {
    url = "https://hexler.net/pub/${pname}/${pname}-${version}-${suffix}.deb";

    hash =
      {
        aarch64-linux = "sha256-WPUWvgVZR+2Dg4zpk+iUemMBGlGBDtaGkUGrWuF5LBs=";
        armv7l-linux = "sha256-tOPqP40e0JrXg92OluMZrurWHXZavGwTkJiNN1IFVEE=";
        x86_64-linux = "sha256-ZA8BlUtKaiSnXGncYwb2BbhBlULuGz7SWuXL0RAgQLI=";
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    alsa-lib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/share $out/share

    mkdir -p $out/bin
    cp opt/kodelife/KodeLife $out/bin/KodeLife

    wrapProgram $out/bin/KodeLife \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runLibDeps} \
      --prefix PATH : ${lib.makeBinPath runBinDeps}

    runHook postInstall
  '';

  suffix =
    {
      aarch64-linux = "linux-arm64";
      armv7l-linux = "linux-armhf";
      x86_64-linux = "linux-x64";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Real-time GPU shader editor";
    homepage = "https://hexler.net/kodelife";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ prusnak ];

    platforms = [
      "aarch64-linux"
      "armv7l-linux"
      "x86_64-linux"
    ];

    mainProgram = "KodeLife";
  };
}
