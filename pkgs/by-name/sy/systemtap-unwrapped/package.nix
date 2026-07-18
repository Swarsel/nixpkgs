{
  lib,
  stdenv,
  boost,
  cpio,
  elfutils,
  fetchgit,
  gettext,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "systemtap";
  version = "5.4";

  src = fetchgit {
    url = "git://sourceware.org/git/systemtap.git";
    rev = "release-${finalAttrs.version}";
    hash = "sha256-11ecQFiBaWOZcbS5Qqf/41heiJM1wSttx0eMoVQImZc=";
  };

  patches = lib.optionals stdenv.hostPlatform.is32bit [
    # Fix 32bit build
    # https://sourceware.org/git/?p=systemtap.git;a=commit;h=94efb7c4eb02de0e3565cb165b53963602d3dcb6
    # does not apply with fetchpatch because of gitweb encoding issues
    ./systemtap-elaborate-fix-32bit-build.patch
  ];

  nativeBuildInputs = [
    pkg-config
    cpio
    python3
    python3.pkgs.setuptools
  ];

  buildInputs = [
    boost
    elfutils
    gettext
    python3
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Provides a scripting language for instrumentation on a live kernel plus user-space";
    homepage = "https://sourceware.org/systemtap/";
    license = lib.licenses.gpl2;
    platforms = lib.systems.inspect.patterns.isGnu;
  };
})
