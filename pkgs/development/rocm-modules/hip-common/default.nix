{
  lib,
  stdenv,
  fetchFromGitHub,
  rocmUpdateScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hip-common";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-systems";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-orfTXKjcZJ5E73cmXEyltZVYhCQo8FLExVHM3J/rqUM=";

    sparseCheckout = [
      "projects/hip"
      "shared"
    ];
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv * $out

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = "${finalAttrs.src.name}/projects/hip";
  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "C++ Heterogeneous-Compute Interface for Portability";
    homepage = "https://github.com/ROCm/rocm-systems/tree/develop/projects/hip";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ lovesegfault ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
