{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  avahi,
  curl,
  dpkg,
  jack2,
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
    jack2
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
  pname = "touchosc";
  version = "1.4.9.248";

  src = fetchurl {
    url = "https://hexler.net/pub/${pname}/${pname}-${version}-${suffix}.deb";

    hash =
      {
        aarch64-linux = "sha256-IKk688XFTx1rHEF03uHZ3cN60GwwIlf/FK4mJ0c/PqM=";
        armv7l-linux = "sha256-li1BLZ6/6OJzsCIN2T3V4vEVXfa9GH6PiFkm6lUl4Ec=";
        x86_64-linux = "sha256-NM9v+wyLNnwNw4qY6jDPB9ig/GZfzzrDshMSmi/yvCM=";
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
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/share $out/share

    mkdir -p $out/bin
    cp opt/touchosc/TouchOSC $out/bin/TouchOSC

    wrapProgram $out/bin/TouchOSC \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runLibDeps} \
      --prefix PATH : ${lib.makeBinPath runBinDeps}

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  suffix =
    {
      aarch64-linux = "linux-arm64";
      armv7l-linux = "linux-armhf";
      x86_64-linux = "linux-x64";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Next generation modular control surface";
    homepage = "https://hexler.net/touchosc";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "aarch64-linux"
      "armv7l-linux"
      "x86_64-linux"
    ];

    mainProgram = "TouchOSC";
  };
}
