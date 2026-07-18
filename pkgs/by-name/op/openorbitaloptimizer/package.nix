{
  lib,
  stdenv,
  fetchFromGitHub,
  armadillo,
  cmake,
  integratorxx,
  libxc,
  nlohmann_json,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openorbitaloptimizer";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "susilehtola";
    repo = "openorbitaloptimizer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bX+pJXZsAdPuWjJi/BynvQt8JnWQAd8NcXTWSH7bi40=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    armadillo
    libxc
  ];

  doCheck = true;

  checkInputs = [
    integratorxx
    nlohmann_json
  ];

  meta = {
    description = "Common orbital optimisation algorithms for quantum chemistry";
    homepage = "https://github.com/susilehtola/OpenOrbitalOptimizer";
    license = [ lib.licenses.mpl20 ];
    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
  };
})
