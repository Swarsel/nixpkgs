{
  lib,
  stdenv,
  binutils-unwrapped-all-targets,
}:

stdenv.mkDerivation {
  inherit (binutils-unwrapped-all-targets) version;
  pname = "libopcodes";

  propagatedBuildInputs = [
    binutils-unwrapped-all-targets.dev
    binutils-unwrapped-all-targets.lib
  ];

  dontBuild = true;
  dontInstall = true;
  dontUnpack = true;

  passthru = {
    inherit (binutils-unwrapped-all-targets) dev;
  };

  meta = {
    description = "Library from binutils for manipulating machine code";
    homepage = "https://www.gnu.org/software/binutils/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ericson2314 ];
    platforms = lib.platforms.unix;
  };
}
