{
  lib,
  fetchurl,
  hash,
  p7zip,
  pname,
  stdenvNoCC,
  version,
  metaCommon ? { },
}:

stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit hash;
    url = "https://github.com/mifi/lossless-cut/releases/download/v${version}/LosslessCut-win-x64.7z";
  };

  nativeBuildInputs = [ p7zip ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/libexec"
    cd ..
    mv "$sourceRoot" "$out/libexec"
    ln -s "$out/libexec/$(basename "$sourceRoot")/LosslessCut.exe" "$out/bin/LosslessCut.exe"
    runHook postInstall
  '';

  sourceRoot = "LosslessCut-win-x64";

  unpackPhase = ''
    runHook preUnpack
    7z x "$src" -o"$sourceRoot"
    runHook postUnpack
  '';

  meta = metaCommon // {
    platforms = lib.platforms.windows;
    mainProgram = "LosslessCut.exe";
  };
}
