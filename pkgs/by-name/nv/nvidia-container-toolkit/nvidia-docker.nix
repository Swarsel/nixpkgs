{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nvidia-docker";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "nvidia-docker";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kHzwFnN/DbpOe1sYDJkrRMxXE1bMiyuCPsbPGq07M9g=";
  };

  buildPhase = ''
    mkdir bin

    cp nvidia-docker bin
    substituteInPlace bin/nvidia-docker --subst-var-by VERSION ${finalAttrs.version}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bin/nvidia-docker $out/bin
  '';

  meta = {
    description = "NVIDIA container runtime for Docker";
    homepage = "https://github.com/NVIDIA/nvidia-docker";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ cpcloud ];
    platforms = lib.platforms.linux;
  };
})
