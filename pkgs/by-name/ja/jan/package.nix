{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  config,
  cudaPackages,
  fetchzip,
  makeWrapper,
  cudaSupport ? config.cudaSupport,
}:

let
  pname = "Jan";
  version = "0.8.3";

  darwin-src = fetchzip {
    hash = "sha256-h2v71DzXez/+wlEp8IMVBk33LlXPhNPJ1UPNLYPShoE=";
    url = "https://github.com/janhq/jan/releases/download/v${version}/jan-mac-universal-${version}.zip";
  };

  linux-src = fetchurl {
    hash = "sha256-vEmioWQ4ic/FrtNFMKaLOcEy2BTRdouPc4PYWk90ZBI=";
    url = "https://github.com/janhq/jan/releases/download/v${version}/Jan_${version}_amd64.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version;
    src = linux-src;
  };

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Open source alternative to ChatGPT that runs 100% offline on your computer";
    homepage = "https://github.com/janhq/jan";
    changelog = "https://github.com/janhq/jan/releases/tag/v${version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ dfjay ];

    platforms =
      lib.platforms.darwin
      ++ (with lib.systems.inspect; patternLogicalAnd patterns.isLinux patterns.isx86_64);

    mainProgram = "Jan";
  };

  linux = appimageTools.wrapType2 {
    inherit pname version;
    inherit passthru meta;
    src = linux-src;

    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/Jan.desktop -t $out/share/applications
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';

    extraPkgs =
      pkgs:
      lib.optionals cudaSupport [
        cudaPackages.cudatoolkit
      ];
  };

  darwin = stdenv.mkDerivation {
    inherit pname version;
    inherit passthru meta;
    src = darwin-src;

    nativeBuildInputs = [
      makeWrapper
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications/${pname}.app
      mkdir -p $out/bin
      cp -R $src/. $out/Applications/${pname}.app/
      if [ -x "$out/Applications/${pname}.app/Contents/MacOS/${pname}" ]; then
        makeWrapper "$out/Applications/${pname}.app/Contents/MacOS/${pname}" $out/bin/${pname}
      fi

      runHook postInstall
    '';

    dontUnpack = true;
  };
in
if stdenv.hostPlatform.isDarwin then darwin else linux
