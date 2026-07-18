{
  lib,
  stdenv,
  fetchFromGitHub,
  clr,
  cmake,
  rocmUpdateScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aqlprofile";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-systems";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-74HjB5Ughu17rSRx9mfCCsPJI4TVyXnT4aU7vIbm7ak=";

    sparseCheckout = [
      "projects/aqlprofile"
      "shared"
    ];
  };

  nativeBuildInputs = [
    cmake
    clr
  ];

  env.CXXFLAGS = "-DROCP_LD_AQLPROFILE=1";
  sourceRoot = "${finalAttrs.src.name}/projects/aqlprofile";
  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "AQLPROFILE library for AMD HSA runtime API extension support";
    homepage = "https://github.com/ROCm/rocm-systems/tree/develop/projects/aqlprofile";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
