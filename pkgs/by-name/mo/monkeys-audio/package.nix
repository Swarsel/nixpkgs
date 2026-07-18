{
  lib,
  stdenv,
  cmake,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "monkeys-audio";
  version = "13.18";

  src = fetchzip {
    url = "https://monkeysaudio.com/files/MAC_${builtins.concatStringsSep "" (lib.strings.splitString "." finalAttrs.version)}_SDK.zip";
    hash = "sha256-zNEEJSHdr89lsLGBIL2lXixSCk0Wj1kgT0GKpph5jXY=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "APE codec and decompressor";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = with lib.platforms; linux ++ windows ++ darwin;
    mainProgram = "mac";
  };
})
