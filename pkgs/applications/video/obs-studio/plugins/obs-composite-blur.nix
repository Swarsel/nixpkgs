{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  obs-studio,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obs-composite-blur";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "FiniteSingularity";
    repo = "obs-composite-blur";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wT49bCxik8mrg+YleNelOPQQzqcYQR7ZSnzvPXA5D3g=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    obs-studio
  ];

  postInstall = ''
    rm -rf "$out/share"
    mkdir -p "$out/share/obs"
    mv "$out/data/obs-plugins" "$out/share/obs"
    rm -rf "$out/obs-plugins" "$out/data"
  '';

  meta = {
    description = "Comprehensive blur plugin for OBS that provides several different blur algorithms, and proper compositing";
    homepage = "https://github.com/FiniteSingularity/obs-composite-blur";
    changelog = "https://github.com/FiniteSingularity/obs-composite-blur/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
  };
})
