{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tinyfecvpn";
  version = "20230206.0";

  src = fetchFromGitHub {
    owner = "wangyu-";
    repo = "tinyfecvpn";
    tag = finalAttrs.version;
    hash = "sha256-g4dduREH64TDK3Y2PKc5RZiISW4h2ALRh8vQK7jvCZU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  installPhase = ''
    runHook preInstall
    install -Dm755 tinyvpn $out/bin/tinyvpn
    runHook postInstall
  '';

  enableParallelBuilding = true;

  patchPhase = ''
    runHook prePatch
    find . -type f -name "makefile" -exec sed "s/ -static/ -g/g" -i \{\} \;
    runHook postPatch
  '';

  meta = {
    description = "VPN Designed for Lossy Links, with Build-in Forward Error Correction(FEC) Support";
    homepage = "https://github.com/wangyu-/tinyfecVPN";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "tinyvpn";
  };
})
