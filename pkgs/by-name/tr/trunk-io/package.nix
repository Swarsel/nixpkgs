{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "trunk-io";
  version = "1.3.4";

  src = fetchurl {
    url = "https://trunk.io/releases/launcher/${finalAttrs.version}/trunk";
    hash = "sha256-ifvdjHtjZJ7rFHlBV1e4mJA8BB5ztJt4Ao29ZOyjCHo=";
  };

  installPhase = ''
    install -D $src $out/bin/trunk
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Developer experience toolkit used to check, test, merge, and monitor code";
    homepage = "https://trunk.io/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ aaronjheng ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "trunk";
  };
})
