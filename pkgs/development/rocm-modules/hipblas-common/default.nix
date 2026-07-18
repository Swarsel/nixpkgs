{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  rocm-cmake,
  rocmUpdateScript,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hipblas-common";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-libraries";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-83LgS4I1fMSaNtWdVFf1qhYRMT7a9jVzO3XpUzEipXg=";

    sparseCheckout = [
      "projects/hipblas-common"
      "shared"
    ];
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    rocm-cmake
  ];

  sourceRoot = "${finalAttrs.src.name}/projects/hipblas-common";
  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "Common files shared by hipBLAS and hipBLASLt";
    homepage = "https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipblas-common";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
