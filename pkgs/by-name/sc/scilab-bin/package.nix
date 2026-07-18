{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  libx11,
  libxcursor,
  libxext,
  libxft,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
  libxxf86vm,
  makeWrapper,
  ncurses5,
  undmg,
}:

let
  pname = "scilab-bin";
  version = "6.1.1";

  srcs = {
    aarch64-darwin = fetchurl {
      sha256 = "sha256-L4dxD8R8bY5nd+4oDs5Yk0LlNsFykLnAM+oN/O87SRI=";
      url = "https://www.utc.fr/~mottelet/scilab/download/${version}/scilab-${version}-accelerate-arm64.dmg";
    };

    x86_64-linux = fetchurl {
      sha256 = "sha256-PuGnz2YdAhriavwnuf5Qyy0cnCeRHlWC6dQzfr7bLHk=";
      url = "https://www.scilab.org/download/${version}/scilab-${version}.bin.linux-x86_64.tar.gz";
    };
  };
  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  meta = {
    description = "Scientific software package for numerical computations (Matlab lookalike)";
    homepage = "http://www.scilab.org/";
    license = lib.licenses.gpl2Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];

    mainProgram = "scilab";
  };

  darwin = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [
      makeWrapper
      undmg
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{Applications/scilab.app,bin}
      cp -R . $out/Applications/scilab.app
      makeWrapper $out/{Applications/scilab.app/Contents/MacOS,bin}/scilab

      runHook postInstall
    '';

    dontCheckForBrokenSymlinks = true;
    sourceRoot = "scilab-${version}.app";
  };

  linux = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      alsa-lib
      ncurses5
      stdenv.cc.cc
      libx11
      libxcursor
      libxext
      libxft
      libxi
      libxrandr
      libxrender
      libxtst
      libxxf86vm
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      mv -t $out bin include lib share thirdparty
      sed -i \
        -e 's|\$(/bin/|$(|g' \
        -e 's|/usr/bin/||g' \
        $out/bin/{scilab,xcos}
      sed -i \
        -e "s|Exec=|Exec=$out/bin/|g" \
        -e "s|Terminal=.*$|Terminal=true|g" \
        $out/share/applications/*.desktop

      runHook postInstall
    '';

    dontCheckForBrokenSymlinks = true;
  };
in
if stdenv.hostPlatform.isDarwin then darwin else linux
