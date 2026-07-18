{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  gengetopt,
  git,
  gnupg,
  help2man,
  m4,
  perl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mmv";
  version = "2.10";

  src = fetchFromGitHub {
    owner = "rrthomas";
    repo = "mmv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h+hdrIQz+7jKdMdJtWhBbZgvmNTIOr7Q38nhfAWC+G4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    gengetopt
    m4
    git
    gnupg
    perl
    autoconf
    automake
    help2man
    pkg-config
  ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=implicit-function-declaration"
      "-Wno-error=implicit-int"
      "-Wno-error=int-conversion"
    ];
  };

  preConfigure = ''
    ./bootstrap
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Utility for wildcard renaming, copying, etc";
    homepage = "https://github.com/rrthomas/mmv";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
  };
})
