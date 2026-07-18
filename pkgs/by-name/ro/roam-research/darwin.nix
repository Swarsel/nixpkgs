{
  lib,
  stdenv,
  fetchurl,
  _7zz,
}:
let
  common = import ./common.nix { inherit fetchurl; };
  inherit (stdenv.hostPlatform) system;
in
stdenv.mkDerivation rec {
  inherit (common) pname version;
  src = common.sources.${system} or (throw "Source for ${pname} is not available for ${system}");
  nativeBuildInputs = [ _7zz ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R *.app "$out/Applications"

    mkdir -p $out/bin
    ln -s "$out/Applications/${appName}.app/Contents/MacOS/${appName}" "$out/bin/${appName}"
    runHook postInstall
  '';

  appName = "Roam Research";
  sourceRoot = ".";

  meta = {
    description = "Note-taking tool for networked thought";
    homepage = "https://roamresearch.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ dbalan ];

    platforms = [
      "aarch64-darwin"
    ];

    mainProgram = "roam-research";
  };
}
