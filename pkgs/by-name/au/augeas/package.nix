{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  flex,
  libxml2,
  perl, # for pod2man
  pkg-config,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "augeas";
  version = "1.14.1";

  src = fetchFromGitHub {
    owner = "hercules-team";
    repo = "augeas";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-U5tm3LDUeI/idHtL2Zy33BigkyvHunXPjToDC59G9VE=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # already have the submodules so don't fail when .git doesn't exist.
    ./bootstrap.diff
  ];

  postPatch = ''
    ./bootstrap --gnulib-srcdir=.gnulib
  '';

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    perl
    pkg-config
  ];

  buildInputs = [
    readline
    libxml2
  ];

  configureFlags = lib.optionals stdenv.buildPlatform.isDarwin [ "--disable-gnulib-tests" ];
  doCheck = true;

  checkPhase = ''
    runHook preCheck
    patchShebangs --build gnulib/tests tests
    make -j $NIX_BUILD_CORES check
    runHook postCheck
  '';

  # Makefile doesn't specify dependencies on parser.h correctly
  enableParallelBuilding = false;

  meta = {
    description = "Configuration editing tool";
    homepage = "https://augeas.net/";
    changelog = "https://github.com/hercules-team/augeas/releases/tag/release-${finalAttrs.version}";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ skyethepinkcat ];
    platforms = lib.platforms.unix;
    mainProgram = "augtool";
  };
})
