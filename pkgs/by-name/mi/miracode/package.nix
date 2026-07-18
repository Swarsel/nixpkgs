{
  lib,
  fetchurl,
  stdenvNoCC,
}:

let
  version = "1.0";
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "miracode";

  src = fetchurl {
    url = "https://github.com/IdreesInc/Miracode/releases/download/v${version}/Miracode.ttf";
    hash = "sha256-Q+/D/TPlqOt779qYS/dF7ahEd3Mm4a4G+wdHB+Gutmo=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/share/fonts/truetype/Miracode.ttf
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  meta = {
    description = "Sharp, readable, vector-y version of Monocraft";
    homepage = "https://github.com/IdreesInc/Miracode";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ coca ];
    platforms = lib.platforms.all;
  };
}
