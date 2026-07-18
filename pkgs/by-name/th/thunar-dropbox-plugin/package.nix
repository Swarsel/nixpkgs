{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  gtk3,
  ninja,
  pkg-config,
  thunar,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thunar-dropbox";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "Jeinzi";
    repo = "thunar-dropbox";
    rev = finalAttrs.version;
    sha256 = "sha256-uYqO87ftEtnSRn/yMSF1jVGleYXR3hVj2Jb1/kAd64Y=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
  ];

  buildInputs = [
    thunar
    gtk3
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Plugin that adds context-menu items for Dropbox to Thunar";
    homepage = "https://github.com/Jeinzi/thunar-dropbox";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
