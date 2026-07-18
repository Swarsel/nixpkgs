{
  lib,
  stdenv,
  fetchurl,
  undmg,
}:
stdenv.mkDerivation rec {
  pname = "Skim";
  version = "1.7.9";

  src = fetchurl {
    url = "mirror://sourceforge/project/skim-app/Skim/Skim-${version}/Skim-${version}.dmg";
    hash = "sha256-0IfdLeH6RPxf4OZWnNltN7tvvZWbWDQaMCmazd4UUi4=";
    name = "Skim-${version}.dmg";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R Skim.app $out/Applications
    runHook postInstall
  '';

  sourceRoot = ".";

  meta = {
    description = "PDF reader and note-taker for macOS";
    homepage = "https://skim-app.sourceforge.io/";
    license = lib.licenses.bsd0;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ YvesStraten ];
    platforms = lib.platforms.darwin;
    mainProgram = "Skim.app";
  };
}
