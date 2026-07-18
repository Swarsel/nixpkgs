{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  obs-studio,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obs-plugin-countdown";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "ashmanix";
    repo = "obs-plugin-countdown";
    tag = finalAttrs.version;
    hash = "sha256-0E2pNRg4vwXK54aYuWYZyuRJaNrpwX7X0Dq6V8B/SgA=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    obs-studio
    qt6.qtbase
  ];

  postInstall = ''
    rm -rf "$out/obs-plugins" "$out/data"
  '';

  dontWrapQtApps = true;

  meta = {
    description = "OBS plugin that creates countdown timers";
    homepage = "https://github.com/ashmanix/obs-plugin-countdown";
    changelog = "https://github.com/ashmanix/obs-plugin-countdown/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
  };
})
