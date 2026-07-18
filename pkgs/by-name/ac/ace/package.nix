{
  lib,
  stdenv,
  fetchurl,
  libtool,
  perl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ace";
  version = "7.0.11";

  src = fetchurl {
    url = "https://download.dre.vanderbilt.edu/previous_versions/ACE-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-r+LRiu/u1qMcbrjkSr8ErnemX6zvhgvc5cLWu8AQhww=";
  };

  postPatch = ''
    patchShebangs ./MPC/prj_install.pl
  '';

  nativeBuildInputs = [
    pkg-config
    libtool
  ];

  buildInputs = [ perl ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=format-security"
  ];

  preConfigure = ''
    export INSTALL_PREFIX=$out
    export ACE_ROOT=$(pwd)
    export LD_LIBRARY_PATH="$ACE_ROOT/ace:$ACE_ROOT/lib"
    echo '#include "ace/config-linux.h"' > ace/config.h
    echo 'include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU'\
    > include/makeinclude/platform_macros.GNU
  '';

  enableParallelBuilding = true;

  meta = {
    description = "ADAPTIVE Communication Environment";
    homepage = "https://www.dre.vanderbilt.edu/~schmidt/ACE.html";
    license = lib.licenses.doc;
    maintainers = with lib.maintainers; [ nico202 ];
    platforms = lib.platforms.linux;
    mainProgram = "ace_gperf";
  };
})
