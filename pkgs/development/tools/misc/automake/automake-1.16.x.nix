{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  perl,
  updateAutotoolsGnuConfigScriptsHook,
}:

stdenv.mkDerivation rec {
  pname = "automake";
  version = "1.16.5";

  src = fetchurl {
    url = "mirror://gnu/automake/automake-${version}.tar.xz";
    sha256 = "0sdl32qxdy7m06iggmkkvf7j520rmmgbsjzbm7fgnxwxdp6mh7gh";
  };

  strictDeps = true;

  nativeBuildInputs = [
    updateAutotoolsGnuConfigScriptsHook
    autoconf
    perl
  ];

  buildInputs = [ autoconf ];
  doCheck = false; # takes _a lot_ of time, fails 3 out of 2698 tests, all seem to be related to paths
  doInstallCheck = false; # runs the same thing, fails the same tests
  # Don't fixup "#! /bin/sh" in Libtool, otherwise it will use the
  # "fixed" path in generated files!
  dontPatchShebangs = true;
  # The test suite can run in parallel.
  enableParallelBuilding = true;
  setupHook = ./setup-hook.sh;

  meta = {
    description = "GNU standard-compliant makefile generator";

    longDescription = ''
      GNU Automake is a tool for automatically generating
      `Makefile.in' files compliant with the GNU Coding
      Standards.  Automake requires the use of Autoconf.
    '';

    homepage = "https://www.gnu.org/software/automake/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    branch = "1.16";
  };
}
