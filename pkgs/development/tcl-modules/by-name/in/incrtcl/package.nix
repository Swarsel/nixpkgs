{
  lib,
  stdenv,
  fetchurl,
  mkTclDerivation,
  tcl,
  writeText,
}:

mkTclDerivation rec {
  pname = "incrtcl";
  version = "4.2.3";

  src = fetchurl {
    url = "mirror://sourceforge/incrtcl/%5BIncr%20Tcl_Tk%5D-source/3.4/itcl${version}.tar.gz";
    hash = "sha256-idOs2GXP3ZY7ECtF+K9hg5REyK6sQ0qk+666gUQPjCY=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  postInstall = ''
    rmdir $out/bin
    mv $out/lib/itcl${version}/* $out/lib
    ln -s libitcl${version}${stdenv.hostPlatform.extensions.sharedLibrary} \
      $out/lib/libitcl${lib.versions.major version}${stdenv.hostPlatform.extensions.sharedLibrary}
    rmdir $out/lib/itcl${version}
  '';

  enableParallelBuilding = true;

  patchPhase = ''
    substituteInPlace configure --replace-fail "\''${TCL_SRC_DIR}/generic" "${tcl}/include"
  '';

  setupHook = writeText "setup-hook.sh" ''
    export ITCL_LIBRARY=@out@/lib
  '';

  meta = {
    description = "Object Oriented Enhancements for Tcl/Tk";
    homepage = "https://incrtcl.sourceforge.net/";
    license = lib.licenses.tcltk;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.unix;
    broken = tcl.isTcl9;
  };
}
