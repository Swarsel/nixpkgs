{
  lib,
  stdenv,
  bluez,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bluesnarfer";
  version = "0.1";

  src = fetchzip {
    url = "https://www.alighieri.org/tools/bluesnarfer.tar.gz";
    hash = "sha256-HGdrJZohKIsOkLETBdHz80w6vxmG25aMEWXrQlpMgRw=";
    stripRoot = false;
  };

  strictDeps = true;
  buildInputs = [ bluez ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-incompatible-pointer-types"
    "-Wno-implicit-function-declaration"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 bluesnarfer $out/bin/bluesnarfer
    runHook postInstall
  '';

  sourceRoot = finalAttrs.src.name + "/bluesnarfer";

  meta = {
    description = "Bluetooth bluesnarfing utility";
    homepage = "https://www.alighieri.org/project.html";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.linux;
  };
})
