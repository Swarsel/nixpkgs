{
  lib,
  fetchurl,
  hash,
  isAarch64,
  pname,
  stdenvNoCC,
  undmg,
  version,
  metaCommon ? { },
}:

stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit hash;

    url = "https://github.com/mifi/lossless-cut/releases/download/v${version}/LosslessCut-mac-${
      if isAarch64 then "arm64" else "x64"
    }.dmg";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -r LosslessCut.app "$out/Applications"
    mkdir -p "$out/bin"
    ln -s "$out/Applications/LosslessCut.app/Contents/MacOS/LosslessCut" "$out/bin/losslesscut"
    runHook postInstall
  '';

  sourceRoot = ".";

  meta = metaCommon // {
    platforms = if isAarch64 then [ "aarch64-darwin" ] else lib.platforms.darwin;
    mainProgram = "losslesscut";
  };
}
