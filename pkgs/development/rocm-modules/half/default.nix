{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  rocm-cmake,
  rocmUpdateScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "half";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "half";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-If9O5BEeymsLN+C0drZsPSxEWXpJTxeDBGNHNXSumm4=";
  };

  nativeBuildInputs = [
    cmake
    rocm-cmake
  ];

  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "C++ library for half precision floating point arithmetics";
    homepage = "https://github.com/ROCm/half";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.rocm ];
  };
})
