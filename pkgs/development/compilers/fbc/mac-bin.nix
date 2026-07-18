{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "fbc-mac-bin";
  version = "1.06-darwin-wip20160505";

  src = fetchzip {
    url = "https://tmc.castleparadox.com/temp/fbc-${version}.tar.bz2";
    sha256 = "sha256-hD3SRUkk50sf0MhhgHNMvBoJHTKz/71lyFxaAXM4/qI=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R * $out

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "FreeBASIC, a multi-platform BASIC Compiler (precompiled Darwin build by OHRRPGCE team)";
    homepage = "https://rpg.hamsterrepublic.com/ohrrpgce/Compiling_in_Mac_OS_X";
    license = lib.licenses.gpl2Plus; # runtime & graphics libraries are LGPLv2+ w/ static linking exception
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = [ ];
  };
}
