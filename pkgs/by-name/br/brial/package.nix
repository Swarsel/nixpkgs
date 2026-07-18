{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  boost,
  gd,
  m4ri,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brial";
  version = "1.2.15";

  src = fetchFromGitHub {
    owner = "BRiAl";
    repo = "BRiAl";
    tag = finalAttrs.version;
    sha256 = "sha256-I8p2jdc2/oq9piy1QvNl+N0+MHDE5Xv1kawkRTjrWSU=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    boost
    m4ri
    gd
  ];

  configureFlags = [
    "--with-boost-unit-test-framework=no"
  ];

  # FIXME package boost-test and enable checks
  doCheck = false;

  meta = {
    description = "Legacy version of PolyBoRi maintained by sagemath developers";
    homepage = "https://github.com/BRiAl/BRiAl";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.sage ];
  };
})
