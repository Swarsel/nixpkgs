{
  lib,
  stdenv,
  fetchFromGitHub,
  coin-utils,
  coinmp,
  gfortran,
  glpk,
  libtool,
  osi,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "symphony";
  version = "5.7.3";

  src = fetchFromGitHub {
    owner = "coin-or";
    repo = "SYMPHONY";
    tag = "releases/${finalAttrs.version}";
    hash = "sha256-f97LICRykxhiZiSsSBE9IJBLL/ApWV+utvlHuUhx1PI=";
  };

  outputs = [ "out" ];

  nativeBuildInputs = [
    gfortran
    libtool
    pkg-config
  ];

  buildInputs = [
    coin-utils
    coinmp
    glpk
    osi
  ];

  meta = {
    description = "Open-source solver, callable library, and development framework for mixed-integer linear programs (MILPs)";
    homepage = "https://www.coin-or.org/SYMPHONY/index.htm";
    changelog = "https://github.com/coin-or/SYMPHONY/blob/releases/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.epl20;
    maintainers = with lib.maintainers; [ b-rodrigues ];
    platforms = lib.platforms.linux;
  };
})
