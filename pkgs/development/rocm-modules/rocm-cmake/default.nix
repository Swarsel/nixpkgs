{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  rocm-core,
  rocmUpdateScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocm-cmake";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-cmake";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-gY6jzIIN1pSXGbCMN6y35Q/VJgbIqWDRjD8aI/fc1L0=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ rocm-core ];
  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "CMake modules for common build tasks for the ROCm stack";
    homepage = "https://github.com/ROCm/rocm-cmake";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.rocm ];
  };
})
