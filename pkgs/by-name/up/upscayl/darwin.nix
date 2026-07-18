{
  makeWrapper,
  meta,
  pname,
  src,
  stdenvNoCC,
  unzip,
  version,
}:
stdenvNoCC.mkDerivation {
  inherit
    pname
    version
    meta
    src
    ;

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,Applications}
    cp -r Upscayl.app $out/Applications/
    makeWrapper $out/Applications/Upscayl.app/Contents/MacOS/Upscayl $out/bin/upscayl
    runHook postInstall
  '';

  sourceRoot = ".";
}
