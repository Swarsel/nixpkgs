{
  lib,
  stdenv,
  binutils-unwrapped-all-targets,
}:

stdenv.mkDerivation {
  inherit (binutils-unwrapped-all-targets) version;
  pname = "libbfd";

  propagatedBuildInputs = [
    binutils-unwrapped-all-targets.dev
    binutils-unwrapped-all-targets.lib
  ];

  dontBuild = true;
  dontInstall = true;
  dontUnpack = true;

  passthru = {
    inherit (binutils-unwrapped-all-targets) src dev plugin-api-header;
  };

  meta = {
    description = "Library for manipulating containers of machine code";

    longDescription = ''
      BFD is a library which provides a single interface to read and write
      object files, executables, archive files, and core files in any format.
      It is associated with GNU Binutils, and elsewhere often distributed with
      it.
    '';

    homepage = "https://www.gnu.org/software/binutils/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ericson2314 ];
    platforms = lib.platforms.unix;
  };
}
