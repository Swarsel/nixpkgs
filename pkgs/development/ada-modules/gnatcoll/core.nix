{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  gnat,
  # for tests
  gnatcoll-core,
  gprbuild,
  python3,
  rsync,
  which,
  enableGnatcollCore ? true,
  # TODO(@sternenseemann): figure out a way to split this up into three packages
  enableGnatcollProjects ? true,
}:

# gnatcoll-projects depends on gnatcoll-core
assert enableGnatcollProjects -> enableGnatcollCore;

stdenv.mkDerivation rec {
  pname = "gnatcoll-core";
  version = "25.0.0";

  src = fetchFromGitHub {
    owner = "AdaCore";
    repo = "gnatcoll-core";
    rev = "v${version}";
    sha256 = "1srnh7vhs46c2zy4hcy4pg0a0prghfzlpv7c82k0jan384yz1g6g";
  };

  patches = [
    # Fix compilation with GNAT 16
    (fetchpatch2 {
      hash = "sha256-rG0D1y2dbXA2M2Arnto+f7iAhg3yCfTPDbDRN+pMJKQ=";
      name = "gnatcoll-core-gnat-16.patch";
      url = "https://github.com/AdaCore/gnatcoll-core/commit/b266466e0a05b30615ec43d72782c345470455b9.patch?full_index=1";
    })
  ];

  postPatch = ''
    patchShebangs */*.gpr.py
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gprbuild
    which
    gnat
    python3
    rsync
  ];

  # propagate since gprbuild needs to find
  # referenced GPR project definitions
  propagatedBuildInputs = lib.optionals enableGnatcollProjects [
    gprbuild # libgpr
  ];

  makeFlags = [
    "prefix=${placeholder "out"}"
    "PROCESSORS=$(NIX_BUILD_CORES)"
    # confusingly, for gprbuild --target is autoconf --host
    "TARGET=${stdenv.hostPlatform.config}"
    "GNATCOLL_MINIMAL_ONLY=${lib.boolToYesNo (!enableGnatcollCore)}"
    "GNATCOLL_PROJECTS=${lib.boolToYesNo enableGnatcollProjects}"
  ];

  passthru.tests = {
    minimalOnly = gnatcoll-core.override {
      enableGnatcollCore = false;
      enableGnatcollProjects = false;
    };

    noProjects = gnatcoll-core.override {
      enableGnatcollCore = true;
      enableGnatcollProjects = false;
    };
  };

  meta = {
    description = "GNAT Components Collection - Core packages";
    homepage = "https://github.com/AdaCore/gnatcoll-core";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sternenseemann ];
    platforms = lib.platforms.all;
  };
}
